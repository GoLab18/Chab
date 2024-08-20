import 'package:chab/pages/sign_in_page.dart';
import 'package:chab/pages/sign_up_page.dart';
import 'package:flutter/material.dart';

class LoginRegister extends StatefulWidget {
  const LoginRegister({super.key});

  @override
  State<LoginRegister> createState() => _LoginRegisterState();
}

class _LoginRegisterState extends State<LoginRegister> {
  // Login page by default
  bool showLogin = true;

  void switchPages() {
    setState(() {
      showLogin = !showLogin;
    });
  }

  @override
  Widget build(BuildContext context) {
    return showLogin
      ? SignInPage(
        toggleSignUpPage: switchPages
      )
      : SignUpPage(
        toggleSignInPage: switchPages
      );
  }
}
