import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:user_repository/user_repository.dart';

part 'room_members_event.dart';
part 'room_members_state.dart';

class RoomMembersBloc extends Bloc<RoomMembersEvent, RoomMembersState> {
  final FirebaseUserRepository userRepository;

  RoomMembersBloc({
    required this.userRepository
  }) : super(const RoomMembersState.loading()) {
    on<PrivateChatRoomMembersRequested>((event, emit) async {
      try {
        List<String> roomMembersIds = await userRepository.getPrivateChatRoomMembersIds(event.roomId);

        Stream<List<Usr>> roomMembersStream = userRepository.getPrivateChatRoomMembersStream(roomMembersIds);
        
        emit(RoomMembersState.success(roomMembersStream));
      } catch (e) {
        emit(const RoomMembersState.failure());
      }
    });

    on<GroupChatRoomMembersRequested>((event, emit) {
      try {
        Stream<List<Usr>> roomMembersStream = userRepository.getGroupChatRoomMembersStream(event.roomId);
        
        emit(RoomMembersState.success(roomMembersStream));
      } catch (e) {
        emit(const RoomMembersState.failure());
      }
    });
  }
}
