import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:room_repository/room_repository.dart';

part 'rooms_event.dart';
part 'rooms_state.dart';

class RoomsBloc extends Bloc<RoomsEvent, RoomsState> {
  final FirebaseRoomRepository roomRepository;

  RoomsBloc({
    required this.roomRepository
  }) : super(const RoomsState.loading()) {
    on<UserRoomsRequested>((event, emit) async {
      try {
        Stream<List<Room>> roomsList = await roomRepository.getUserRooms(event.userId);
        
        emit(RoomsState.success(roomsList));
      } catch (e) {
        emit(const RoomsState.failure());
      }
    });
  }
}
