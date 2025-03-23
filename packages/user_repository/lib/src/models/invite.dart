import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

import '../util/typedefs.dart';

class Invite extends Equatable {
  /// Invite Id used for CRUD operations.
  final String id;

  /// Sender Id.
  final String fromUser;

  /// Receiver Id.
  final String toUser;

  /// Status of an invite.
  /// Is of type [InviteStatus].
  late final InviteStatus status;
  
  /// Invite creation date.
  /// Isn't overriden on edit.
  late final Timestamp timestamp;

  Invite({
    required this.id,
    required this.fromUser,
    required this.toUser,
    this.status = InviteStatus.pending,
    Timestamp? timestamp
  }) {
    this.timestamp = timestamp ?? Timestamp.now();
  }

  @override
  List<Object?> get props => [id, fromUser, toUser, status, timestamp];

  static Invite empty = Invite(
    id: "",
    fromUser: "",
    toUser: ""
  );

  /// Getter for checking if the invite is empty.
  bool get isEmpty => this == Invite.empty;

  /// Returns a copy of the invite with the given values.
  Invite copyWith({
    String? id,
    String? fromUser,
    String? toUser,
    InviteStatus? status
  }) {
    return Invite(
      id: id ?? this.id,
      fromUser: fromUser ?? this.fromUser,
      toUser: toUser ?? this.toUser,
      status: status ?? this.status
    );
  }
  
  /// Data serialization for database storage.
  JsonMap toDocument() {
    return {
      "id": id,
      "fromUser": fromUser,
      "toUser": toUser,
      "status": status.index,
      "timestamp": timestamp
    };
  }
  
  /// Database data deserialization.
  static Invite fromDocument(JsonMap doc) {
    return Invite(
      id: doc["id"] as String,
      fromUser: doc["fromUser"] as String,
      toUser: doc["toUser"] as String,
      status: InviteStatus.values[(doc["status"] as int)],
      timestamp: doc["timestamp"] as Timestamp
    );
  }

  /// Data serialization for elasticsearch.
  JsonMap toEsObject() {
    return {
      "id": id,
      "fromUser": fromUser,
      "toUser": toUser,
      "status": status.index,
      "timestamp": timestamp.toDate().toIso8601String()
    };
  }

  /// Data deserialization for elasticsearch.
  static Invite fromEsObject(JsonMap doc) {
    return Invite(
      id: doc["id"] as String,
      fromUser: doc["fromUser"] as String,
      toUser: doc["toUser"] as String,
      status: InviteStatus.values[(doc["status"] as int)],
      timestamp: Timestamp.fromDate(DateTime.parse(doc["timestamp"] as String))
    );
  }
}