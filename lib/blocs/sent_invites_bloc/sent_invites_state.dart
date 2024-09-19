part of 'sent_invites_bloc.dart';

enum SentInvitesStatus {
  success,
  loading,
  failure
}

final class SentInvitesState {
  final Stream<List<(Usr, DateTime)>>? userInvitesStream;
  final SentInvitesStatus status;

  const SentInvitesState({
    this.userInvitesStream,
    this.status = SentInvitesStatus.loading
  });

  const SentInvitesState.loading() : this();

  const SentInvitesState.success(Stream<List<(Usr, DateTime)>> userInvitesStream) : this(
    userInvitesStream: userInvitesStream,
    status: SentInvitesStatus.success
  );

  const SentInvitesState.failure() : this(status: SentInvitesStatus.failure);
}
