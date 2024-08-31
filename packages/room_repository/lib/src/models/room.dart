import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

import '../util/typedefs.dart';

/// Class for chat room utility.
/// [lastMessageContent], [lastMessageHasPicture] and [lastMessageTimestamp]
/// are stored for quick lookup.
class Room extends Equatable {
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

  Room({
    required this.lastMessageContent,
    this.lastMessageHasPicture = false,
    Timestamp? lastMessageTimestamp,
    List<String>? members,
    required this.name,
    required this.picture
  }) {
    this.members = members ?? List.empty();
    this.lastMessageTimestamp = lastMessageTimestamp ?? Timestamp.now();
  }
  
  @override
  List<Object?> get props => [lastMessageContent, lastMessageHasPicture, lastMessageTimestamp, members, name, picture];

  static Room empty = Room(
    lastMessageContent: "",
    name: "",
    picture: ""
  );

  /// Getter for checking if the chat room is empty.
  bool get isEmpty => this == Room.empty;

  /// Returns a copy of the chat room with the given values.
  Room copyWith({
    String? lastMessageContent,
    bool? lastMessageHasPicture,
    Timestamp? lastMessageTimestamp,
    List<String>? members,
    String? name,
    String? picture
  }) {
    return Room(
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
      "lastMessageContent": lastMessageContent,
      "lastMessageHasPicture": lastMessageHasPicture,
      "lastMessageTimestamp": lastMessageTimestamp,
      "members": members,
      "name": name,
      "picture": picture
    };
  }
  
  /// Database data deserialization.
  static Room fromDocument(JsonMap doc) {
    return Room(
      lastMessageContent: doc["lastMessageContent"] as String,
      lastMessageHasPicture: doc["lastMessageHasPicture"] as bool,
      lastMessageTimestamp: doc["lastMessageTimestamp"] as Timestamp,
      members: (doc["members"] as List<dynamic>).cast<String>(),
      name: doc["name"] as String,
      picture: doc["picture"] as String
    );
  }
}
