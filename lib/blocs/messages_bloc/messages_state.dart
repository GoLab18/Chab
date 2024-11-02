part of 'messages_bloc.dart';

enum MessagesStatus {
  success,
  loading,
  failure,
  empty
}

class MessagesState {
  final MessagesStatus status;
  final List<Message>? messages;

  const MessagesState({
    this.status = MessagesStatus.loading,
    this.messages
  });

  const MessagesState.loading() : this();

  const MessagesState.success(List<Message> messages) : this(messages: messages, status: MessagesStatus.success);

  const MessagesState.failure() : this(status: MessagesStatus.failure);

  const MessagesState.empty() : this(status: MessagesStatus.empty);
}
