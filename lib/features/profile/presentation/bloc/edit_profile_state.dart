part of 'edit_profile_bloc.dart';

class EditProfileState extends Equatable {
  const EditProfileState({
    this.profile,
    this.busyFields = const {},
    this.errors = const [],
    this.lastSavedField,
    this.savedToken = 0,
  });

  final Profile? profile;

  /// Set of fields whose POST is currently in flight. UI uses this to
  /// show per-section spinners and disable just the active save button.
  final Set<EditableField> busyFields;

  final List<String> errors;

  /// Which section most recently saved (used by the UI to highlight or
  /// toast the confirmation). Reset to `null` after the UI consumes it.
  final EditableField? lastSavedField;

  /// Monotonic counter bumped on every successful save — lets the UI's
  /// `listenWhen` detect "another save just succeeded" even when the
  /// same field saves twice in a row.
  final int savedToken;

  EditProfileState copyWith({
    Profile? profile,
    Set<EditableField>? busyFields,
    List<String>? errors,
    EditableField? lastSavedField,
    int? savedToken,
  }) {
    return EditProfileState(
      profile: profile ?? this.profile,
      busyFields: busyFields ?? this.busyFields,
      errors: errors ?? this.errors,
      lastSavedField: lastSavedField ?? this.lastSavedField,
      savedToken: savedToken ?? this.savedToken,
    );
  }

  bool isSaving(EditableField field) => busyFields.contains(field);

  @override
  List<Object?> get props => [
        profile,
        busyFields,
        errors,
        lastSavedField,
        savedToken,
      ];
}
