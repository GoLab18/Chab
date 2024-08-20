import 'package:chab/util/auth_util/login_register.dart';
import 'package:chab/blocs/auth_bloc/auth_bloc.dart';
import 'package:chab/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (BuildContext context, AuthState state) {
          if (state.status == AuthStatus.authenticated) {
            return const HomePage();
          } else {
            return const LoginRegister();
          }
        }
      )
    );
  }
}