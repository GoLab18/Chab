part of 'invites_bloc.dart';

enum InvitesStatus {
  success,
  loading,
  failure
}

final class InvitesState {
  final Stream<List<(Usr, Invite)>>? userFriendInvitesStream;
  final Stream<List<(Usr, Invite)>>? userIssuedInvitesStream;
  final InvitesStatus status;

  const InvitesState({
    this.userFriendInvitesStream,
    this.userIssuedInvitesStream,
    this.status = InvitesStatus.loading
  });

  const InvitesState.loading() : this();

  const InvitesState.success(
    Stream<List<(Usr, Invite)>> userFriendInvitesStream,
    Stream<List<(Usr, Invite)>> userIssuedInvitesStream
  ) : this(
    userFriendInvitesStream: userFriendInvitesStream,
    userIssuedInvitesStream: userIssuedInvitesStream,
    status: InvitesStatus.success
  );

  const InvitesState.failure() : this(status: InvitesStatus.failure);
}
