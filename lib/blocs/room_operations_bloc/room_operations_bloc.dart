import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:room_repository/room_repository.dart';

part 'room_operations_event.dart';
part 'room_operations_state.dart';

class RoomOperationsBloc extends Bloc<RoomOperationsEvent, RoomOperationsState> {
  final FirebaseRoomRepository roomRepository;

  RoomOperationsBloc({
    required this.roomRepository
  }) : super(const RoomOperationsState.loading()) {
    on<CreatePrivateChatRoom>((event, emit) async {
      try {
        String roomId = await roomRepository.createRoom(true);

        await roomRepository.addMembersToRoom(false ,roomId, [event.personOneId, event.personTwoId]);
        
        emit(const RoomOperationsState.success());
      } catch (e) {
        emit(const RoomOperationsState.failure());
      }
    });

    on<CreateGroupChatRoom>((event, emit) async {
      try {
        String roomId = await roomRepository.createRoom(false);

        await roomRepository.addMembersToRoom(true, roomId, event.newMembersIds);
        
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
