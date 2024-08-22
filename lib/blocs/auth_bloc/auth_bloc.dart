import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:user_repository/user_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final FirebaseUserRepository userRepository;
  late final StreamSubscription<User?> userSubscription;

  AuthBloc({
    required this.userRepository
  }) : super(const AuthState.unknown()) {
    userSubscription = userRepository.user.listen((User? user) {
      add(AuthUserChanged(user: user));
    });

    on<AuthUserChanged>((event, emit) {
      (event.user != null)
        ? emit(AuthState.authenticated(event.user!))
        : emit(const AuthState.unauthenticated());
    });
  }

  @override
  Future<void> close() {
    userSubscription.cancel();
    return super.close();
  }
}
