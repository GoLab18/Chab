import 'package:equatable/equatable.dart';

/// The type definition for a JSON-serializable [Map].
typedef JsonMap = Map<String, dynamic>;

class UsrEntity extends Equatable{
  final String id;
  final String email;
  final String name;
  final String? picture;

  const UsrEntity({
    required this.id,
    required this.email,
    required this.name,
    required this.picture
  });

  @override
  List<Object?> get props => [id, email, name, picture];

  JsonMap toDocument() {
    return {
      "id": id,
      "email": email,
      "name": name,
      "picture": picture
    };
  }
  
  static UsrEntity fromDocument(JsonMap doc) {
    return UsrEntity(
      id: doc["id"] as String,
      email: doc["email"] as String,
      name: doc["name"] as String,
      picture: doc["picture"] as String?
    );
  }
  
  @override
  String toString() {
    return '''UsrEntity: {
    id: $id
    email: $email
    name: $name
    picture: $picture
    }''';
  }
}