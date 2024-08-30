import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:user_repository/user_repository.dart';

part 'usr_event.dart';
part 'usr_state.dart';

class UsrBloc extends Bloc<UsrEvent, UsrState> {
  final FirebaseUserRepository userRepository;
  
  UsrBloc({
    required this.userRepository
  }) : super(const UsrState.loading()) {
    on<GetUser>((event, emit) async {
      try {
        Usr user = await userRepository.getUsr(event.userId);
        
        emit(UsrState.success(user));
      } catch (e) {
        emit(const UsrState.failure());
      }
    });

    on<UpdateUser>((event, emit) {
      try {
        emit(UsrState.success(event.updatedUser));
      } catch (e) {
        emit(const UsrState.failure());
      }
    });
  }
}
