part of 'room_members_bloc.dart';

enum ChatRoomMembersStatus {
  success,
  loading,
  failure
}

final class RoomMembersState {
  final Stream<List<Usr>>? roomMembersStream;
  final ChatRoomMembersStatus status;

  const RoomMembersState({
    this.roomMembersStream,
    this.status = ChatRoomMembersStatus.loading
  });

  const RoomMembersState.loading() : this();

  const RoomMembersState.success(Stream<List<Usr>> roomMembersStream) : this(
    roomMembersStream: roomMembersStream,
    status: ChatRoomMembersStatus.success
  );

  const RoomMembersState.failure() : this(status: ChatRoomMembersStatus.failure);
}
