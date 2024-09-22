part of 'room_bloc.dart';

sealed class RoomEvent extends Equatable {
  const RoomEvent();

  @override
  List<Object> get props => [];
}

final class RoomWithMessagesRequested extends RoomEvent {
  final String roomId;

  const RoomWithMessagesRequested({
    required this.roomId
  });
  
  @override
  List<Object> get props => [roomId];
}

final class CreatePrivateChatRoom extends RoomEvent {
  final String personOneId;
  final String personTwoId;

  const CreatePrivateChatRoom(this.personOneId, this.personTwoId);

  @override
  List<Object> get props => [personOneId, personTwoId];
}

final class CreateGroupChatRoom extends RoomEvent {
  final List<String> newMembersIds;

  const CreateGroupChatRoom(this.newMembersIds);

  @override
  List<Object> get props => [newMembersIds];
}
