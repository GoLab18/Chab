part of 'invites_operations_bloc.dart';

enum InviteOperationStatus {
  success,
  loading,
  failure
}

final class InvitesOperationsState {
  final InviteOperationStatus status;

  const InvitesOperationsState({this.status = InviteOperationStatus.loading});

  const InvitesOperationsState.loading() : this();

const InvitesOperationsState.success() : this(status: InviteOperationStatus.success);

  const InvitesOperationsState.failure() : this(status: InviteOperationStatus.failure);
}
