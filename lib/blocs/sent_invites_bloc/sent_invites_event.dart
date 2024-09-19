part of 'sent_invites_bloc.dart';

final class SentInvitesEvent extends Equatable {
  final String userId;

  const SentInvitesEvent(this.userId);

  @override
  List<Object> get props => [userId];
}
