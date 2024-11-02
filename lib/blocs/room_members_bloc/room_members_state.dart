part of 'room_members_bloc.dart';

enum RoomMembersStatus {
  success,
  loading,
  failure
}

final class RoomMembersState {
  final Map<String, Usr>? groupMembers;
  final Usr? privateChatRoomFriend;
  final RoomMembersStatus status;

  const RoomMembersState({
    this.groupMembers,
    this.privateChatRoomFriend,
    this.status = RoomMembersStatus.loading
  });

  const RoomMembersState.loading() : this();

  const RoomMembersState.success({
    Map<String, Usr>? groupChatMembers,
    Usr? privateChatRoomFriend
  }) : this(
    groupMembers: groupChatMembers,
    privateChatRoomFriend: privateChatRoomFriend,
    status: RoomMembersStatus.success
  );

  const RoomMembersState.failure() : this(status: RoomMembersStatus.failure);
}
