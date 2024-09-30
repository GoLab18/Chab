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
        Stream<Usr> privateChatRoomFriend = await userRepository.getPrivateChatRoomFriend(event.roomId, event.currentUserId);

        emit(RoomMembersState.success(privateChatRoomFriend: privateChatRoomFriend));
      } catch (e) {
        emit(const RoomMembersState.failure());
      }
    });

    on<GroupChatRoomMembersRequested>((event, emit) async {
      try {
        Stream<Map<String, Usr>> roomMembersStream = await userRepository.getGroupChatRoomMembersStream(event.roomId);
        
        emit(RoomMembersState.success(roomMembersStream: roomMembersStream));
      } catch (e) {
        emit(const RoomMembersState.failure());
      }
    });
  }
}
