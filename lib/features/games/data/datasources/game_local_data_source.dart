import 'dart:convert';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/bowling_game_model.dart';

abstract class GameLocalDataSource {
  Future<List<BowlingGameModel>> getAllGames();
  Future<void> saveGame(BowlingGameModel game);
  Future<void> updateGame(BowlingGameModel game);
  Future<void> deleteGame(String id);
  Future<BowlingGameModel?> getGameById(String id);
  Future<List<BowlingGameModel>> getPendingGames();
  Future<void> updateGameAfterSync(String localId, String backendId);
  Future<void> markSyncFailed(String gameId, String error);
}

@LazySingleton(as: GameLocalDataSource)
class GameLocalDataSourceImpl implements GameLocalDataSource {
  static const String _gamesKey = 'bowling_games';
  final SharedPreferences _prefs;

  GameLocalDataSourceImpl(this._prefs);

  @override
  Future<List<BowlingGameModel>> getAllGames() async {
    final gamesJson = _prefs.getString(_gamesKey);
    if (gamesJson == null) return [];

    final List<dynamic> gamesList = json.decode(gamesJson);
    return gamesList
        .map((json) => BowlingGameModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> saveGame(BowlingGameModel game) async {
    final games = await getAllGames();

    // Check if game already exists, if so update it
    final existingIndex = games.indexWhere((g) => g.id == game.id);
    if (existingIndex != -1) {
      games[existingIndex] = game;
    } else {
      games.add(game);
    }

    await _saveGames(games);
  }

  @override
  Future<void> updateGame(BowlingGameModel game) async {
    final games = await getAllGames();
    final index = games.indexWhere((g) => g.id == game.id);

    if (index != -1) {
      games[index] = game;
      await _saveGames(games);
    }
  }

  @override
  Future<void> deleteGame(String id) async {
    final games = await getAllGames();
    games.removeWhere((game) => game.id == id);
    await _saveGames(games);
  }

  @override
  Future<BowlingGameModel?> getGameById(String id) async {
    final games = await getAllGames();
    try {
      return games.firstWhere((game) => game.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<BowlingGameModel>> getPendingGames() async {
    final games = await getAllGames();
    return games.where((g) => g.syncStatus == 'pending_sync').toList();
  }

  @override
  Future<void> updateGameAfterSync(String localId, String backendId) async {
    final games = await getAllGames();
    final index = games.indexWhere((g) => g.id == localId);
    if (index != -1) {
      final game = games[index];
      games[index] = BowlingGameModel(
        id: game.id,
        frames: game.frames,
        totalScore: game.totalScore,
        date: game.date,
        isComplete: game.isComplete,
        handPreference: game.handPreference,
        oilPattern: game.oilPattern,
        laneCondition: game.laneCondition,
        gameType: game.gameType,
        laneNumber: game.laneNumber,
        backendId: backendId,
        syncStatus: 'synced',
        syncedAt: DateTime.now(),
        syncError: null,
      );
      await _saveGames(games);
    }
  }

  @override
  Future<void> markSyncFailed(String gameId, String error) async {
    final games = await getAllGames();
    final index = games.indexWhere((g) => g.id == gameId);
    if (index != -1) {
      final game = games[index];
      games[index] = BowlingGameModel(
        id: game.id,
        frames: game.frames,
        totalScore: game.totalScore,
        date: game.date,
        isComplete: game.isComplete,
        handPreference: game.handPreference,
        oilPattern: game.oilPattern,
        laneCondition: game.laneCondition,
        gameType: game.gameType,
        laneNumber: game.laneNumber,
        backendId: game.backendId,
        syncStatus: 'pending_sync',
        syncedAt: game.syncedAt,
        syncError: error,
      );
      await _saveGames(games);
    }
  }

  Future<void> _saveGames(List<BowlingGameModel> games) async {
    final gamesJson = json.encode(games.map((g) => g.toJson()).toList());
    await _prefs.setString(_gamesKey, gamesJson);
  }
}
