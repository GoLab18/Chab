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

  /// A representation of firebase array.
  /// Holds a [List] of chat room's members' ids.
  late final List<String> members;

  /// Chat room's name.
  final String name;

  /// Chat room's picture.
  final String picture;

  /// Room creation date.
  /// Isn't overriden on edit.
  late final Timestamp timestamp;

  Room({
    required this.id,
    this.isPrivate = true,
    required this.lastMessageContent,
    this.lastMessageHasPicture = false,
    Timestamp? lastMessageTimestamp,
    List<String>? members,
    required this.name,
    required this.picture,
    Timestamp? timestamp
  }) {
    this.members = members ?? List.empty();
    this.lastMessageTimestamp = lastMessageTimestamp ?? Timestamp.now();
    this.timestamp = timestamp ?? Timestamp.now();
  }
  
  @override
  List<Object?> get props => [id, isPrivate, lastMessageContent, lastMessageHasPicture, lastMessageTimestamp, members, name, picture, timestamp];

  static Room empty = Room(
    id: "",
    lastMessageContent: "",
    name: "",
    picture: ""
  );

  /// Getter for checking if the chat room is empty.
  bool get isEmpty => this == Room.empty;

  /// Returns a copy of the chat room with the given values.
  Room copyWith({
    String? id,
    bool? isPrivate,
    String? lastMessageContent,
    bool? lastMessageHasPicture,
    Timestamp? lastMessageTimestamp,
    List<String>? members,
    String? name,
    String? picture
  }) {
    return Room(
      id: id ?? this.id,
      isPrivate: isPrivate ?? this.isPrivate,
      lastMessageContent: lastMessageContent ?? this.lastMessageContent,
      lastMessageHasPicture: lastMessageHasPicture ?? this.lastMessageHasPicture,
      lastMessageTimestamp: lastMessageTimestamp ?? this.lastMessageTimestamp,
      members: members ?? this.members,
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
      "members": members,
      "name": name,
      "picture": picture,
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
      lastMessageTimestamp: doc["lastMessageTimestamp"] as Timestamp,
      members: (doc["members"] as List<dynamic>).cast<String>(),
      name: doc["name"] as String,
      picture: doc["picture"] as String,
      timestamp: doc["timestamp"] as Timestamp
    );
  }
}
