import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:user_repository/user_repository.dart';

part 'invites_event.dart';
part 'invites_state.dart';

class InvitesBloc extends Bloc<InvitesEvent, InvitesState> {
  final FirebaseUserRepository userRepository;

  InvitesBloc({
    required this.userRepository
  }) : super(const InvitesState.loading()) {
    on<InvitesEvent>((event, emit) async {
      try {
        Stream<List<(Usr, Invite)>> userFriendInvitesStream = await userRepository.getUserFriendInvites(event.userId);
        Stream<List<(Usr, Invite)>> userIssuedInvitesStream = userRepository.getCurrentUsersIssuedInvites(event.userId);

        emit(InvitesState.success(userFriendInvitesStream, userIssuedInvitesStream));
      } catch (e) {
        emit(const InvitesState.failure());
      }
    });
  }
}
