part of 'message_bloc.dart';

enum MessageStatus {
  success,
  pending,
  failure
}

class MessageState {
  final MessageStatus status;

  const MessageState({
    this.status = MessageStatus.pending
  });

  const MessageState.loading() : this();

  const MessageState.success() : this(status: MessageStatus.success);

  const MessageState.failure() : this(status: MessageStatus.failure);
}
