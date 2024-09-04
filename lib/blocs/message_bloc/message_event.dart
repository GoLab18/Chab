part of 'message_bloc.dart';

sealed class MessageEvent extends Equatable {
  const MessageEvent();

  @override
  List<Object> get props => [];
}

final class AddMessage extends MessageEvent {
  final String roomId;
  final Message message;

  const AddMessage({
    required this.roomId,
    required this.message
  });

  @override
  List<Object> get props => [roomId, message];
}

final class UpdateMessage extends MessageEvent {
  final String roomId;
  final Message updatedMessage;

  const UpdateMessage({
    required this.updatedMessage,
    required this.roomId
  });

  @override
  List<Object> get props => [updatedMessage, roomId];
}

final class DeleteMessage extends MessageEvent {
  final String messageId;
  final String roomId;

  const DeleteMessage({
    required this.messageId,
    required this.roomId
  });

  @override
  List<Object> get props => [messageId, roomId];
}
