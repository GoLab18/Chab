part of 'messages_bloc.dart';

sealed class MessagesEvent extends Equatable {
  const MessagesEvent();

  @override
  List<Object> get props => [];
}

final class MessagesRequested extends MessagesEvent {
  final String roomId;

  const MessagesRequested(this.roomId);
  
  @override
  List<Object> get props => [roomId];
}
