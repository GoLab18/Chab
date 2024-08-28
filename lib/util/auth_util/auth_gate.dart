import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:room_repository/room_repository.dart';

import '../../blocs/auth_bloc/auth_bloc.dart';
import '../../blocs/room_bloc/room_bloc.dart';
import '../../pages/home_page.dart';
import 'login_register.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: BlocBuilder<AuthBloc, AuthState>(
        builder: (BuildContext context, AuthState state) {
      if (state.status == AuthStatus.authenticated) {
        return RepositoryProvider(
          create: (context) => FirebaseRoomRepository(),
          child: BlocProvider(
            create: (context) => RoomBloc(
              roomRepository: context.read<FirebaseRoomRepository>()
            ),
            child: const HomePage()
          )
        );
      } else {
        return const LoginRegister();
      }
    }));
  }
}
