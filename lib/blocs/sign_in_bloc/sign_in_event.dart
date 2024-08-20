part of 'sign_in_bloc.dart';

sealed class SignInEvent extends Equatable {
  const SignInEvent();

  @override
  List<Object?> get props => throw UnimplementedError();
}

final class SignInRequested extends SignInEvent {
  final String email;
  final String password;

  const SignInRequested({
    required this.email,
    required this.password
  });
}

final class SignOutRequested extends SignInEvent {}
