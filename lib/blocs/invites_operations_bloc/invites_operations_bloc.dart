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
        userRepository.handleInviteStatusUpdate(event.inviteId, event.newStatus, event.toUser, event.fromUser);

        emit(InvitesOperationsState.success(
          event.newStatus,
          event.newStatus == InviteStatus.accepted ? event.fromUser! : null
        ));
      } catch (e) {
        emit(const InvitesOperationsState.failure());
      }
    });

    on<DeleteInvite>((event, emit) {
      try {
        userRepository.deleteInvite(event.inviteId, event.isInviteTransformedToFriendship);

        emit(const InvitesOperationsState.success(null, null));
      } catch (e) {
        emit(const InvitesOperationsState.failure());
      }
    });

    on<AddInvite>((event, emit) {
      try {
        userRepository.addInvite(event.invite);

        emit(InvitesOperationsState.success(InviteStatus.pending));
      } catch (e) {
        emit(const InvitesOperationsState.failure());
      }
    });
  }
}
