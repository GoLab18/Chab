import 'package:chatise_app/authentication/login_register.dart';
import 'package:chatise_app/themes/light_mode.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Chatise",
      theme: lightMode,
      home: const LoginRegister()
    );
  }
}
