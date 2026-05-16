import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/event.dart';
import '../../domain/repositories/events_repository.dart';

part 'event_editor_event.dart';
part 'event_editor_state.dart';

/// Drives the create / edit event form. Holds the pick-list state
/// (event types, date, location mode + center, online toggle) so the
/// screen widgets stay simple. Title / description / address / flyer
/// URL controllers live on the screen.
///
/// Pass [existing] when editing — the bloc seeds its state from the
/// event and the submit fires PUT instead of POST.
class EventEditorBloc extends Bloc<EventEditorEvent, EventEditorState> {
  EventEditorBloc({
    required EventsRepository repository,
    Event? existing,
  })  : _repository = repository,
        _existing = existing,
        super(EventEditorState.fromExisting(existing)) {
    on<EventEditorTypesLoaded>(_onTypesLoaded);
    on<EventEditorTypeChanged>(_onTypeChanged);
    on<EventEditorDateChanged>(_onDateChanged);
    on<EventEditorOnlineToggled>(_onOnlineToggled);
    on<EventEditorLocationModeChanged>(_onLocationModeChanged);
    on<EventEditorCenterSelected>(_onCenterSelected);
    on<EventEditorAddressSelected>(_onAddressSelected);
    on<EventEditorSubmitRequested>(_onSubmit);
    on<EventEditorLoadTypes>(_onLoadTypes);
  }

  final EventsRepository _repository;
  final Event? _existing;

  bool get isEdit => _existing != null;

  Future<void> _onLoadTypes(
    EventEditorLoadTypes event,
    Emitter<EventEditorState> emit,
  ) async {
    if (state.types.isNotEmpty) return;
    final res = await _repository.getEventTypes();
    res.fold(
      (_) {/* silent — types just stay empty, picker shows empty list */},
      (types) => add(EventEditorTypesLoaded(types)),
    );
  }

  void _onTypesLoaded(
    EventEditorTypesLoaded event,
    Emitter<EventEditorState> emit,
  ) {
    emit(state.copyWith(types: event.types));
  }

  void _onTypeChanged(
    EventEditorTypeChanged event,
    Emitter<EventEditorState> emit,
  ) {
    emit(state.copyWith(eventTypeId: event.typeId));
  }

  void _onDateChanged(
    EventEditorDateChanged event,
    Emitter<EventEditorState> emit,
  ) {
    emit(state.copyWith(eventDate: event.date));
  }

  void _onOnlineToggled(
    EventEditorOnlineToggled event,
    Emitter<EventEditorState> emit,
  ) {
    emit(state.copyWith(isOnline: event.isOnline));
  }

  void _onLocationModeChanged(
    EventEditorLocationModeChanged event,
    Emitter<EventEditorState> emit,
  ) {
    emit(state.copyWith(
      locationMode: event.mode,
      // Clear the inactive slot so an old pick doesn't accidentally
      // bleed into the submit payload.
      clearCenter: event.mode != EventLocationMode.center,
      clearAddress: event.mode != EventLocationMode.custom,
    ));
  }

  void _onCenterSelected(
    EventEditorCenterSelected event,
    Emitter<EventEditorState> emit,
  ) {
    emit(state.copyWith(
      locationMode: EventLocationMode.center,
      centerId: event.id,
      centerLabel: event.label,
    ));
  }

  void _onAddressSelected(
    EventEditorAddressSelected event,
    Emitter<EventEditorState> emit,
  ) {
    emit(state.copyWith(
      locationMode: EventLocationMode.custom,
      addressLabel: event.address,
      latitude: event.latitude,
      longitude: event.longitude,
      zipcode: event.zipcode,
    ));
  }

  Future<void> _onSubmit(
    EventEditorSubmitRequested event,
    Emitter<EventEditorState> emit,
  ) async {
    final title = event.title.trim();
    final description = event.description.trim();
    final typeId = state.eventTypeId;
    final date = state.eventDate;

    final errs = <String>[];
    if (title.isEmpty) errs.add('Title is required.');
    if (description.isEmpty) errs.add('Description is required.');
    if (typeId == null) errs.add('Pick an event type.');
    if (date == null) errs.add('Pick a date and time.');
    if (date != null && date.isBefore(DateTime.now())) {
      errs.add('Event date must be in the future.');
    }
    if (!state.isOnline) {
      if (state.locationMode == EventLocationMode.center &&
          state.centerId == null) {
        errs.add('Pick a bowling center.');
      }
      if (state.locationMode == EventLocationMode.custom &&
          (state.latitude == null || state.longitude == null)) {
        errs.add('Pick an address.');
      }
    }
    if (errs.isNotEmpty) {
      emit(state.copyWith(errors: errs));
      return;
    }

    emit(state.copyWith(submitting: true, errors: const []));

    final draft = EventEditorDraft(
      title: title,
      description: description,
      eventTypeId: typeId!,
      eventDate: date!,
      flyerUrl: event.flyerUrl.trim().isEmpty ? null : event.flyerUrl.trim(),
      isOnline: state.isOnline,
      centerId: state.isOnline ? null : state.centerId,
      latitude: state.isOnline ||
              state.locationMode != EventLocationMode.custom
          ? null
          : state.latitude,
      longitude: state.isOnline ||
              state.locationMode != EventLocationMode.custom
          ? null
          : state.longitude,
      addressStr:
          (state.isOnline || state.locationMode != EventLocationMode.custom)
              ? null
              : (state.addressLabel.isEmpty ? null : state.addressLabel),
      zipcode: (state.isOnline ||
              state.locationMode != EventLocationMode.custom)
          ? null
          : (state.zipcode == null || state.zipcode!.isEmpty
              ? null
              : state.zipcode),
    );

    final res = isEdit
        ? await _repository.updateEvent(uid: _existing!.uid, draft: draft)
        : await _repository.createEvent(draft);
    res.fold(
      (f) => emit(state.copyWith(submitting: false, errors: f.messages)),
      (saved) => emit(state.copyWith(
        submitting: false,
        saved: saved,
      )),
    );
  }
}
