import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io' show Platform;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:injectable/injectable.dart';

import '../../features/notifications/data/datasources/notifications_remote_datasource.dart';

/// Bridges Firebase Cloud Messaging with the backend's device-token registry.
///
/// Lifecycle:
///   • [registerCurrentDevice] — call after every successful auth (login,
///     signup-complete, session restore). Idempotent; safe to call repeatedly.
///   • [unregisterCurrentDevice] — call BEFORE clearing the auth token at
///     logout. After the token is gone the request would 401.
///
/// Resilience: if Firebase has no platform config yet (no
/// `google-services.json` / `GoogleService-Info.plist`), every method is a
/// silent no-op. The app keeps running; push notifications just won't fire
/// until the config files are dropped in.
@lazySingleton
class DeviceTokenService {
  DeviceTokenService(this._datasource);

  final NotificationsRemoteDatasource _datasource;

  String? _cachedToken;
  StreamSubscription<String>? _refreshSub;

  Future<void> registerCurrentDevice() async {
    final token = await _safelyFetchToken();
    if (token == null) return;
    _cachedToken = token;
    await _postRegister(token);
    _listenForRefresh();
  }

  Future<void> unregisterCurrentDevice() async {
    final token = _cachedToken;
    await _refreshSub?.cancel();
    _refreshSub = null;
    _cachedToken = null;
    if (token == null) return;
    try {
      await _datasource.unregisterDevice({'token': token});
    } catch (e) {
      developer.log(
        'DeviceTokenService: unregister failed (non-fatal): $e',
        name: 'fcm',
      );
    }
  }

  // ── internals ──────────────────────────────────────────────────────────────

  Future<String?> _safelyFetchToken() async {
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp();
      }
      // iOS needs explicit permission; Android auto-grants on supported APIs.
      await FirebaseMessaging.instance.requestPermission();
      return await FirebaseMessaging.instance.getToken();
    } catch (e) {
      // No google-services.json / GoogleService-Info.plist yet, or user
      // denied notifications. Don't crash auth flows over this.
      developer.log(
        'DeviceTokenService: FCM unavailable, skipping device register: $e',
        name: 'fcm',
      );
      return null;
    }
  }

  Future<void> _postRegister(String token) async {
    final platform = Platform.isIOS ? 'ios' : 'android';
    try {
      await _datasource.registerDevice({
        'token': token,
        'platform': platform,
      });
    } catch (e) {
      developer.log(
        'DeviceTokenService: register failed (non-fatal): $e',
        name: 'fcm',
      );
    }
  }

  void _listenForRefresh() {
    _refreshSub?.cancel();
    try {
      _refreshSub = FirebaseMessaging.instance.onTokenRefresh.listen(
        (newToken) async {
          _cachedToken = newToken;
          await _postRegister(newToken);
        },
      );
    } catch (_) {
      // onTokenRefresh can throw if Firebase isn't initialised — ignore.
    }
  }
}
