part of 'rooms_bloc.dart';

sealed class RoomsEvent extends Equatable {
  const RoomsEvent();

  @override
  List<Object> get props => [];
}

final class RoomsDataChangedDone extends RoomsEvent {
  final List<Room> rooms;

  const RoomsDataChangedDone(this.rooms);
  
  @override
  List<Object> get props => [rooms];
}

final class RoomsDataErr extends RoomsEvent {}
