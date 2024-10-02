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
  }
}
