import 'package:equatable/equatable.dart';

import '../entities/usr_entity.dart';

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
  
  /// Conversion to entity object for serialization utility.
  UsrEntity toEntity() {
    return UsrEntity(
      id: id,
      email: email,
      name: name,
      picture: picture
    );
  }

  /// Conversion from the entity object.
  static Usr fromEntity(UsrEntity entity) {
    return Usr(
      id: entity.id,
      email: entity.email,
      name: entity.name,
      picture: entity.picture
    );
  }
}