part of 'room_bloc.dart';

enum RoomStatus {
  success,
  loading,
  failure
}

class RoomState {
  final RoomStatus status;
  final Room? room;

  const RoomState({
    this.room,
    this.status = RoomStatus.loading
  });

  const RoomState.loading() : this();

  const RoomState.success(Room room) : this(room: room, status: RoomStatus.success);

  const RoomState.failure() : this(status: RoomStatus.failure);
}
