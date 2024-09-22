import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:room_repository/room_repository.dart';

part 'room_event.dart';
part 'room_state.dart';

class RoomBloc extends Bloc<RoomEvent, RoomState> {
  final FirebaseRoomRepository roomRepository;

  RoomBloc({
    required this.roomRepository
  }) : super(const RoomState.loading()) {
    on<RoomWithMessagesRequested>((event, emit) async {
      try {
        ChatRoomTuple roomTuple = await roomRepository.getRoomWithMessages(event.roomId);
        
        emit(RoomState.success(roomTuple));
      } catch (e) {
        emit(const RoomState.failure());
      }
    });

    on<CreatePrivateChatRoom>((event, emit) async {
      try {
        String roomId = await roomRepository.createRoom(true);

        await roomRepository.addMembersToRoom(false ,roomId, [event.personOneId, event.personTwoId]);
        
        emit(const RoomState.success(null));
      } catch (e) {
        emit(const RoomState.failure());
      }
    });

    on<CreateGroupChatRoom>((event, emit) async {
      try {
        String roomId = await roomRepository.createRoom(false);

        await roomRepository.addMembersToRoom(true, roomId, event.newMembersIds);
        
        emit(const RoomState.success(null));
      } catch (e) {
        emit(const RoomState.failure());
      }
    });
  }
}
