import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:room_repository/room_repository.dart';
import 'package:user_repository/user_repository.dart';

part 'room_operations_event.dart';
part 'room_operations_state.dart';

class RoomOperationsBloc extends Bloc<RoomOperationsEvent, RoomOperationsState> {
  final FirebaseRoomRepository roomRepository;

  RoomOperationsBloc({
    required this.roomRepository
  }) : super(const RoomOperationsState.loading()) {
    on<CreatePrivateChatRoom>((event, emit) async {
      try {
        List<Map<String, dynamic>> privateRoomMembers = [
          event.personOne.toEsObject(true),
          event.personTwo.toEsObject(true)
        ];

        String roomId = await roomRepository.createRoom(true, null, privateRoomMembers);

        await roomRepository.addMembersToRoom(roomId, [event.personOne.id, event.personTwo.id]);
        
        emit(const RoomOperationsState.success());
      } catch (e) {
        emit(const RoomOperationsState.failure());
      }
    });

    on<CreateGroupChatRoom>((event, emit) async {
      try {
        List<Map<String, dynamic>> groupChatRoomMembers = [];
        List<String> membersIds = [];

        for (var m in event.newMembers) {
          groupChatRoomMembers.add(m.toEsObject(true));
          membersIds.add(m.id);
        }

        String roomId = await roomRepository.createRoom(false, event.name);

        await roomRepository.addMembersToRoom(roomId, membersIds, groupChatRoomMembers);

        if (event.imagePath != null) await roomRepository.uploadRoomPicture(roomId, event.imagePath!);
        
        emit(const RoomOperationsState.success());
      } catch (e) {
        emit(const RoomOperationsState.failure());
      }
    });

    on<UpdateChatRoom>((event, emit) async {
      try {
        await roomRepository.updateRoom(event.updatedRoom);
        
        emit(const RoomOperationsState.success());
      } catch (e) {
        emit(const RoomOperationsState.failure());
      }
    });

    on<UploadRoomPicture>((event, emit) async {
      try {
        await roomRepository.uploadRoomPicture(event.roomId, event.imagePath);
        
        emit(const RoomOperationsState.success());
      } catch (e) {
        emit(const RoomOperationsState.failure());
      }
    });

    on<DeleteChatRoom>((event, emit) async {
      try {
        await roomRepository.deleteRoom(event.roomId);
        
        emit(const RoomOperationsState.success());
      } catch (e) {
        emit(const RoomOperationsState.failure());
      }
    });
  }
}
