part of 'rooms_bloc.dart';

sealed class RoomsEvent extends Equatable {
  const RoomsEvent();

  @override
  List<Object> get props => [];
}

final class UserRoomsRequested extends RoomsEvent {
  final String userId;

  const UserRoomsRequested({
    required this.userId
  });
  
  @override
  List<Object> get props => [userId];
}
