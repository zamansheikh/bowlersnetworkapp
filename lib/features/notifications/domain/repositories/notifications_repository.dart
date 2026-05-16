import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/notification_preferences.dart';

abstract class NotificationsRepository {
  /// `GET /api/notifications/preferences` — full current snapshot.
  Future<Either<Failure, NotificationPreferences>> getPreferences();

  /// `PATCH /api/notifications/preferences` with a single-key payload.
  /// Returns the new authoritative preferences object so the bloc can
  /// drop its optimistic value.
  Future<Either<Failure, NotificationPreferences>> setPreference({
    required NotificationKind kind,
    required bool value,
  });
}
