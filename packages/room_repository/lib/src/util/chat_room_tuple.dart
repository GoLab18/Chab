import '../models/models.dart';

/// Tuple mixing single [Room] with it's [Message]s
class ChatRoomTuple {
  final Room room;
  final List<Message> messages;

  ChatRoomTuple({
    required this.room,
    required this.messages
  });
}
