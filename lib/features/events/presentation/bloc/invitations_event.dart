part of 'invitations_bloc.dart';

sealed class InvitationsEvent extends Equatable {
  const InvitationsEvent();
  @override
  List<Object?> get props => const [];
}

class InvitationsLoadRequested extends InvitationsEvent {
  const InvitationsLoadRequested({this.force = false});
  final bool force;
  @override
  List<Object?> get props => [force];
}

class InvitationsRefreshRequested extends InvitationsEvent {
  const InvitationsRefreshRequested();
}

class InvitationsNextPageRequested extends InvitationsEvent {
  const InvitationsNextPageRequested();
}

/// Accept or decline a single invitation. The bloc applies an
/// optimistic flip + reconciles with the backend's authoritative
/// response.
class InvitationRespondRequested extends InvitationsEvent {
  const InvitationRespondRequested({
    required this.invitationId,
    required this.status,
  });
  final int invitationId;
  final InvitationStatus status;
  @override
  List<Object?> get props => [invitationId, status];
}
