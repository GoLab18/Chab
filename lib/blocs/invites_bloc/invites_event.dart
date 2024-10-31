part of 'invites_bloc.dart';

final class InvitesEvent extends Equatable {
  final String userId;

  const InvitesEvent(this.userId);

  @override
  List<Object> get props => [userId];
}
