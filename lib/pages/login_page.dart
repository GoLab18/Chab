import 'package:chatise_app/components/button_template.dart';
import 'package:chatise_app/components/custom_textfield.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _pwdController = TextEditingController();

  final void Function()? toggleRegisterPage;
  
  LoginPage({
    super.key,
    required this.toggleRegisterPage
  });

  void login() {

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
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
              onButtonPressed: login
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
      )
    );
  }
}