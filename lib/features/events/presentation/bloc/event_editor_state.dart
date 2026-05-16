part of 'event_editor_bloc.dart';

class EventEditorState extends Equatable {
  const EventEditorState({
    this.types = const [],
    this.eventTypeId,
    this.eventDate,
    this.isOnline = false,
    this.locationMode = EventLocationMode.center,
    this.centerId,
    this.centerLabel = '',
    this.addressLabel = '',
    this.latitude,
    this.longitude,
    this.zipcode,
    this.submitting = false,
    this.saved,
    this.errors = const [],
  });

  factory EventEditorState.fromExisting(Event? existing) {
    if (existing == null) return const EventEditorState();
    final loc = existing.location;
    final mode = existing.isOnline
        ? EventLocationMode.center // not shown — but pick a default
        : (loc?.isCenter == true
            ? EventLocationMode.center
            : EventLocationMode.custom);
    return EventEditorState(
      eventTypeId: existing.eventType?.id,
      eventDate: existing.eventDate,
      isOnline: existing.isOnline,
      locationMode: mode,
      centerId: loc?.center?.id,
      centerLabel: loc?.center?.name ?? '',
      addressLabel: loc?.address ?? '',
      latitude: loc?.latitude,
      longitude: loc?.longitude,
      zipcode: loc?.zipCode.isEmpty ?? true ? null : loc?.zipCode,
    );
  }

  final List<EventType> types;
  final int? eventTypeId;
  final DateTime? eventDate;
  final bool isOnline;
  final EventLocationMode locationMode;

  /// Center mode — id + a human-readable label for the chip.
  final int? centerId;
  final String centerLabel;

  /// Custom mode — geocoded address + lat/lng.
  final String addressLabel;
  final double? latitude;
  final double? longitude;
  final String? zipcode;

  final bool submitting;

  /// Non-null after a successful create/update — screen pops back when
  /// it sees this flip.
  final Event? saved;

  final List<String> errors;

  EventEditorState copyWith({
    List<EventType>? types,
    int? eventTypeId,
    DateTime? eventDate,
    bool? isOnline,
    EventLocationMode? locationMode,
    int? centerId,
    String? centerLabel,
    bool clearCenter = false,
    String? addressLabel,
    double? latitude,
    double? longitude,
    String? zipcode,
    bool clearAddress = false,
    bool? submitting,
    Event? saved,
    List<String>? errors,
  }) {
    return EventEditorState(
      types: types ?? this.types,
      eventTypeId: eventTypeId ?? this.eventTypeId,
      eventDate: eventDate ?? this.eventDate,
      isOnline: isOnline ?? this.isOnline,
      locationMode: locationMode ?? this.locationMode,
      centerId: clearCenter ? null : (centerId ?? this.centerId),
      centerLabel: clearCenter ? '' : (centerLabel ?? this.centerLabel),
      addressLabel: clearAddress ? '' : (addressLabel ?? this.addressLabel),
      latitude: clearAddress ? null : (latitude ?? this.latitude),
      longitude: clearAddress ? null : (longitude ?? this.longitude),
      zipcode: clearAddress ? null : (zipcode ?? this.zipcode),
      submitting: submitting ?? this.submitting,
      saved: saved ?? this.saved,
      errors: errors ?? this.errors,
    );
  }

  @override
  List<Object?> get props => [
        types,
        eventTypeId,
        eventDate,
        isOnline,
        locationMode,
        centerId,
        centerLabel,
        addressLabel,
        latitude,
        longitude,
        zipcode,
        submitting,
        saved,
        errors,
      ];
}
