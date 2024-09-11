import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

import '../util/typedefs.dart';

/// Class for chat room utility.
/// [lastMessageContent], [lastMessageHasPicture] and [lastMessageTimestamp]
/// are stored for quick lookup.
class Room extends Equatable {
  final String id;

  /// Boolean flag that is equal to true, if the chat room is a private 1v1 conversation.
  final bool isPrivate;

  /// Last message content.
  final String lastMessageContent;

  /// Flag for rooms list UI prompting.
  final bool lastMessageHasPicture;

  /// Last message picture.
  late final Timestamp lastMessageTimestamp;

  // Last message sender ID.
  final String lastMessageSenderId;

  /// Chat room's name.
  /// Stays null if it's a private chat.
  final String? name;

  /// Chat room's picture.
  /// Stays null if it's a private chat.
  final String? picture;

  /// Room creation date.
  /// Isn't overriden on edit.
  late final Timestamp timestamp;

  Room({
    required this.id,
    this.isPrivate = true,
    required this.lastMessageContent,
    this.lastMessageHasPicture = false,
    required this.lastMessageSenderId,
    Timestamp? lastMessageTimestamp,
    required this.name,
    required this.picture,
    Timestamp? timestamp
  }) {
    this.lastMessageTimestamp = lastMessageTimestamp ?? Timestamp.now();
    this.timestamp = timestamp ?? Timestamp.now();
  }
  
  @override
  List<Object?> get props => [id, isPrivate, lastMessageContent, lastMessageHasPicture, lastMessageTimestamp, name, picture, timestamp];

  static Room empty = Room(
    id: "",
    lastMessageContent: "",
    lastMessageSenderId: "",
    name: null,
    picture: null
  );

  /// Getter for checking if the chat room is empty.
  bool get isEmpty => this == Room.empty;

  /// Returns a copy of the chat room with the given values.
  Room copyWith({
    String? id,
    bool? isPrivate,
    String? lastMessageContent,
    bool? lastMessageHasPicture,
    String? lastMessageSenderId,
    Timestamp? lastMessageTimestamp,
    String? name,
    String? picture
  }) {
    return Room(
      id: id ?? this.id,
      isPrivate: isPrivate ?? this.isPrivate,
      lastMessageContent: lastMessageContent ?? this.lastMessageContent,
      lastMessageHasPicture: lastMessageHasPicture ?? this.lastMessageHasPicture,
      lastMessageSenderId: lastMessageSenderId ?? this.lastMessageSenderId,
      lastMessageTimestamp: lastMessageTimestamp ?? this.lastMessageTimestamp,
      name: name ?? this.name,
      picture: picture ?? this.picture
    );
  }
  
  /// Data serialization for database storage.
  JsonMap toDocument() {
    return {
      "id": id,
      "isPrivate": isPrivate,
      "lastMessageContent": lastMessageContent,
      "lastMessageHasPicture": lastMessageHasPicture,
      "lastMessageTimestamp": lastMessageTimestamp,
      if (name != null) "name": name,
      if (picture != null) "picture": picture,
      "timestamp": timestamp
    };
  }
  
  /// Database data deserialization.
  static Room fromDocument(JsonMap doc) {
    return Room(
      id: doc["id"] as String,
      isPrivate: doc["isPrivate"] as bool,
      lastMessageContent: doc["lastMessageContent"] as String,
      lastMessageHasPicture: doc["lastMessageHasPicture"] as bool,
      lastMessageSenderId: doc["lastMessageSenderId"] as String,
      lastMessageTimestamp: doc["lastMessageTimestamp"] as Timestamp,
      name: doc["name"] as String?,
      picture: doc["picture"] as String?,
      timestamp: doc["timestamp"] as Timestamp
    );
  }
}
