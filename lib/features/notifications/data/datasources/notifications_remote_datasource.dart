import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../core/constants/api_constants.dart';
import '../models/notification_preferences_dto.dart';

part 'notifications_remote_datasource.g.dart';

/// Backend wants `{token, platform}` for register and `{token}` for
/// unregister. Both endpoints respond `{message: "..."}` — no DTO needed.
@injectable
@RestApi()
abstract class NotificationsRemoteDatasource {
  @factoryMethod
  factory NotificationsRemoteDatasource(Dio dio) =
      _NotificationsRemoteDatasource;

  @POST(Endpoints.registerDevice)
  Future<void> registerDevice(@Body() Map<String, dynamic> body);

  @POST(Endpoints.unregisterDevice)
  Future<void> unregisterDevice(@Body() Map<String, dynamic> body);

  @GET(Endpoints.notificationPreferences)
  Future<NotificationPreferencesDto> getPreferences();

  /// Partial update — any subset of the 9 boolean keys.
  @PATCH(Endpoints.notificationPreferences)
  Future<NotificationPreferencesDto> updatePreferences(
    @Body() Map<String, dynamic> body,
  );
}
