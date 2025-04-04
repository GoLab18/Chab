import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:room_repository/room_repository.dart';

part 'rooms_event.dart';
part 'rooms_state.dart';

class RoomsBloc extends Bloc<RoomsEvent, RoomsState> {
  final FirebaseRoomRepository roomRepository;
  late final StreamSubscription<List<Room>> roomsSub;
  late final String userId;

  RoomsBloc({
    required this.roomRepository,
    required this.userId
  }) : super(const RoomsState.loading()) {
    roomsSub = roomRepository.getUserRooms(userId).listen(
      (rooms) async {
        add(RoomsDataChangedDone(rooms));
      },
      onError: (error) {
        add(RoomsDataErr());
      },
    );

    on<RoomsDataChangedDone>((event, emit) {
      emit(RoomsState.success(event.rooms));
    });

    on<RoomsDataErr>((event, emit) {
      emit(RoomsState.failure());
    });
  }

  @override
  Future<void> close() {
    roomsSub.cancel();
    return super.close();
  }
}
