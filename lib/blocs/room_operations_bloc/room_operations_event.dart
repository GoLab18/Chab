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
  final String? name;
  final String? imagePath;
  final List<String> newMembersIds;

  const CreateGroupChatRoom(this.name, this.imagePath, this.newMembersIds);

  @override
  List<Object> get props => [newMembersIds];
}

final class UpdateChatRoom extends RoomOperationsEvent {
  final Room updatedRoom;

  const UpdateChatRoom(this.updatedRoom);

  @override
  List<Object> get props => [updatedRoom];
}

final class UploadRoomPicture extends RoomOperationsEvent {
  final String roomId;
  final String imagePath;

  const UploadRoomPicture(this.roomId, this.imagePath);

  @override
  List<Object> get props => [roomId, imagePath];
}

final class DeleteChatRoom extends RoomOperationsEvent {
  final String roomId;

  const DeleteChatRoom(this.roomId);

  @override
  List<Object> get props => [roomId];
}
