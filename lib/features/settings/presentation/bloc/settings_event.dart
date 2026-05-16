part of 'settings_bloc.dart';

sealed class SettingsEvent extends Equatable {
  const SettingsEvent();
  @override
  List<Object?> get props => const [];
}

class SettingsLoadRequested extends SettingsEvent {
  const SettingsLoadRequested({this.force = false});
  final bool force;
  @override
  List<Object?> get props => [force];
}

class SettingsPreferenceToggled extends SettingsEvent {
  const SettingsPreferenceToggled(this.kind);
  final NotificationKind kind;
  @override
  List<Object?> get props => [kind];
}
