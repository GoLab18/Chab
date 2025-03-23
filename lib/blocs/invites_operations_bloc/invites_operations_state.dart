part of 'invites_operations_bloc.dart';

enum InviteOperationStatus {
  success,
  loading,
  failure
}

final class InvitesOperationsState {
  final InviteOperationStatus opStatus;
  final InviteStatus? invStatus; // Is null when the status is not the focal point of the operation
  final String? fromUserId; // Non-null on accepted invites

  const InvitesOperationsState({
    this.opStatus = InviteOperationStatus.loading,
    this.invStatus = InviteStatus.pending,
    this.fromUserId
  });

  const InvitesOperationsState.loading() : this();

  const InvitesOperationsState.success([InviteStatus? invStatus, String? fromUserId]) : this(
    opStatus: InviteOperationStatus.success,
    invStatus: invStatus,
    fromUserId: fromUserId
  );

  const InvitesOperationsState.failure() : this(opStatus: InviteOperationStatus.failure);
}
