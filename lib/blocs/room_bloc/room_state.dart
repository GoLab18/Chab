part of 'room_bloc.dart';

enum ChatRoomStatus {
  success,
  loading,
  failure
}

class RoomState {
  final ChatRoomTuple? roomTuple;
  final List<Room>? roomsList;
  final ChatRoomStatus status;

  const RoomState({
    this.roomTuple,
    this.roomsList,
    this.status = ChatRoomStatus.loading
  });

  const RoomState.loading() : this();

  const RoomState.success({
    ChatRoomTuple? roomTuple,
    List<Room>? roomsList
  }) : this(roomTuple: roomTuple, roomsList: roomsList, status: ChatRoomStatus.success);

  const RoomState.failure() : this(status: ChatRoomStatus.failure);
}
