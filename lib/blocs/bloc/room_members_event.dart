part of 'room_members_bloc.dart';

sealed class RoomMembersEvent extends Equatable {
  const RoomMembersEvent();

  @override
  List<Object> get props => [];
}

final class PrivateChatRoomMembersRequested extends RoomMembersEvent {
  final String roomId;
  final String currentUserId;

  const PrivateChatRoomMembersRequested({
    required this.roomId,
    required this.currentUserId
  });

  @override
  List<Object> get props => [roomId, currentUserId];
}

final class GroupChatRoomMembersRequested extends RoomMembersEvent {
  final String roomId;

  const GroupChatRoomMembersRequested(this.roomId);

  @override
  List<Object> get props => [roomId];
}
