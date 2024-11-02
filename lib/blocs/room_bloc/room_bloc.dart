import 'dart:async';

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
    on<RoomRequested>((event, emit) async {
      try {
        Stream<Room> roomStream = roomRepository.getRoomStream(event.roomId);

        await emit.forEach(
          roomStream,
          onData: (Room room) => RoomState.success(room),
          onError: (_, __) => const RoomState.failure()
        );
      } catch (_) {
        emit(const RoomState.failure());
      }
    });
  }
}
