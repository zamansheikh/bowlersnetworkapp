part of 'settings_bloc.dart';

class SettingsState extends Equatable {
  const SettingsState({
    this.loading = false,
    this.preferences,
    this.busyKinds = const {},
    this.errors = const [],
  });

  final bool loading;
  final NotificationPreferences? preferences;

  /// Set of categories whose PATCH is currently in flight — used to
  /// disable just that one toggle while the request flies.
  final Set<NotificationKind> busyKinds;

  final List<String> errors;

  SettingsState copyWith({
    bool? loading,
    NotificationPreferences? preferences,
    Set<NotificationKind>? busyKinds,
    List<String>? errors,
  }) {
    return SettingsState(
      loading: loading ?? this.loading,
      preferences: preferences ?? this.preferences,
      busyKinds: busyKinds ?? this.busyKinds,
      errors: errors ?? this.errors,
    );
  }

  bool isBusy(NotificationKind kind) => busyKinds.contains(kind);

  @override
  List<Object?> get props => [loading, preferences, busyKinds, errors];
}
