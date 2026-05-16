import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:injectable/injectable.dart';

/// Wraps Google Play's in-app update API. Android-only — `checkAndPrompt`
/// no-ops on iOS / desktop so callers don't need a platform check.
///
/// Flow used here:
///   1. `checkForUpdate()` to ask Play whether a new version is available.
///   2. If yes, start a **flexible** update — the download happens in the
///      background while the user keeps using the app.
///   3. Once the download completes, call `completeFlexibleUpdate()` to
///      prompt the user to install + restart.
///
/// The service swallows all errors silently — an update check should
/// never crash or interrupt the app. Failures (Play store unavailable,
/// debug build, sideloaded APK, etc.) are logged in debug only.
@lazySingleton
class AppUpdateService {
  bool _checkRunning = false;
  bool _installPromptScheduled = false;

  /// Run the full check-then-install pipeline. Safe to call multiple
  /// times — re-entries while a check is in flight are dropped.
  Future<void> checkAndPrompt() async {
    if (!Platform.isAndroid) return;
    if (_checkRunning) return;
    _checkRunning = true;
    try {
      final info = await InAppUpdate.checkForUpdate();
      if (info.updateAvailability != UpdateAvailability.updateAvailable) {
        return;
      }
      if (info.flexibleUpdateAllowed) {
        await _runFlexible();
      } else if (info.immediateUpdateAllowed) {
        // Immediate updates take over the UI with a full-screen Play
        // overlay; fine for must-have updates but most apps prefer
        // flexible. Only fire it when Play explicitly disallows
        // flexible (which is rare; usually means priority >= 5).
        await InAppUpdate.performImmediateUpdate();
      }
    } catch (e, stack) {
      if (kDebugMode) {
        debugPrint('[AppUpdateService] check failed: $e\n$stack');
      }
    } finally {
      _checkRunning = false;
    }
  }

  Future<void> _runFlexible() async {
    final result = await InAppUpdate.startFlexibleUpdate();
    // `result` reports whether the download succeeded; only prompt the
    // install when it did. We only schedule one install prompt per app
    // run so reopening the app doesn't keep nagging.
    if (result == AppUpdateResult.success && !_installPromptScheduled) {
      _installPromptScheduled = true;
      await InAppUpdate.completeFlexibleUpdate();
    }
  }
}
