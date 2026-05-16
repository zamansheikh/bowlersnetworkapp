import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../notifications/domain/entities/notification_preferences.dart';
import '../../../notifications/domain/repositories/notifications_repository.dart';

part 'settings_event.dart';
part 'settings_state.dart';

/// Drives the notification-preferences section of the Settings screen.
/// Theme is managed by [ThemeCubit] directly so we don't shadow it here
/// — this bloc only owns the network-backed preferences.
///
/// Each toggle flips optimistically + PATCHes; on failure the prior
/// value is restored and an error is surfaced.
@injectable
class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsBloc(this._repository) : super(const SettingsState()) {
    on<SettingsLoadRequested>(_onLoad);
    on<SettingsPreferenceToggled>(_onToggled);
  }

  final NotificationsRepository _repository;

  Future<void> _onLoad(
    SettingsLoadRequested event,
    Emitter<SettingsState> emit,
  ) async {
    if (state.preferences != null && !event.force) return;
    emit(state.copyWith(loading: true, errors: const []));
    final res = await _repository.getPreferences();
    res.fold(
      (f) => emit(state.copyWith(loading: false, errors: f.messages)),
      (prefs) => emit(state.copyWith(loading: false, preferences: prefs)),
    );
  }

  Future<void> _onToggled(
    SettingsPreferenceToggled event,
    Emitter<SettingsState> emit,
  ) async {
    final current = state.preferences;
    if (current == null) return;
    if (state.busyKinds.contains(event.kind)) return;

    final wasEnabled = current.valueOf(event.kind);
    final optimistic = current.withKind(event.kind, !wasEnabled);
    emit(state.copyWith(
      preferences: optimistic,
      busyKinds: {...state.busyKinds, event.kind},
      errors: const [],
    ));

    final res = await _repository.setPreference(
      kind: event.kind,
      value: !wasEnabled,
    );
    res.fold(
      (f) => emit(state.copyWith(
        // Rollback the flip.
        preferences: current,
        busyKinds: state.busyKinds.where((k) => k != event.kind).toSet(),
        errors: f.messages,
      )),
      (authoritative) => emit(state.copyWith(
        preferences: authoritative,
        busyKinds: state.busyKinds.where((k) => k != event.kind).toSet(),
      )),
    );
  }
}
