import '../models/models.dart';

/// Tuple mixing single [Room] with it's [Message]s
class ChatRoomTuple {
  final Room room;
  final Stream<List<Message>> messagesStream;

  ChatRoomTuple({
    required this.room,
    required this.messagesStream
  });
}
