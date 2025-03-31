import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:room_repository/room_repository.dart';
import 'package:user_repository/user_repository.dart';

import '../../blocs/auth_bloc/auth_bloc.dart';
import '../../blocs/change_usr_info_bloc/change_usr_info_bloc.dart';
import '../../blocs/rooms_bloc/rooms_bloc.dart';
import '../../blocs/search_bloc/search_bloc.dart';
import '../../blocs/usr_bloc/usr_bloc.dart';
import '../../pages/home_page.dart';
import 'login_register.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (BuildContext context, AuthState state) {
        if (state.status == AuthStatus.authenticated) {
          return MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (context) => RoomsBloc(
                  roomRepository: context.read<FirebaseRoomRepository>()
                )..add(
                  UserRoomsRequested(
                    userId: state.user!.uid
                  )
                )
              ),
              BlocProvider(
                create: (BuildContext context) => UsrBloc(
                  userRepository: context.read<FirebaseUserRepository>()
                )..add(
                  GetUser(
                    userId: state.user!.uid
                  )
                )
              ),
              BlocProvider(
                create: (BuildContext context) => ChangeUsrInfoBloc(
                  userRepository: context.read<FirebaseUserRepository>()
                )
              ),
              BlocProvider(
                create: (context) => SearchBloc(
                  userRepository: context.read<FirebaseUserRepository>(),
                  roomRepository: context.read<FirebaseRoomRepository>()
                )
              )
            ],
            child: const HomePage()
          );
        } else {
          return const LoginRegister();
        }
      }
    );
  }
}
