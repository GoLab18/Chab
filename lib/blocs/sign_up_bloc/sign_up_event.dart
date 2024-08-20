part of 'sign_up_bloc.dart';

@immutable
sealed class SignUpEvent extends Equatable {
  const SignUpEvent();

  @override
  List<Object?> get props => [];
}

final class SignUpRequested extends SignUpEvent {
  final Usr user;
  final String password;

  const SignUpRequested({
    required this.user,
    required this.password
  });
}
