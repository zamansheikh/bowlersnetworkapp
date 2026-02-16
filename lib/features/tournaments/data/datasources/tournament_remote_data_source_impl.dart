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
        '🏆 TournamentDataSource: Fetching tournaments from /api/tournaments/v0',
      );

      final response = await _dio.get(
        '/api/tournaments/v0',
        options: _getOptionsWithAuth(),
      );

      debugPrint(
        '🏆 TournamentDataSource: Response status: ${response.statusCode}',
      );

      if (response.statusCode == 200) {
        final dynamic responseData = response.data;
        final List<dynamic> data;

        if (responseData is List) {
          data = responseData;
        } else if (responseData is Map &&
            responseData.containsKey('data') &&
            responseData['data'] is List) {
          data = responseData['data'];
        } else {
          // Fallback or empty if structure is completely different
          data = [];
          debugPrint(
            '🏆 TournamentDataSource: Unexpected response structure: $responseData',
          );
        }

        final tournaments = data.map((item) {
          // Check if item has a nested 'data' object (common in v0/v1 Laravel resources sometimes)
          // Based on web code: const tournamentData = item.data || item;
          final tournamentData = (item is Map && item.containsKey('data'))
              ? item['data']
              : item;

          // Helper to safely get values from either the top level or nested data
          // Web code uses: item.id for ID, but tournamentData.name for name
          final id = item['id'];

          // Map fields manually to match TournamentModel structure if keys differ
          // Web: name, startDate, time, director_name, note, numberOfParticipants, categories
          // App Model expects: name, start_date, reg_deadline, etc.

          return TournamentModel(
            id: _parseInt(id) ?? 0,
            name: tournamentData['name'] ?? '',
            startDate: _parseDate(
              tournamentData['startDate'] ?? tournamentData['start_date'],
            ),
            regDeadline: _parseDate(
              tournamentData['regDeadline'] ?? tournamentData['reg_deadline'],
            ), // Fallback empty if missing
            address:
                'Strike Zone Bowling Center', // Hardcoded in Web currently, can use item['center_id'] logic later
            lat: null, // Web doesn't seem to use this from API yet
            long: null,
            regFee: _parseDouble(
              tournamentData['entryFee'] ?? tournamentData['reg_fee'],
            ),
            accessType: tournamentData['accessType'] ?? 'public',
            format: tournamentData['format'] ?? 'Standard',
            alreadyEnrolled:
                0, // Not explicitly in Web list parsing, might need separate check or it's false
            participantsCount: _parseInt(
              tournamentData['numberOfParticipants'] ??
                  tournamentData['participants_count'],
            ),
            description:
                tournamentData['note'] ?? tournamentData['description'],
            status: 'draft', // Web defaults to 'draft'
            tournamentType: 'Handicap', // Default
            average: null,
            percentage: null,
            // Note: 'is_published' from item.is_published is available but not in current App Model constructor directly as a named parameter distinct from status/etc?
            // The Model has 'status', we can use that.
          );
        }).toList();

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

  // Helper method to safely parse date
  static String _parseDate(dynamic value) {
    if (value == null || value.toString().isEmpty) {
      // Return current date as fallback to prevent parsing errors
      return DateTime.now().toIso8601String();
    }
    return value.toString();
  }

  // Helper method to safely parse double from various types
  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
  }

  // Helper method to safely parse int from various types
  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      return int.tryParse(value);
    }
    return null;
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
