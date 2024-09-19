part of 'received_invites_bloc.dart';

final class ReceivedInvitesEvent extends Equatable {
  final String userId;

  const ReceivedInvitesEvent(this.userId);

  @override
  List<Object> get props => [userId];
}
