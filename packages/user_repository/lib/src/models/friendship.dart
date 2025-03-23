import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

import '../util/typedefs.dart';

class Friendship extends Equatable {
  /// Friend's id that is the same as document id.
  final String friendId;

  /// Friendship start date.
  /// Isn't overriden on edit.
  late final Timestamp since;

  Friendship({
    required this.friendId,
    Timestamp? since
  }) {
    this.since = since ?? Timestamp.now();
  }

  @override
  List<Object?> get props => [friendId, since];

  static Friendship empty = Friendship(
    friendId: ""
  );

  /// Getter for checking if the friendship is empty.
  bool get isEmpty => this == Friendship.empty;

  /// Returns a copy of the friendship with the given values.
  Friendship copyWith({
    String? friendId
  }) {
    return Friendship(
      friendId: friendId ?? this.friendId
    );
  }
  
  /// Data serialization for database storage.
  JsonMap toDocument() {
    return {
      "friendId": friendId,
      "since": since
    };
  }
  
  /// Database data deserialization.
  static Friendship fromDocument(JsonMap doc) {
    return Friendship(
      friendId: doc["friendId"] as String,
      since: doc["since"] as Timestamp
    );
  }

  /// Data serialization for elasticsearch.
  JsonMap toEsObject() {
    return {
      "friendId": friendId,
      "since": since.toDate().toIso8601String()
    };
  }

  /// Data deserialization for elasticsearch.
  static Friendship fromEsObject(JsonMap doc, String friendId) {
    return Friendship(
      friendId: friendId,
      since: Timestamp.fromDate(DateTime.parse(doc["since"] as String))
    );
  }
}