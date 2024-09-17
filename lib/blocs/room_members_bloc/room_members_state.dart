part of 'room_members_bloc.dart';

enum ChatRoomMembersStatus {
  success,
  loading,
  failure
}

final class RoomMembersState {
  final Stream<Map<String, Usr>>? roomMembersStream;
  final Usr? privateChatRoomFriend;
  final ChatRoomMembersStatus status;

  const RoomMembersState({
    this.roomMembersStream,
    this.privateChatRoomFriend,
    this.status = ChatRoomMembersStatus.loading
  });

  const RoomMembersState.loading() : this();

  const RoomMembersState.success({
    Stream<Map<String, Usr>>? roomMembersStream,
    Usr? privateChatRoomFriend
  }) : this(
    roomMembersStream: roomMembersStream,
    privateChatRoomFriend: privateChatRoomFriend,
    status: ChatRoomMembersStatus.success
  );

  bool get isNull => privateChatRoomFriend == null;

  const RoomMembersState.failure() : this(status: ChatRoomMembersStatus.failure);
}
