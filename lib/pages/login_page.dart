import 'package:chab/authentication/auth_service.dart';
import 'package:chab/components/button_template.dart';
import 'package:chab/components/custom_textfield.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _pwdController = TextEditingController();

  final void Function()? toggleRegisterPage;
  
  LoginPage({
    super.key,
    required this.toggleRegisterPage
  });

  void login(BuildContext context) async {
    final authService = AuthService();

    try {
      await authService.signInWithEmailAndPassword(
        _emailController.text,
        _pwdController.text
      );
    } catch (e) {
      // Check for async purposes, so that the dialog shows if the widget is still in the widget tree
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(
              e.toString()
            )
          )
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
          
              // Main logo
              Icon(
                Icons.message_sharp,
                size: 60,
                color: Theme.of(context).colorScheme.primary
              ),
          
              const SizedBox(height: 40),
              
              // Message
              Text(
                "Welcome back!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 16
                )
              ),
          
              const SizedBox(height: 20),
          
              // Login email
              CustomTextField(
                hintText: "Email..",
                inputController: _emailController
              ),
          
              const SizedBox(height: 20),
          
              // Login password
              CustomTextField(
                hintText: "Password..",
                inputController: _pwdController,
                isObscured: true
              ),
          
              const SizedBox(height: 10),
          
              // Change password if forgotten
              Text(
                "Forgot password?",
                textAlign: TextAlign.end,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary
                )
              ),
          
              const SizedBox(height: 10),
          
              // login button
              ButtonTemplate(
                buttonText: "Login",
                onButtonPressed: () => login(context)
              ),
          
              const SizedBox(height: 20),
          
              // Register instead
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account? ",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.tertiary
                    )
                  ),
                  GestureDetector(
                    onTap: toggleRegisterPage,
                    child: Text(
                      "Sign up",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold
                      )
                    ),
                  )
                ]
              )
            ]
          ),
        ),
      )
    );
  }
}