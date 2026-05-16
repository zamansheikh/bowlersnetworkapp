import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/event.dart';
import '../../domain/repositories/events_repository.dart';

part 'notes_event.dart';
part 'notes_state.dart';

/// Drives the Q&A notes sheet for a single event. One bloc per sheet
/// — the [uid] is locked at construction. New notes are prepended on
/// the wire shape's "newest first" order, replies merge in place, and
/// deletes drop the row.
class NotesBloc extends Bloc<NotesEvent, NotesState> {
  NotesBloc({
    required EventsRepository repository,
    required String uid,
  })  : _repository = repository,
        _uid = uid,
        super(const NotesState()) {
    on<NotesLoadRequested>(_onLoad);
    on<NotesRefreshRequested>(_onRefresh);
    on<NotesNextPageRequested>(_onNextPage);
    on<NotesNoteSubmitted>(_onSubmit);
    on<NotesReplySubmitted>(_onReply);
    on<NotesNoteDeleted>(_onDelete);
  }

  final EventsRepository _repository;
  final String _uid;

  Future<void> _onLoad(
    NotesLoadRequested event,
    Emitter<NotesState> emit,
  ) async {
    if (state.notes.isNotEmpty && !event.force) return;
    emit(state.copyWith(loading: true, errors: const []));
    final res = await _repository.getNotes(uid: _uid, page: 1);
    res.fold(
      (f) => emit(state.copyWith(loading: false, errors: f.messages)),
      (page) => emit(state.copyWith(
        loading: false,
        notes: page.notes,
        page: 1,
        hasMore: page.hasMore,
      )),
    );
  }

  Future<void> _onRefresh(
    NotesRefreshRequested event,
    Emitter<NotesState> emit,
  ) async {
    emit(state.copyWith(refreshing: true, errors: const []));
    final res = await _repository.getNotes(uid: _uid, page: 1);
    res.fold(
      (f) => emit(state.copyWith(refreshing: false, errors: f.messages)),
      (page) => emit(state.copyWith(
        refreshing: false,
        notes: page.notes,
        page: 1,
        hasMore: page.hasMore,
      )),
    );
  }

  Future<void> _onNextPage(
    NotesNextPageRequested event,
    Emitter<NotesState> emit,
  ) async {
    if (state.loadingMore || !state.hasMore || state.loading) return;
    emit(state.copyWith(loadingMore: true));
    final next = state.page + 1;
    final res = await _repository.getNotes(uid: _uid, page: next);
    res.fold(
      (f) => emit(state.copyWith(loadingMore: false, errors: f.messages)),
      (page) => emit(state.copyWith(
        loadingMore: false,
        notes: [...state.notes, ...page.notes],
        page: next,
        hasMore: page.hasMore,
      )),
    );
  }

  Future<void> _onSubmit(
    NotesNoteSubmitted event,
    Emitter<NotesState> emit,
  ) async {
    final content = event.content.trim();
    if (content.isEmpty || state.posting) return;
    emit(state.copyWith(posting: true, errors: const []));
    final res = await _repository.createNote(uid: _uid, content: content);
    res.fold(
      (f) => emit(state.copyWith(posting: false, errors: f.messages)),
      (note) => emit(state.copyWith(
        posting: false,
        notes: [note, ...state.notes],
      )),
    );
  }

  Future<void> _onReply(
    NotesReplySubmitted event,
    Emitter<NotesState> emit,
  ) async {
    final content = event.content.trim();
    if (content.isEmpty) return;
    if (state.replyBusyIds.contains(event.noteId)) return;
    emit(state.copyWith(
      replyBusyIds: {...state.replyBusyIds, event.noteId},
      errors: const [],
    ));
    final res = await _repository.replyToNote(
      noteId: event.noteId,
      content: content,
    );
    res.fold(
      (f) => emit(state.copyWith(
        replyBusyIds:
            state.replyBusyIds.where((id) => id != event.noteId).toSet(),
        errors: f.messages,
      )),
      (updated) {
        final idx = state.notes.indexWhere((n) => n.id == event.noteId);
        final nextNotes = List<EventNote>.from(state.notes);
        if (idx != -1) nextNotes[idx] = updated;
        emit(state.copyWith(
          notes: nextNotes,
          replyBusyIds:
              state.replyBusyIds.where((id) => id != event.noteId).toSet(),
        ));
      },
    );
  }

  Future<void> _onDelete(
    NotesNoteDeleted event,
    Emitter<NotesState> emit,
  ) async {
    if (state.deleteBusyIds.contains(event.noteId)) return;
    emit(state.copyWith(
      deleteBusyIds: {...state.deleteBusyIds, event.noteId},
      errors: const [],
    ));
    final res = await _repository.deleteNote(event.noteId);
    res.fold(
      (f) => emit(state.copyWith(
        deleteBusyIds:
            state.deleteBusyIds.where((id) => id != event.noteId).toSet(),
        errors: f.messages,
      )),
      (_) => emit(state.copyWith(
        notes:
            state.notes.where((n) => n.id != event.noteId).toList(growable: false),
        deleteBusyIds:
            state.deleteBusyIds.where((id) => id != event.noteId).toSet(),
      )),
    );
  }
}
