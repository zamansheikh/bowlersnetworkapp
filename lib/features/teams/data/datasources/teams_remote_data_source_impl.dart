import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/constants.dart';
import '../models/team_model.dart';
import '../models/team_member_model.dart';
import '../models/team_invitation_model.dart';
import '../../domain/entities/team.dart';
import '../../domain/entities/team_member.dart';
import '../../domain/entities/team_invitation.dart';
import 'teams_remote_data_source.dart';

@Injectable(as: TeamsRemoteDataSource)
class TeamsRemoteDataSourceImpl implements TeamsRemoteDataSource {
  final Dio _dio;
  final SharedPreferences _prefs;

  TeamsRemoteDataSourceImpl(this._dio, this._prefs);

  @override
  Future<List<Team>> getUserTeams() async {
    try {
      print('🏆 TeamsDataSource: Fetching user teams from /api/user/teams');

      final response = await _dio.get(
        '/api/user/teams',
        options: _getOptionsWithAuth(),
      );

      print('🏆 TeamsDataSource: Response status: ${response.statusCode}');
      print('🏆 TeamsDataSource: Response data: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final myTeams = data['my_teams'] as List<dynamic>;

        // Fetch member count for each team
        final List<Team> teamsWithMembers = [];
        for (final teamJson in myTeams) {
          try {
            final teamModel = TeamModel.fromJson(
              teamJson as Map<String, dynamic>,
            );
            final team = teamModel.toEntity();

            // Fetch member count
            final membersResponse = await _dio.get(
              '/api/user/teams/${team.teamId}/members',
              options: _getOptionsWithAuth(),
            );

            if (membersResponse.statusCode == 200) {
              final membersData = membersResponse.data as Map<String, dynamic>;
              final memberCount = membersData['members']?['member_count'] ?? 0;
              teamsWithMembers.add(team.copyWith(memberCount: memberCount));
            } else {
              teamsWithMembers.add(team);
            }
          } catch (e) {
            print('🏆 TeamsDataSource: Error processing team: $e');
            continue;
          }
        }

        return teamsWithMembers;
      } else {
        throw Exception('Failed to load teams: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('🏆 TeamsDataSource: Dio error: ${e.message}');
      if (e.response != null) {
        print('🏆 TeamsDataSource: Error response: ${e.response?.data}');
        throw Exception(
          'Failed to load teams: ${e.response?.statusCode} - ${e.response?.data}',
        );
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      print('🏆 TeamsDataSource: Unexpected error: $e');
      throw Exception('Failed to load teams: $e');
    }
  }

  @override
  Future<Team> createTeam({required String name}) async {
    try {
      print('🏆 TeamsDataSource: Creating team: $name');

      final data = {'name': name};

      final response = await _dio.post(
        '/api/user/teams',
        data: data,
        options: _getOptionsWithAuth(),
      );

      print('🏆 TeamsDataSource: Create response: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final teamModel = TeamModel.fromJson(
          response.data as Map<String, dynamic>,
        );
        return teamModel.toEntity();
      } else {
        throw Exception('Failed to create team: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('🏆 TeamsDataSource: Create error: ${e.message}');
      if (e.response != null) {
        throw Exception(
          'Failed to create team: ${e.response?.statusCode} - ${e.response?.data}',
        );
      }
      throw Exception('Network error: ${e.message}');
    }
  }

  @override
  Future<void> deleteTeam(int teamId) async {
    try {
      print('🏆 TeamsDataSource: Deleting team $teamId');

      final response = await _dio.delete(
        '/api/user/teams/$teamId/delete',
        options: _getOptionsWithAuth(),
      );

      print('🏆 TeamsDataSource: Delete response: ${response.statusCode}');

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete team: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('🏆 TeamsDataSource: Delete error: ${e.message}');
      if (e.response != null) {
        throw Exception(
          'Failed to delete team: ${e.response?.statusCode} - ${e.response?.data}',
        );
      }
      throw Exception('Network error: ${e.message}');
    }
  }

  @override
  Future<TeamDetails> getTeamDetails(int teamId) async {
    try {
      print('🏆 TeamsDataSource: Fetching team details $teamId');

      final response = await _dio.get(
        '/api/user/teams/$teamId/members',
        options: _getOptionsWithAuth(),
      );

      print(
        '🏆 TeamsDataSource: Team details response: ${response.statusCode}',
      );

      if (response.statusCode == 200) {
        final teamDetailsModel = TeamDetailsModel.fromJson(
          response.data as Map<String, dynamic>,
        );
        return teamDetailsModel.toEntity();
      } else {
        throw Exception('Failed to get team details: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('🏆 TeamsDataSource: Team details error: ${e.message}');
      if (e.response != null) {
        throw Exception(
          'Failed to get team details: ${e.response?.statusCode} - ${e.response?.data}',
        );
      }
      throw Exception('Network error: ${e.message}');
    }
  }

  @override
  Future<List<AvailableMember>> getAvailableMembers() async {
    try {
      print('🏆 TeamsDataSource: Fetching available members');

      final response = await _dio.get(
        '/api/user-data',
        options: _getOptionsWithAuth(),
      );

      print(
        '🏆 TeamsDataSource: Available members response: ${response.statusCode}',
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data as List<dynamic>;
        final members = data
            .map(
              (json) =>
                  AvailableMemberModel.fromJson(json as Map<String, dynamic>),
            )
            .toList();

        return members.map((model) => model.toEntity()).toList();
      } else {
        throw Exception(
          'Failed to load available members: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      print('🏆 TeamsDataSource: Available members error: ${e.message}');
      if (e.response != null) {
        throw Exception(
          'Failed to load available members: ${e.response?.statusCode} - ${e.response?.data}',
        );
      }
      throw Exception('Network error: ${e.message}');
    }
  }

  @override
  Future<void> inviteUserToTeam({
    required int teamId,
    required int invitedUserId,
  }) async {
    try {
      print('🏆 TeamsDataSource: Inviting user $invitedUserId to team $teamId');

      final data = {'team_id': teamId, 'invited_user_id': invitedUserId};

      final response = await _dio.post(
        '/api/user/teams/invite',
        data: data,
        options: _getOptionsWithAuth(),
      );

      print('🏆 TeamsDataSource: Invite response: ${response.statusCode}');

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to invite user: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('🏆 TeamsDataSource: Invite error: ${e.message}');
      if (e.response != null) {
        throw Exception(
          'Failed to invite user: ${e.response?.statusCode} - ${e.response?.data}',
        );
      }
      throw Exception('Network error: ${e.message}');
    }
  }

  @override
  Future<TeamInvitations> getTeamInvitations() async {
    try {
      print('🏆 TeamsDataSource: Fetching team invitations');

      final response = await _dio.get(
        '/api/user/teams/invitations',
        options: _getOptionsWithAuth(),
      );

      print('🏆 TeamsDataSource: Invitations response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final teamInvitationsModel = TeamInvitationsModel.fromJson(
          response.data as Map<String, dynamic>,
        );
        return teamInvitationsModel.toEntity();
      } else {
        throw Exception('Failed to load invitations: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('🏆 TeamsDataSource: Invitations error: ${e.message}');
      if (e.response != null) {
        throw Exception(
          'Failed to load invitations: ${e.response?.statusCode} - ${e.response?.data}',
        );
      }
      throw Exception('Network error: ${e.message}');
    }
  }

  @override
  Future<void> respondToInvitation({
    required int invitationId,
    required bool isAccepted,
  }) async {
    try {
      print(
        '🏆 TeamsDataSource: Responding to invitation $invitationId: $isAccepted',
      );

      final data = {'invitation_id': invitationId, 'is_accepted': isAccepted};

      final response = await _dio.post(
        '/api/user/teams/invitations',
        data: data,
        options: _getOptionsWithAuth(),
      );

      print('🏆 TeamsDataSource: Respond response: ${response.statusCode}');

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception(
          'Failed to respond to invitation: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      print('🏆 TeamsDataSource: Respond error: ${e.message}');
      if (e.response != null) {
        throw Exception(
          'Failed to respond to invitation: ${e.response?.statusCode} - ${e.response?.data}',
        );
      }
      throw Exception('Network error: ${e.message}');
    }
  }

  @override
  Future<void> withdrawInvitation(int invitationId) async {
    try {
      print('🏆 TeamsDataSource: Withdrawing invitation $invitationId');

      final data = {'invitation_id': invitationId};

      final response = await _dio.delete(
        '/api/user/teams/invitations',
        data: data,
        options: _getOptionsWithAuth(),
      );

      print('🏆 TeamsDataSource: Withdraw response: ${response.statusCode}');

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception(
          'Failed to withdraw invitation: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      print('🏆 TeamsDataSource: Withdraw error: ${e.message}');
      if (e.response != null) {
        throw Exception(
          'Failed to withdraw invitation: ${e.response?.statusCode} - ${e.response?.data}',
        );
      }
      throw Exception('Network error: ${e.message}');
    }
  }

  @override
  Future<void> removeMemberFromTeam({
    required int teamId,
    required int memberId,
  }) async {
    try {
      print('🏆 TeamsDataSource: Removing member $memberId from team $teamId');

      final response = await _dio.delete(
        '/api/user/teams/$teamId/members/$memberId',
        options: _getOptionsWithAuth(),
      );

      print(
        '🏆 TeamsDataSource: Remove member response: ${response.statusCode}',
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to remove member: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('🏆 TeamsDataSource: Remove member error: ${e.message}');
      if (e.response != null) {
        throw Exception(
          'Failed to remove member: ${e.response?.statusCode} - ${e.response?.data}',
        );
      }
      throw Exception('Network error: ${e.message}');
    }
  }

  // Helper methods for authentication
  String? _getAuthToken() {
    return _prefs.getString(AppConstants.tokenKey);
  }

  Options _getOptionsWithAuth() {
    final options = Options();
    final token = _getAuthToken();

    print(
      '🏆 TeamsDataSource: Token retrieved: ${token != null ? 'Token exists (${token.length} chars)' : 'No token found'}',
    );

    if (token != null) {
      options.headers = {'Authorization': 'Bearer $token'};
      print('🏆 TeamsDataSource: Added Authorization header');
    }

    return options;
  }
}
