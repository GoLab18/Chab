part of 'received_invites_bloc.dart';

enum ReceivedInvitesStatus {
  success,
  loading,
  failure
}

final class ReceivedInvitesState {
  final Stream<List<(Usr, DateTime)>>? userInvitesStream;
  final ReceivedInvitesStatus status;

  const ReceivedInvitesState({
    this.userInvitesStream,
    this.status = ReceivedInvitesStatus.loading
  });

  const ReceivedInvitesState.loading() : this();

  const ReceivedInvitesState.success(Stream<List<(Usr, DateTime)>> userInvitesStream) : this(
    userInvitesStream: userInvitesStream,
    status: ReceivedInvitesStatus.success
  );

  const ReceivedInvitesState.failure() : this(status: ReceivedInvitesStatus.failure);
}
