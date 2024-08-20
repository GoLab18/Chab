part of 'auth_bloc.dart';

enum AuthStatus {
  authenticated,
  unauthenticated,
  unknown
}

class AuthState extends Equatable {
  final User? user;
  final AuthStatus status;

  const AuthState({
    this.user,
    this.status = AuthStatus.unknown
  });

  /// No info about the [AuthStatus] of the user
  /// Falls back to [AuthStatus.unknown]
  const AuthState.unknown() : this();

  /// User has a status of [AuthStatus.authenticated]
  const AuthState.authenticated(User user) : this(user: user, status: AuthStatus.authenticated);

  /// User has a status of [AuthStatus.unauthenticated]
  const AuthState.unauthenticated() : this(status: AuthStatus.unauthenticated);

  @override
  List<Object?> get props => [user, status];
}
