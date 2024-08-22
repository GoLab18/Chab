import 'package:equatable/equatable.dart';

/// The type definition for a JSON-serializable [Map].
typedef JsonMap = Map<String, dynamic>;

class Usr extends Equatable {
  final String id;
  final String email;
  final String name;
  final String picture;

  const Usr({
    required this.id,
    required this.email,
    required this.name,
    required this.picture
  });

  @override
  List<Object?> get props => [id, email, name, picture];

  static const empty = Usr(
    id: "",
    email: "",
    name: "",
    picture: ""
  );

  /// Getter for checking if the user is empty.
  bool get isEmpty => this == Usr.empty;

  /// Returns a copy of the user with the given values.
  Usr copyWith({
    String? id,
    String? email,
    String? name,
    String? picture
  }) {
    return Usr(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      picture: picture ?? this.picture
    );
  }
  
  /// Data serialization for database storage.
  JsonMap toDocument() {
    return {
      "id": id,
      "email": email,
      "name": name,
      "picture": picture
    };
  }
  
  /// Database data deserialization.
  static Usr fromDocument(JsonMap doc) {
    return Usr(
      id: doc["id"] as String,
      email: doc["email"] as String,
      name: doc["name"] as String,
      picture: doc["picture"] as String
    );
  }
}