import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

import '../util/typedefs.dart';

class Message extends Equatable {
  final String id;
  
  /// Message content.
  final String content;

  /// Flag for prompting other users if the message was edited.
  final bool edited;

  /// Message picture.
  /// Is empty if there is no picture attached.
  final String picture;

  /// Id of the user that sent the message to the chat room.
  final String senderId;

  /// Message creation date.
  /// Isn't overriden on edit.
  late final Timestamp timestamp;

  Message({
    required this.id,
    required this.content,
    this.edited = false,
    this.picture = "",
    required this.senderId,
    Timestamp? timestamp
  }) {
    this.timestamp = timestamp ?? Timestamp.now();
  }
  
  @override
  List<Object?> get props => [id, content, edited, picture, senderId, timestamp];

  static Message empty = Message(
    id: "",
    content: "",
    senderId: ""
  );

  /// Getter for checking if the message is empty.
  bool get isEmpty => this == Message.empty;

  /// Returns a copy of the message with the given values.
  Message copyWith({
    String? id,
    String? content,
    bool? edited,
    String? picture,
    List<String>? seenBy,
    String? senderId
  }) {
    return Message(
      id: id ?? this.id,
      content: content ?? this.content,
      edited: edited ?? this.edited,
      picture: picture ?? this.picture,
      senderId: senderId ?? this.senderId
    );
  }
  
  /// Data serialization for database storage.
  JsonMap toDocument() {
    return {
      "id": id,
      "content": content,
      "edited": edited,
      "picture": picture,
      "senderId": senderId,
      "timestamp": timestamp
    };
  }
  
  /// Database data deserialization.
  static Message fromDocument(JsonMap doc) {
    return Message(
      id: doc["id"] as String,
      content: doc["content"] as String,
      edited: doc["edited"] as bool,
      picture: doc["picture"] as String,
      senderId: doc["senderId"] as String,
      timestamp: doc["timestamp"] as Timestamp
    );
  }

  /// Data serialization for elasticsearch.
  JsonMap toEsObject(String roomId) {
    return {
      "roomId": roomId,
      "id": id,
      "content": content,
      "edited": edited,
      "picture": picture,
      "senderId": senderId,
      "timestamp": timestamp.toDate().toIso8601String()
    };
  }
  
  /// Data deserialization for elasticsearch.
  static Message fromEsObject(JsonMap doc) {
    return Message(
      id: doc["id"] as String,
      content: doc["content"] as String,
      edited: doc["edited"] as bool,
      picture: doc["picture"] as String,
      senderId: doc["senderId"] as String,
      timestamp: Timestamp.fromDate(DateTime.parse(doc["timestamp"] as String))
    );
  }
}
