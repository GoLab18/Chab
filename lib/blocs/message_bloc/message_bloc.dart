import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:room_repository/room_repository.dart';

part 'message_event.dart';
part 'message_state.dart';

class MessageBloc extends Bloc<MessageEvent, MessageState> {
  final FirebaseRoomRepository roomRepository;
  MessageBloc({
    required this.roomRepository
  }) : super(const MessageState.loading()) {

    on<AddMessage>((event, emit) async {
      try {
        await roomRepository.addMessage(
          event.roomId,
          event.message
        );

        emit(const MessageState.success());
      } catch (e) {
        emit(const MessageState.failure());
      }
    });

    on<UpdateMessage>((event, emit) async {
      try {
        await roomRepository.updateMessage(
          event.roomId,
          event.updatedMessage
        );

        emit(const MessageState.success());
      } catch (e) {
        emit(const MessageState.failure());
      }
    });

    on<DeleteMessage>((event, emit) async {
      try {
        await roomRepository.deleteMessage(
          event.roomId,
          event.messageId
        );

        emit(const MessageState.success());
      } catch (e) {
        emit(const MessageState.failure());
      }
    });
  }
}
