part of 'sign_up_bloc.dart';

@immutable
sealed class SignUpState extends Equatable{
  const SignUpState();
  
  @override
  List<Object> get props => [];
}

final class SignUpInitial extends SignUpState {}

final class SignUpSuccess extends SignUpState {}

final class SignUpFailure extends SignUpState {
  final String error;

  const SignUpFailure(this.error);
}

final class SignUpPending extends SignUpState {}
