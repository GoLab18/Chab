import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String hintText;
  final TextEditingController inputController;
  final bool isObscured;
  
  const CustomTextField({
    super.key,
    required this.hintText,
    required this.inputController,
    this.isObscured = false
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: inputController,
      obscureText: isObscured,
      decoration: InputDecoration(
        filled: true,
        fillColor: Theme.of(context).colorScheme.secondary,
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.tertiary
          )
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary
          )
        ),
        hintText: hintText,
        hintStyle: TextStyle(
          color: Theme.of(context).hintColor
        )
      )
    );
  }
}