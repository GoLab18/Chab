import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

import '../util/typedefs.dart';

class Usr extends Equatable {
  final String id;
  final String email;
  final String name;
  final String picture;

  /// Few words about the user.
  final String bio;
  
  /// User creation date.
  /// Isn't overriden on edit.
  late final Timestamp timestamp;

  Usr({
    required this.id,
    required this.email,
    required this.name,
    required this.picture,
    required this.bio,
    Timestamp? timestamp
  }) {
    this.timestamp = timestamp ?? Timestamp.now();
  }

  @override
  List<Object?> get props => [id, email, name, picture, bio, timestamp];

  static Usr empty = Usr(
    id: "",
    email: "",
    name: "",
    picture: "",
    bio: ""
  );

  /// Getter for checking if the user is empty.
  bool get isEmpty => this == Usr.empty;

  /// Returns a copy of the user with the given values.
  Usr copyWith({
    String? id,
    String? email,
    String? name,
    String? picture,
    String? bio
  }) {
    return Usr(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      picture: picture ?? this.picture,
      bio: bio ?? this.bio
    );
  }
  
  /// Data serialization for database storage.
  JsonMap toDocument() {
    return {
      "id": id,
      "email": email,
      "name": name,
      "picture": picture,
      "bio": bio,
      "timestamp": timestamp
    };
  }
  
  /// Database data deserialization.
  static Usr fromDocument(JsonMap doc) {
    return Usr(
      id: doc["id"] as String,
      email: doc["email"] as String,
      name: doc["name"] as String,
      picture: doc["picture"] as String,
      bio: doc["bio"] as String,
      timestamp: doc["timestamp"] as Timestamp
    );
  }
}