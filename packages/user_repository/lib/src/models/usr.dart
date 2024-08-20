import 'package:equatable/equatable.dart';

import '../entities/entities.dart';

class Usr extends Equatable {
  final String id;
  final String email;
  final String name;
  final String? picture;

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

  /// Getter for checking if the user is empty
  bool get isEmpty => this == Usr.empty;

  /// Getter for checking if the user is not empty
  bool get isNotEmpty => this != Usr.empty;

  /// Returns a copy of `user` with the given values
  Usr copyWith({
    String? id,
    String? email,
    String? name,
    String? picture
  }) {
    return Usr(id: id ?? this.id,
    email: email ?? this.email,
    name: name ?? this.name,
    picture: picture ?? this.picture
    );
  }
  
  UsrEntity toEntity() {
    return UsrEntity(
      id: id,
      email: email,
      name: name,
      picture: picture
    );
  }

  static Usr fromEntity(UsrEntity entity) {
    return Usr(
      id: entity.id,
      email: entity.email,
      name: entity.name,
      picture: entity.picture
    );
  }
}