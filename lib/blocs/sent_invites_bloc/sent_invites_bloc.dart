import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:user_repository/user_repository.dart';

part 'sent_invites_event.dart';
part 'sent_invites_state.dart';

class SentInvitesBloc extends Bloc<SentInvitesEvent, SentInvitesState> {
  final FirebaseUserRepository userRepository;

  SentInvitesBloc({
    required this.userRepository
  }) : super(const SentInvitesState.loading()) {
    on<SentInvitesEvent>((event, emit) async {
      try {
        Stream<List<(Usr, DateTime)>> currentUsersIssuedInvitesStream = await userRepository.getCurrentUsersIssuedInvites(event.userId);

        emit(SentInvitesState.success(currentUsersIssuedInvitesStream));
      } catch (e) {
        emit(const SentInvitesState.failure());
      }
    });
  }
}
