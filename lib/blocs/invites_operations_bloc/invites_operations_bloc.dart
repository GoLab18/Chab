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

        emit(InvitesOperationsState.success(
          event.newStatus,
          event.newStatus == InviteStatus.accepted ? event.fromUserId : null
        ));
      } catch (e) {
        emit(const InvitesOperationsState.failure());
      }
    });

    on<DeleteInvite>((event, emit) {
      try {
        userRepository.deleteInvite(event.inviteId);

        emit(const InvitesOperationsState.success(null, null));
      } catch (e) {
        emit(const InvitesOperationsState.failure());
      }
    });
  }
}
