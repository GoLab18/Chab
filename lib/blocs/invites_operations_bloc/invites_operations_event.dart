part of 'invites_operations_bloc.dart';

sealed class InvitesOperationsEvent {
  const InvitesOperationsEvent();
}

final class AddInvite extends InvitesOperationsEvent {
  final Invite invite; // Without a proper id still, given on db indexing

  const AddInvite(this.invite);
}

final class UpdateInviteStatus extends InvitesOperationsEvent {
  final String inviteId;
  final InviteStatus newStatus;
  final Usr? toUser, fromUser; // Used only for accepted invites to be stored in elasticsearch friendships_invites index

  const UpdateInviteStatus({
    required this.inviteId,
    required this.newStatus,
    this.toUser,
    this.fromUser
  });
}

final class DeleteInvite extends InvitesOperationsEvent {
  final String inviteId;

  const DeleteInvite(this.inviteId);
}
