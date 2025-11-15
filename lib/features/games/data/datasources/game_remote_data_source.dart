import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../models/bowling_game_model.dart';

abstract class GameRemoteDataSource {
  Future<BowlingGameModel> createGame(BowlingGameModel game);
  Future<List<BowlingGameModel>> getAllGames({
    int skip = 0,
    int limit = 20,
    String sortBy = 'date',
    String order = 'desc',
  });
  Future<BowlingGameModel> getGameById(String id);
  Future<BowlingGameModel> updateGame(String id, BowlingGameModel game);
  Future<void> deleteGame(String id);
  Future<SyncResult> syncBulk(List<SyncItem> games);
}

@LazySingleton(as: GameRemoteDataSource)
class GameRemoteDataSourceImpl implements GameRemoteDataSource {
  static const String _baseUrl = 'https://test.bowlersnetwork.com/api';
  final Dio _dio;

  GameRemoteDataSourceImpl(this._dio);

  @override
  Future<BowlingGameModel> createGame(BowlingGameModel game) async {
    try {
      final response = await _dio.post('$_baseUrl/games', data: game.toJson());
      return BowlingGameModel.fromJson(response.data);
    } catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  @override
  Future<List<BowlingGameModel>> getAllGames({
    int skip = 0,
    int limit = 20,
    String sortBy = 'date',
    String order = 'desc',
  }) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/games',
        // queryParameters: {
        //   'skip': skip,
        //   'limit': limit,
        //   'sortBy': sortBy,
        //   'order': order,
        // },
      );
      final List<dynamic> gamesList = response.data['data'] ?? [];
      return gamesList
          .map(
            (json) => BowlingGameModel.fromJson(json as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  @override
  Future<BowlingGameModel> getGameById(String id) async {
    try {
      final response = await _dio.get('$_baseUrl/games/$id');
      return BowlingGameModel.fromJson(response.data);
    } catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  @override
  Future<BowlingGameModel> updateGame(String id, BowlingGameModel game) async {
    try {
      final response = await _dio.put(
        '$_baseUrl/games/$id',
        data: game.toJson(),
      );
      return BowlingGameModel.fromJson(response.data);
    } catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  @override
  Future<void> deleteGame(String id) async {
    try {
      await _dio.delete('$_baseUrl/games/$id');
    } catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  @override
  Future<SyncResult> syncBulk(List<SyncItem> games) async {
    try {
      final response = await _dio.post(
        // '$_baseUrl/games/sync/bulk',
        '$_baseUrl/games',
        data: {'games': games.map((g) => g.toJson()).toList()},
      );
      return SyncResult.fromJson(response.data);
    } catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  void _handleError(dynamic error) {
    if (error is DioException) {
      switch (error.response?.statusCode) {
        case 400:
          throw Exception(
            'Invalid game data: ${error.response?.data['details']}',
          );
        case 401:
          throw Exception('Unauthorized: Please log in again');
        case 404:
          throw Exception('Game not found');
        case 409:
          throw Exception('Game conflict: Data was modified');
        default:
          throw Exception('Network error: ${error.message}');
      }
    }
    throw error;
  }
}

// Models for bulk sync
class SyncItem {
  final String localId;
  final String? backendId;
  final String operation; // create, update, delete
  final Map<String, dynamic>? data;

  SyncItem({
    required this.localId,
    required this.backendId,
    required this.operation,
    this.data,
  });

  Map<String, dynamic> toJson() {
    return {
      'localId': localId,
      'backendId': backendId,
      'operation': operation,
      if (data != null) 'data': data,
    };
  }
}

class SyncResult {
  final List<SyncResultItem> results;
  final int failedCount;
  final int successCount;

  SyncResult({
    required this.results,
    required this.failedCount,
    required this.successCount,
  });

  factory SyncResult.fromJson(Map<String, dynamic> json) {
    return SyncResult(
      results: (json['results'] as List)
          .map((r) => SyncResultItem.fromJson(r as Map<String, dynamic>))
          .toList(),
      failedCount: json['failedCount'] as int,
      successCount: json['successCount'] as int,
    );
  }
}

class SyncResultItem {
  final String localId;
  final bool success;
  final String operation;
  final String? backendId;
  final String? error;
  final int? statusCode;
  final Map<String, dynamic>? data;

  SyncResultItem({
    required this.localId,
    required this.success,
    required this.operation,
    this.backendId,
    this.error,
    this.statusCode,
    this.data,
  });

  factory SyncResultItem.fromJson(Map<String, dynamic> json) {
    return SyncResultItem(
      localId: json['localId'] as String,
      success: json['success'] as bool,
      operation: json['operation'] as String,
      backendId: json['backendId'] as String?,
      error: json['error'] as String?,
      statusCode: json['statusCode'] as int?,
      data: json['data'] as Map<String, dynamic>?,
    );
  }
}
