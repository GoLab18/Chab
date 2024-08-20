part of 'sign_in_bloc.dart';

@immutable
sealed class SignInState extends Equatable{
  const SignInState();
  
  @override
  List<Object> get props => [];
}

final class SignInInitial extends SignInState {}

final class SignInSuccess extends SignInState {}

final class SignInFailure extends SignInState {
  final String? message;

  const SignInFailure({
    this.message
  });
}

final class SignInPending extends SignInState {}
