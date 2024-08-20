import 'package:chab/util/auth_util/regex.dart';
import 'package:chab/blocs/sign_in_bloc/sign_in_bloc.dart';
import 'package:chab/components/button_template.dart';
import 'package:chab/components/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SignInPage extends StatefulWidget {
  final void Function()? toggleSignUpPage;

  const SignInPage({super.key, required this.toggleSignUpPage});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _pwdController = TextEditingController();

  IconData iconPassword = Icons.visibility;
  bool isObscured = true;
  bool signInTriggered = false;

  String? error;
  bool isErrorVisible = false;

  void toggleObscuredText() {
    setState(() {
      isObscured = !isObscured;
    });
  }

  void login() {
    if (_formKey.currentState!.validate()) {
      context.read<SignInBloc>().add(
        SignInRequested(
          email: _emailController.text,
          password: _pwdController.text
        )
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30),
          child: Form(
            key: _formKey,
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
                  inputController: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (String? textField) => validateEmail(textField),
                  prefixIconData: Icons.email_outlined
                ),

                const SizedBox(height: 20),

                // Login password
                CustomTextField(
                  hintText: "Password..",
                  inputController: _pwdController,
                  keyboardType: TextInputType.visiblePassword,
                  validator: (String? textField) => validatePassword(textField),
                  prefixIconData: Icons.lock_outline,
                  isObscured: isObscured,
                  suffixIconButtonData: isObscured
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                  suffixIconOnPressed: toggleObscuredText
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

                BlocListener<SignInBloc, SignInState>(
                  listener: (context, state) {
                    setState(() {
                      if (state is SignInSuccess) {
                        isErrorVisible = false;
                        signInTriggered = false;
                      } else if (state is SignInPending) {
                        signInTriggered = true;
                      } else if (state is SignInFailure) {
                        error = state.error;
                        isErrorVisible = true;
                        signInTriggered = false;
                      }
                    });
                  },
                  child: !signInTriggered
                    ? Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [

                        // Sign in button
                        ButtonTemplate(
                          buttonText: "Sign In",
                          onButtonPressed: login
                        ),
                        
                        // Error message
                        Visibility(
                          visible: isErrorVisible,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Center(
                              child: Text(
                                error ?? "",
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color.fromARGB(255, 209, 53, 42)
                                )
                              )
                            )
                          )
                        )
                      ]
                    )
                    : Center(
                      child: CircularProgressIndicator(
                        color: Theme.of(context).colorScheme.primary
                      )
                    )
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
                      onTap: widget.toggleSignUpPage,
                      child: Text(
                        "Sign up",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold
                        )
                      )
                    )
                  ]
                )
              ]
            )
          )
        )
      )
    );
  }
}
