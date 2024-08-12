import 'package:chab/components/button_template.dart';
import 'package:chab/components/custom_textfield.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _pwdController = TextEditingController();
  final TextEditingController _confirmPwdController = TextEditingController();

  final void Function()? toggleLoginPage;
  
  RegisterPage({
    super.key,
    required this.toggleLoginPage
  });

  void register() {

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
              "Create your account",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontSize: 16
              )
            ),
        
            const SizedBox(height: 20),
        
            // Register email
            CustomTextField(
              hintText: "Email..",
              inputController: _emailController
            ),
        
            const SizedBox(height: 20),
        
            // Register password
            CustomTextField(
              hintText: "Password..",
              inputController: _pwdController,
              isObscured: true
            ),
        
            const SizedBox(height: 20),
        
            // Confirm password
            CustomTextField(
              hintText: "Confirm password..",
              inputController: _confirmPwdController,
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
              onButtonPressed: register
            ),
        
            const SizedBox(height: 20),
        
            // Register instead
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Already have an account? ",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.tertiary
                  )
                ),
                GestureDetector(
                  onTap: toggleLoginPage,
                  child: Text(
                    "Login now",
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