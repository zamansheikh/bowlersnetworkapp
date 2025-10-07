import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/constants.dart';
import '../models/tournament_model.dart';
import '../../domain/entities/tournament.dart';
import 'tournament_remote_data_source.dart';

@Injectable(as: TournamentRemoteDataSource)
class TournamentRemoteDataSourceImpl implements TournamentRemoteDataSource {
  final Dio _dio;
  final SharedPreferences _prefs;

  TournamentRemoteDataSourceImpl(this._dio, this._prefs);

  @override
  Future<List<Tournament>> getTournaments() async {
    try {
      debugPrint(
        '🏆 TournamentDataSource: Fetching tournaments from /api/tournaments',
      );

      final response = await _dio.get(
        '/api/tournaments',
        options: _getOptionsWithAuth(),
      );

      debugPrint(
        '🏆 TournamentDataSource: Response status: ${response.statusCode}',
      );
      debugPrint('🏆 TournamentDataSource: Response data: ${response.data}');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data as List<dynamic>;
        final tournaments = data
            .map(
              (json) => TournamentModel.fromJson(json as Map<String, dynamic>),
            )
            .toList();

        return tournaments.map((model) => model.toEntity()).toList();
      } else {
        throw Exception('Failed to load tournaments: ${response.statusCode}');
      }
    } on DioException catch (e) {
      debugPrint('🏆 TournamentDataSource: Dio error: ${e.message}');
      if (e.response != null) {
        debugPrint(
          '🏆 TournamentDataSource: Error response: ${e.response?.data}',
        );
        throw Exception(
          'Failed to load tournaments: ${e.response?.statusCode} - ${e.response?.data}',
        );
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      debugPrint('🏆 TournamentDataSource: Unexpected error: $e');
      throw Exception('Failed to load tournaments: $e');
    }
  }

  @override
  Future<Tournament> getTournamentById(int id) async {
    try {
      debugPrint('🏆 TournamentDataSource: Fetching tournament $id');

      // For now, get all tournaments and find the one we need
      // In a real API, this would be GET /api/tournaments/$id
      final tournaments = await getTournaments();
      final tournament = tournaments.firstWhere(
        (t) => t.id == id,
        orElse: () => throw Exception('Tournament not found'),
      );

      return tournament;
    } catch (e) {
      debugPrint('🏆 TournamentDataSource: Error fetching tournament $id: $e');
      rethrow;
    }
  }

  @override
  Future<void> registerForTournament(int tournamentId) async {
    try {
      debugPrint(
        '🏆 TournamentDataSource: Registering for tournament $tournamentId',
      );

      final response = await _dio.post(
        '/api/tournaments/$tournamentId/register',
        options: _getOptionsWithAuth(),
      );

      debugPrint(
        '🏆 TournamentDataSource: Registration response: ${response.statusCode}',
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to register: ${response.statusCode}');
      }
    } on DioException catch (e) {
      debugPrint('🏆 TournamentDataSource: Registration error: ${e.message}');
      if (e.response != null) {
        throw Exception(
          'Registration failed: ${e.response?.statusCode} - ${e.response?.data}',
        );
      }
      throw Exception('Network error: ${e.message}');
    }
  }

  @override
  Future<void> unregisterFromTournament(int tournamentId) async {
    try {
      debugPrint(
        '🏆 TournamentDataSource: Unregistering from tournament $tournamentId',
      );

      final response = await _dio.delete(
        '/api/tournaments/$tournamentId/register',
        options: _getOptionsWithAuth(),
      );

      debugPrint(
        '🏆 TournamentDataSource: Unregistration response: ${response.statusCode}',
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to unregister: ${response.statusCode}');
      }
    } on DioException catch (e) {
      debugPrint('🏆 TournamentDataSource: Unregistration error: ${e.message}');
      if (e.response != null) {
        throw Exception(
          'Unregistration failed: ${e.response?.statusCode} - ${e.response?.data}',
        );
      }
      throw Exception('Network error: ${e.message}');
    }
  }

  @override
  Future<Tournament> createTournament({
    required String name,
    required String startDate,
    required String regDeadline,
    required String regFee,
    required String address,
    String? lat,
    String? long,
    required int participantsCount,
    required String accessType,
    required String tournamentType,
    double? average,
    double? percentage,
  }) async {
    try {
      debugPrint('🏆 TournamentDataSource: Creating tournament: $name');

      final data = {
        'name': name,
        'start_date': startDate,
        'reg_deadline': regDeadline,
        'reg_fee': double.tryParse(regFee) ?? 0.0, // Convert string to double
        'address': address,
        if (lat != null) 'lat': lat,
        if (long != null) 'long': long,
        'participants_count': participantsCount,
        'access_type': accessType,
        'tournament_type': tournamentType,
        if (average != null) 'average': average,
        if (percentage != null) 'percentage': percentage,
      };

      final response = await _dio.post(
        '/api/tournaments',
        data: data,
        options: _getOptionsWithAuth(),
      );

      debugPrint(
        '🏆 TournamentDataSource: Create response: ${response.statusCode}',
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final tournamentModel = TournamentModel.fromJson(
          response.data as Map<String, dynamic>,
        );
        return tournamentModel.toEntity();
      } else {
        throw Exception('Failed to create tournament: ${response.statusCode}');
      }
    } on DioException catch (e) {
      debugPrint('🏆 TournamentDataSource: Create error: ${e.message}');
      if (e.response != null) {
        throw Exception(
          'Failed to create tournament: ${e.response?.statusCode} - ${e.response?.data}',
        );
      }
      throw Exception('Network error: ${e.message}');
    }
  }

  @override
  Future<List<Tournament>> getUserRegisteredTournaments() async {
    try {
      final allTournaments = await getTournaments();
      return allTournaments
          .where((tournament) => tournament.isRegistered)
          .toList();
    } catch (e) {
      debugPrint(
        '🏆 TournamentDataSource: Error fetching registered tournaments: $e',
      );
      rethrow;
    }
  }

  @override
  Future<List<Tournament>> getAvailableTournaments() async {
    try {
      final allTournaments = await getTournaments();
      return allTournaments
          .where((tournament) => !tournament.isRegistered)
          .toList();
    } catch (e) {
      debugPrint(
        '🏆 TournamentDataSource: Error fetching available tournaments: $e',
      );
      rethrow;
    }
  }

  // Helper methods for authentication
  String? _getAuthToken() {
    return _prefs.getString(AppConstants.tokenKey);
  }

  Options _getOptionsWithAuth() {
    final options = Options();
    final token = _getAuthToken();

    debugPrint(
      '🏆 TournamentDataSource: Token retrieved: ${token != null ? 'Token exists (${token.length} chars)' : 'No token found'}',
    );

    if (token != null) {
      options.headers = {'Authorization': 'Bearer $token'};
      debugPrint('🏆 TournamentDataSource: Added Authorization header');
    }

    return options;
  }

  @override
  Future<void> registerSinglesForTournament(
    int tournamentId,
    int playerId,
  ) async {
    try {
      debugPrint(
        '🏆 TournamentDataSource: Registering player $playerId for singles tournament $tournamentId',
      );

      final response = await _dio.post(
        '/api/tournament/$tournamentId/add-singles-member/$playerId',
        options: _getOptionsWithAuth(),
      );

      debugPrint(
        '🏆 TournamentDataSource: Singles registration response: ${response.statusCode}',
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception(
          'Failed to register for singles tournament: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      debugPrint(
        '🏆 TournamentDataSource: Singles registration error: ${e.message}',
      );
      if (e.response != null) {
        throw Exception(
          'Singles registration failed: ${e.response?.statusCode} - ${e.response?.data}',
        );
      }
      throw Exception('Network error: ${e.message}');
    }
  }

  @override
  Future<void> registerTeamForTournament(int tournamentId, int teamId) async {
    try {
      debugPrint(
        '🏆 TournamentDataSource: Registering team $teamId for tournament $tournamentId',
      );

      final response = await _dio.post(
        '/api/tournament/$tournamentId/add-teams-member/$teamId',
        options: _getOptionsWithAuth(),
      );

      debugPrint(
        '🏆 TournamentDataSource: Team registration response: ${response.statusCode}',
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception(
          'Failed to register team for tournament: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      debugPrint(
        '🏆 TournamentDataSource: Team registration error: ${e.message}',
      );
      if (e.response != null) {
        throw Exception(
          'Team registration failed: ${e.response?.statusCode} - ${e.response?.data}',
        );
      }
      throw Exception('Network error: ${e.message}');
    }
  }
}
