import 'package:chatise_app/pages/login_page.dart';
import 'package:chatise_app/pages/register_page.dart';
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
      ? LoginPage(
        toggleRegisterPage: switchPages
      )
      : RegisterPage(
        toggleLoginPage: switchPages
      );
  }
}