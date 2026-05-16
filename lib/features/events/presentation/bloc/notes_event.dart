part of 'notes_bloc.dart';

sealed class NotesEvent extends Equatable {
  const NotesEvent();
  @override
  List<Object?> get props => const [];
}

class NotesLoadRequested extends NotesEvent {
  const NotesLoadRequested({this.force = false});
  final bool force;
  @override
  List<Object?> get props => [force];
}

class NotesRefreshRequested extends NotesEvent {
  const NotesRefreshRequested();
}

class NotesNextPageRequested extends NotesEvent {
  const NotesNextPageRequested();
}

/// User submitted the composer at the bottom of the sheet.
class NotesNoteSubmitted extends NotesEvent {
  const NotesNoteSubmitted(this.content);
  final String content;
  @override
  List<Object?> get props => [content];
}

/// Event creator replied to a specific note. Backend rejects this for
/// non-creators — the UI hides the reply affordance accordingly.
class NotesReplySubmitted extends NotesEvent {
  const NotesReplySubmitted({required this.noteId, required this.content});
  final int noteId;
  final String content;
  @override
  List<Object?> get props => [noteId, content];
}

/// Delete one note. Backend allows author OR event creator.
class NotesNoteDeleted extends NotesEvent {
  const NotesNoteDeleted(this.noteId);
  final int noteId;
  @override
  List<Object?> get props => [noteId];
}
