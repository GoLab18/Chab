import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:user_repository/user_repository.dart';

part 'invites_operations_event.dart';
part 'invites_operations_state.dart';

class InvitesOperationsBloc extends Bloc<InvitesOperationsEvent, InvitesOperationsState> {
  final FirebaseUserRepository userRepository;

  InvitesOperationsBloc({
    required this.userRepository
  }) : super(const InvitesOperationsState.loading()) {
    on<UpdateInviteStatus>((event, emit) {
      try {
        userRepository.updateInviteStatus(event.inviteId, event.newStatus);

        emit(const InvitesOperationsState.success());
      } catch (e) {
        emit(const InvitesOperationsState.failure());
      }
    });
  }
}
