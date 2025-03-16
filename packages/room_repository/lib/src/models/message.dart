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
  final String picture;

  /// A representation of firebase array.
  /// Holds a [List] of user ids that have seen the message.
  late final List<String> seenBy;

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
    List<String>? seenBy,
    required this.senderId,
    Timestamp? timestamp
  }) {
    this.seenBy = seenBy ?? List.empty();
    this.timestamp = timestamp ?? Timestamp.now();
  }
  
  @override
  List<Object?> get props => [id, content, edited, picture, seenBy, senderId, timestamp];

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
      seenBy: seenBy ?? this.seenBy,
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
      "seenBy": seenBy,
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
      seenBy: (doc["seenBy"] as List<dynamic>).cast<String>(),
      senderId: doc["senderId"] as String,
      timestamp: doc["timestamp"] as Timestamp
    );
  }

  /// Data serialization for elasticsearch.
  JsonMap toEsObject() {
    return {
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
