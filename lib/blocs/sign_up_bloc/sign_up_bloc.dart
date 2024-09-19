import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:user_repository/user_repository.dart';

part 'sign_up_event.dart';
part 'sign_up_state.dart';

class SignUpBloc extends Bloc<SignUpEvent, SignUpState> {
  final FirebaseUserRepository userRepository;

  SignUpBloc({
    required this.userRepository
  }) : super(SignUpInitial()) {
    on<SignUpRequested>((event, emit) async {
      // Authenticating sign up user
      Result<Usr, String> signUpResult = await userRepository.signUp(
        event.user,
        event.password
      );
      
      if (signUpResult.isSuccess) {
        // Storing the new user data
        await userRepository.addUser(signUpResult.value!);

        emit(SignUpSuccess());
      }

      if (signUpResult.isError) {
        // Emit failure with error message
        emit(SignUpFailure(signUpResult.error!));
      }        
    });
  }
}
