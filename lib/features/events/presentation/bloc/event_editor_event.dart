part of 'event_editor_bloc.dart';

/// Whether the editor's location section is targeting a registered
/// bowling center vs. a custom geocoded address.
enum EventLocationMode { center, custom }

sealed class EventEditorEvent extends Equatable {
  const EventEditorEvent();
  @override
  List<Object?> get props => const [];
}

class EventEditorLoadTypes extends EventEditorEvent {
  const EventEditorLoadTypes();
}

class EventEditorTypesLoaded extends EventEditorEvent {
  const EventEditorTypesLoaded(this.types);
  final List<EventType> types;
  @override
  List<Object?> get props => [types];
}

class EventEditorTypeChanged extends EventEditorEvent {
  const EventEditorTypeChanged(this.typeId);
  final int typeId;
  @override
  List<Object?> get props => [typeId];
}

class EventEditorDateChanged extends EventEditorEvent {
  const EventEditorDateChanged(this.date);
  final DateTime date;
  @override
  List<Object?> get props => [date];
}

class EventEditorOnlineToggled extends EventEditorEvent {
  const EventEditorOnlineToggled(this.isOnline);
  final bool isOnline;
  @override
  List<Object?> get props => [isOnline];
}

class EventEditorLocationModeChanged extends EventEditorEvent {
  const EventEditorLocationModeChanged(this.mode);
  final EventLocationMode mode;
  @override
  List<Object?> get props => [mode];
}

class EventEditorCenterSelected extends EventEditorEvent {
  const EventEditorCenterSelected({required this.id, required this.label});
  final int id;
  final String label;
  @override
  List<Object?> get props => [id, label];
}

class EventEditorAddressSelected extends EventEditorEvent {
  const EventEditorAddressSelected({
    required this.address,
    required this.latitude,
    required this.longitude,
    this.zipcode,
  });
  final String address;
  final double latitude;
  final double longitude;
  final String? zipcode;
  @override
  List<Object?> get props => [address, latitude, longitude, zipcode];
}

/// Title / description / flyer URL live on the screen's controllers,
/// so the submit event carries them in.
class EventEditorSubmitRequested extends EventEditorEvent {
  const EventEditorSubmitRequested({
    required this.title,
    required this.description,
    required this.flyerUrl,
  });
  final String title;
  final String description;
  final String flyerUrl;
  @override
  List<Object?> get props => [title, description, flyerUrl];
}
