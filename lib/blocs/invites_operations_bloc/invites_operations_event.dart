part of 'invites_operations_bloc.dart';

sealed class InvitesOperationsEvent {
  const InvitesOperationsEvent();
}

final class AddInvite extends InvitesOperationsEvent {
  final Invite newInvite;
  const AddInvite(this.newInvite);
}

final class UpdateInviteStatus extends InvitesOperationsEvent {
  final String inviteId;
  final InviteStatus newStatus;
  final String? fromUserId; // Used only for accepted invites

  const UpdateInviteStatus({
    required this.inviteId,
    required this.newStatus,
    this.fromUserId
  });
}

final class DeleteInvite extends InvitesOperationsEvent {
  final String inviteId;

  const DeleteInvite(this.inviteId);
}
