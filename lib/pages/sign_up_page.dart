import 'package:chab/util/auth_util/regex.dart';
import 'package:chab/blocs/sign_up_bloc/sign_up_bloc.dart';
import 'package:chab/components/button_template.dart';
import 'package:chab/components/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:user_repository/user_repository.dart';

class SignUpPage extends StatefulWidget {
  final void Function()? toggleSignInPage;

  const SignUpPage({super.key, required this.toggleSignInPage});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _pwdController = TextEditingController();
  final TextEditingController _confirmPwdController = TextEditingController();

  IconData iconPassword = Icons.visibility;
  bool isObscuredPwd = true;
  bool isObscuredConfirmPwd = true;
  bool signUpTriggered = false;

  String? error;
  bool isErrorVisible = false;

  void register() {
    if (_formKey.currentState!.validate()) {
      Usr usr = Usr.empty;

      usr = usr.copyWith(
        email: _emailController.text,
        name: _usernameController.text
      );

      context.read<SignUpBloc>().add(
        SignUpRequested(
          user: usr,
          password: _confirmPwdController.text
        )
      );
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _pwdController.dispose();
    _confirmPwdController.dispose();

    super.dispose();
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

                const SizedBox(height: 20), 

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

                // Register username
                CustomTextField(
                  hintText: "Username..",
                  inputController: _usernameController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (String? textField) => validateUsername(textField),
                  prefixIconData: Icons.person_2_outlined
                ),

                const SizedBox(height: 20),

                // Register email
                CustomTextField(
                  hintText: "Email..",
                  inputController: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (String? textField) => validateEmail(textField),
                  prefixIconData: Icons.email_outlined
                ),

                const SizedBox(height: 20),

                // Register password
                CustomTextField(
                  hintText: "Password..",
                  inputController: _pwdController,
                  keyboardType: TextInputType.visiblePassword,
                  validator: (String? textField) => validatePassword(textField),
                  prefixIconData: Icons.lock_outline,
                  isObscured: isObscuredPwd,
                  suffixIconButtonData: isObscuredPwd
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                  suffixIconOnPressed: () {
                    setState(() {
                      isObscuredPwd = !isObscuredPwd;
                    });
                  }
                ),

                const SizedBox(height: 20),

                // Confirm password
                CustomTextField(
                  hintText: "Confirm password..",
                  inputController: _confirmPwdController,
                  keyboardType: TextInputType.visiblePassword,
                  validator: (String? textField) => validateConfirmPassword(textField, _pwdController.text),
                  prefixIconData: Icons.lock_outline,
                  isObscured: isObscuredConfirmPwd,
                  suffixIconButtonData: isObscuredConfirmPwd
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                  suffixIconOnPressed: () {
                    setState(() {
                      isObscuredConfirmPwd = !isObscuredConfirmPwd;
                    });
                  }
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

                BlocListener<SignUpBloc, SignUpState>(
                  listener: (context, state) {
                    setState(() {
                      if (state is SignUpSuccess) {
                        isErrorVisible = false;
                        signUpTriggered = false;
                      } else if (state is SignUpPending) {
                        signUpTriggered = true;
                      } else if (state is SignUpFailure) {
                        error = state.error;
                        isErrorVisible = true;
                        signUpTriggered = false;
                      }
                    });
                  },
                  child: !signUpTriggered
                    ? Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [

                        // Sign up button
                        ButtonTemplate(
                          buttonText: "Sign Up",
                          onButtonPressed: register
                        ),
                        
                        // Error message
                        Visibility(
                          visible: isErrorVisible,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Center(
                              child: Text(
                                error ?? "",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(context).colorScheme.error
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

                // Login instead
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have an account?  ",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary
                        )
                    ),
                    GestureDetector(
                      onTap: widget.toggleSignInPage,
                      child: Text(
                        "Login now",
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
