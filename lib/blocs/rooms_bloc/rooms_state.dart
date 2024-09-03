part of 'rooms_bloc.dart';

enum RoomsStatus {
  success,
  loading,
  failure
}

class RoomsState {
  final Stream<List<Room>>? roomsList;
  final RoomsStatus status;

  const RoomsState({
    this.roomsList,
    this.status = RoomsStatus.loading
  });

  const RoomsState.loading() : this();

  const RoomsState.success(Stream<List<Room>> roomsList) : this(roomsList: roomsList, status: RoomsStatus.success);

  const RoomsState.failure() : this(status: RoomsStatus.failure);
}
