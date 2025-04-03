import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

import '../util/typedefs.dart';

class Member extends Equatable {
  /// Room id that the user is apart of.
  final String roomId;
  
  /// Member user id.
  final String memberId;

  /// Timestamp of the member getting kicked out. Specific for group chat rooms.
  /// As long as the member is apart of the group or the member is apart of a private chat room it is null.
  final Timestamp? kickOutTime;

  const Member({
    required this.roomId,
    required this.memberId,
    this.kickOutTime
  });
  
  @override
  List<Object?> get props => [roomId, memberId, kickOutTime];

  static Member empty = Member(
    roomId: "",
    memberId: ""
  );

  /// Getter for checking if the member is empty.
  bool get isEmpty => this == Member.empty;

  /// Returns a copy of the member with the given values.
  Member copyWith({
    String? roomId,
    String? memberId,
    Timestamp? kickOutTime
  }) {
    return Member(
      roomId: roomId ?? this.roomId,
      memberId: memberId ?? this.memberId,
      kickOutTime: kickOutTime ?? this.kickOutTime
    );
  }
  
  /// Data serialization for database storage.
  JsonMap toDocument() {
    return {
      "roomId": roomId,
      "memberId": memberId,
      "kickOutTime": kickOutTime
    };
  }
  
  /// Database data deserialization.
  static Member fromDocument(JsonMap doc) {
    return Member(
      roomId: doc["roomId"] as String,
      memberId: doc["memberId"] as String,
      kickOutTime: doc["kickOutTime"] as Timestamp?
    );
  }

  /// Data serialization for elasticsearch.
  JsonMap toEsObject(String memberUsername, String memberPicUrl) {
    return {
      "roomId": roomId,
      "member": {
        "id": memberId,
        "name": memberUsername,
        "picture": memberPicUrl
      },
      if (kickOutTime != null) "kickOutTime": kickOutTime!.toDate().toIso8601String()
    };
  }
  
  /// Data deserialization for elasticsearch.
  static Member fromEsObject(JsonMap doc) {
    return Member(
      roomId: doc["roomId"] as String,
      memberId: doc["member.id"] as String,
      kickOutTime: (doc["kickOutTime"] != null) ? Timestamp.fromDate(DateTime.parse(doc["kickOutTime"] as String)) : null
    );
  }
}
