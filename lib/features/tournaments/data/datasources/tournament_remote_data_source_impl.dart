import 'package:dio/dio.dart';
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
      print(
        '🏆 TournamentDataSource: Fetching tournaments from /api/tournaments',
      );

      final response = await _dio.get(
        '/api/tournaments',
        options: _getOptionsWithAuth(),
      );

      print('🏆 TournamentDataSource: Response status: ${response.statusCode}');
      print('🏆 TournamentDataSource: Response data: ${response.data}');

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
      print('🏆 TournamentDataSource: Dio error: ${e.message}');
      if (e.response != null) {
        print('🏆 TournamentDataSource: Error response: ${e.response?.data}');
        throw Exception(
          'Failed to load tournaments: ${e.response?.statusCode} - ${e.response?.data}',
        );
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      print('🏆 TournamentDataSource: Unexpected error: $e');
      throw Exception('Failed to load tournaments: $e');
    }
  }

  @override
  Future<Tournament> getTournamentById(int id) async {
    try {
      print('🏆 TournamentDataSource: Fetching tournament $id');

      // For now, get all tournaments and find the one we need
      // In a real API, this would be GET /api/tournaments/$id
      final tournaments = await getTournaments();
      final tournament = tournaments.firstWhere(
        (t) => t.id == id,
        orElse: () => throw Exception('Tournament not found'),
      );

      return tournament;
    } catch (e) {
      print('🏆 TournamentDataSource: Error fetching tournament $id: $e');
      rethrow;
    }
  }

  @override
  Future<void> registerForTournament(int tournamentId) async {
    try {
      print(
        '🏆 TournamentDataSource: Registering for tournament $tournamentId',
      );

      final response = await _dio.post(
        '/api/tournaments/$tournamentId/register',
        options: _getOptionsWithAuth(),
      );

      print(
        '🏆 TournamentDataSource: Registration response: ${response.statusCode}',
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to register: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('🏆 TournamentDataSource: Registration error: ${e.message}');
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
      print(
        '🏆 TournamentDataSource: Unregistering from tournament $tournamentId',
      );

      final response = await _dio.delete(
        '/api/tournaments/$tournamentId/register',
        options: _getOptionsWithAuth(),
      );

      print(
        '🏆 TournamentDataSource: Unregistration response: ${response.statusCode}',
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to unregister: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('🏆 TournamentDataSource: Unregistration error: ${e.message}');
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
    required String format,
    required int participantsCount,
    required String accessType,
  }) async {
    try {
      print('🏆 TournamentDataSource: Creating tournament: $name');

      final data = {
        'name': name,
        'start_date': startDate,
        'reg_deadline': regDeadline,
        'reg_fee': regFee,
        'address': address,
        'format': format,
        'participants_count': participantsCount,
        'access_type': accessType,
      };

      final response = await _dio.post(
        '/api/tournaments',
        data: data,
        options: _getOptionsWithAuth(),
      );

      print('🏆 TournamentDataSource: Create response: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final tournamentModel = TournamentModel.fromJson(
          response.data as Map<String, dynamic>,
        );
        return tournamentModel.toEntity();
      } else {
        throw Exception('Failed to create tournament: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('🏆 TournamentDataSource: Create error: ${e.message}');
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
      print(
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
      print(
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

    print(
      '🏆 TournamentDataSource: Token retrieved: ${token != null ? 'Token exists (${token.length} chars)' : 'No token found'}',
    );

    if (token != null) {
      options.headers = {'Authorization': 'Bearer $token'};
      print('🏆 TournamentDataSource: Added Authorization header');
    }

    return options;
  }
}
