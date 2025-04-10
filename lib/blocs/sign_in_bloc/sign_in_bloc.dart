import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:user_repository/user_repository.dart';

part 'sign_in_event.dart';
part 'sign_in_state.dart';

class SignInBloc extends Bloc<SignInEvent, SignInState> {
  final FirebaseUserRepository userRepository;
  
  SignInBloc({
    required this.userRepository
  }) : super(SignInInitial()) {
    on<SignInRequested>((event, emit) async {
      emit(SignInPending());

      String? error = await userRepository.signIn(event.email, event.password);

      if (error == null) {
        emit(SignInSuccess());
      } else {
        emit(SignInFailure(error));
      }
    });

    on<SignOutRequested>((event, emit) async {
      await userRepository.signOut();
    });
  }
}
