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
