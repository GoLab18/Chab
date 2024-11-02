import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:room_repository/room_repository.dart';

part 'messages_event.dart';
part 'messages_state.dart';

class MessagesBloc extends Bloc<MessagesEvent, MessagesState> {
  final FirebaseRoomRepository roomRepository;
  StreamSubscription<List<Message>>? sub;

  MessagesBloc({
    required this.roomRepository
  }) : super(const MessagesState.loading()) {
    on<MessagesRequested>((event, emit) async {
      try {
        Stream<List<Message>> messagesStream = roomRepository.getMessagesStream(event.roomId);

        await emit.forEach(
          messagesStream,
          onData: (List<Message> messages) {
            if (messages.isEmpty) {
              return const MessagesState.empty();
            }

            return MessagesState.success(messages);
          },
          onError: (_, __) => const MessagesState.failure()
        );
      } catch (_) {
        emit(const MessagesState.failure());
      }
    });
  }
}
