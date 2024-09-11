part of 'room_members_bloc.dart';

sealed class RoomMembersEvent extends Equatable {
  const RoomMembersEvent();

  @override
  List<Object> get props => [];
}

final class PrivateChatRoomMembersRequested extends RoomMembersEvent {
  final String roomId;

  const PrivateChatRoomMembersRequested(this.roomId);

  @override
  List<Object> get props => [roomId];
}

final class GroupChatRoomMembersRequested extends RoomMembersEvent {
  final String roomId;

  const GroupChatRoomMembersRequested(this.roomId);

  @override
  List<Object> get props => [roomId];
}
