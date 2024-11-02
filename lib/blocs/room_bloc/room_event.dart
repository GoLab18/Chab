part of 'room_bloc.dart';

sealed class RoomEvent extends Equatable {
  const RoomEvent();

  @override
  List<Object> get props => [];
}

final class RoomRequested extends RoomEvent {
  final String roomId;

  const RoomRequested(this.roomId);
  
  @override
  List<Object> get props => [roomId];
}
