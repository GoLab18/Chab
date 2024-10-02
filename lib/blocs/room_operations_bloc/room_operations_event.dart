part of 'room_operations_bloc.dart';

sealed class RoomOperationsEvent extends Equatable {
  const RoomOperationsEvent();

  @override
  List<Object> get props => [];
}

final class CreatePrivateChatRoom extends RoomOperationsEvent {
  final String personOneId;
  final String personTwoId;

  const CreatePrivateChatRoom(this.personOneId, this.personTwoId);

  @override
  List<Object> get props => [personOneId, personTwoId];
}

final class CreateGroupChatRoom extends RoomOperationsEvent {
  final List<String> newMembersIds;

  const CreateGroupChatRoom(this.newMembersIds);

  @override
  List<Object> get props => [newMembersIds];
}

final class DeleteChatRoom extends RoomOperationsEvent {
  final String roomId;

  const DeleteChatRoom(this.roomId);

  @override
  List<Object> get props => [roomId];
}

final class UpdateChatRoom extends RoomOperationsEvent {
  final String roomId;
  final Room updatedRoom;

  const UpdateChatRoom(this.roomId, this.updatedRoom);

  @override
  List<Object> get props => [roomId, updatedRoom];
}
