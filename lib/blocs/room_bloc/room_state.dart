part of 'room_bloc.dart';

enum ChatRoomStatus {
  success,
  loading,
  failure
}

class RoomState {
  final ChatRoomTuple? roomTuple;
  final ChatRoomStatus status;

  const RoomState({
    this.roomTuple,
    this.status = ChatRoomStatus.loading
  });

  const RoomState.loading() : this();

  const RoomState.success(ChatRoomTuple? roomTuple) : this(roomTuple: roomTuple, status: ChatRoomStatus.success);

  const RoomState.failure() : this(status: ChatRoomStatus.failure);
}
