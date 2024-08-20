part of 'auth_bloc.dart';

@immutable
sealed class AuthEvent extends Equatable {
  const AuthEvent();
  
  @override
  List<Object> get props => [];
}

final class AuthUserChanged extends AuthEvent {
  final User? user;

  const AuthUserChanged({
    this.user
  });
}
