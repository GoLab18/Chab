part of 'room_operations_bloc.dart';

enum RoomOpStatus {
  success,
  loading,
  failure
}

class RoomOperationsState {
  final RoomOpStatus status;

  const RoomOperationsState({this.status = RoomOpStatus.loading});

  const RoomOperationsState.loading() : this();

  const RoomOperationsState.success() : this(status: RoomOpStatus.success);

  const RoomOperationsState.failure() : this(status: RoomOpStatus.failure);
}
