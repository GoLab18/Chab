import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:user_repository/user_repository.dart';

part 'received_invites_event.dart';
part 'received_invites_state.dart';

class ReceivedInvitesBloc extends Bloc<ReceivedInvitesEvent, ReceivedInvitesState> {
  final FirebaseUserRepository userRepository;

  ReceivedInvitesBloc({
    required this.userRepository
  }) : super(const ReceivedInvitesState.loading()) {
    on<ReceivedInvitesEvent>((event, emit) async {
      try {
        Stream<List<(Usr, Invite)>> userFriendInvitesStream = await userRepository.getUserFriendInvites(event.userId);

        emit(ReceivedInvitesState.success(userFriendInvitesStream));
      } catch (e) {
        emit(const ReceivedInvitesState.failure());
      }
    });
  }
}
