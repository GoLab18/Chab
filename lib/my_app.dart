import 'package:chab/blocs/auth_bloc/auth_bloc.dart';
import 'package:chab/blocs/sign_in_bloc/sign_in_bloc.dart';
import 'package:chab/blocs/sign_up_bloc/sign_up_bloc.dart';
import 'package:chab/util/auth_util/auth_gate.dart';
import 'package:chab/blocs/theme_bloc/theme_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:user_repository/user_repository.dart';


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (BuildContext context) => AuthBloc(
              userRepository: context.read<FirebaseUserRepository>()
            )
          ),
          BlocProvider(
            create: (BuildContext context) => SignInBloc(
              userRepository: context.read<FirebaseUserRepository>()
            )
          ),
          BlocProvider(
            create: (BuildContext context) => SignUpBloc(
              userRepository: context.read<FirebaseUserRepository>()
            )
          ),
          BlocProvider(
            create: (BuildContext context) => ThemeBloc()
          )
        ],
        child: BlocBuilder<ThemeBloc, ThemeState>(
          builder: (context, state) {
            return MaterialApp(
                debugShowCheckedModeBanner: false,
                title: "Chab",
                theme: state.themeData,
                home: const AuthGate());
          },
        ));
  }
}
