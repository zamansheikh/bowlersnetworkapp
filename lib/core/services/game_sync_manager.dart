import 'package:connectivity_plus/connectivity_plus.dart' as connectivity;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../features/games/data/datasources/game_local_data_source.dart';
import '../../features/games/data/datasources/game_remote_data_source.dart';

@Singleton()
class GameSyncManager extends ChangeNotifier {
  final GameLocalDataSource _localDataSource;
  final GameRemoteDataSource _remoteDataSource;
  final connectivity.Connectivity _connectivity;

  bool _isSyncing = false;
  String? _lastSyncError;
  DateTime? _lastSyncTime;

  bool get isSyncing => _isSyncing;
  String? get lastSyncError => _lastSyncError;
  DateTime? get lastSyncTime => _lastSyncTime;

  GameSyncManager(
    this._localDataSource,
    this._remoteDataSource,
    this._connectivity,
  ) {
    _listenToConnectivity();
  }

  void _listenToConnectivity() {
    _connectivity.onConnectivityChanged.listen((result) {
      if (result != connectivity.ConnectivityResult.none) {
        // Device came online, trigger sync
        syncPendingGames();
      }
    });
  }

  Future<void> syncPendingGames() async {
    final isOnline = await _isOnline();
    if (!isOnline) {
      _lastSyncError = 'No internet connection';
      notifyListeners();
      return;
    }

    if (_isSyncing) return;

    _isSyncing = true;
    _lastSyncError = null;
    notifyListeners();

    try {
      // Get all pending games from local storage
      final pendingGames = await _localDataSource.getPendingGames();
      if (pendingGames.isEmpty) {
        _lastSyncTime = DateTime.now();
        _isSyncing = false;
        notifyListeners();
        return;
      }

      // Create sync items for bulk sync
      final syncItems = pendingGames.map((game) {
        return SyncItem(
          localId: game.id,
          backendId: game.backendId,
          operation: 'create', // Assuming all pending are creates for now
          data: game.toJson(),
        );
      }).toList();

      // Perform bulk sync
      final result = await _remoteDataSource.syncBulk(syncItems);

      // Update local storage with results
      int successCount = 0;
      for (final item in result.results) {
        if (item.success) {
          if (item.operation == 'delete') {
            await _localDataSource.deleteGame(item.localId);
          } else if (item.backendId != null) {
            await _localDataSource.updateGameAfterSync(
              item.localId,
              item.backendId!,
            );
            successCount++;
          }
        } else {
          // Mark as failed
          await _localDataSource.markSyncFailed(
            item.localId,
            item.error ?? 'Unknown error',
          );
        }
      }

      _lastSyncTime = DateTime.now();
      _lastSyncError = null;

      if (successCount > 0) {
        Fluttertoast.showToast(
          msg: 'Synced $successCount game(s) 🎳',
          backgroundColor: const Color.fromARGB(255, 139, 195, 66),
        );
      }
    } catch (e) {
      _lastSyncError = e.toString().replaceAll('Exception: ', '');
      Fluttertoast.showToast(
        msg: 'Sync failed: $_lastSyncError',
        backgroundColor: const Color.fromARGB(255, 239, 68, 68),
        toastLength: Toast.LENGTH_LONG,
      );
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  Future<bool> _isOnline() async {
    final result = await _connectivity.checkConnectivity();
    return result.contains(connectivity.ConnectivityResult.mobile) ||
        result.contains(connectivity.ConnectivityResult.wifi);
  }

  Future<bool> get isOnline async => _isOnline();
}
