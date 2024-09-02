import 'package:equatable/equatable.dart';

/// The type definition for a JSON-serializable [Map].
typedef JsonMap = Map<String, dynamic>;

class Usr extends Equatable {
  final String id;
  final String email;
  final String name;
  final String picture;
  final String bio;

  const Usr({
    required this.id,
    required this.email,
    required this.name,
    required this.picture,
    required this.bio
  });

  @override
  List<Object?> get props => [id, email, name, picture, bio];

  static const empty = Usr(
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
      "bio": bio
    };
  }
  
  /// Database data deserialization.
  static Usr fromDocument(JsonMap doc) {
    return Usr(
      id: doc["id"] as String,
      email: doc["email"] as String,
      name: doc["name"] as String,
      picture: doc["picture"] as String,
      bio: doc["bio"] as String
    );
  }
}