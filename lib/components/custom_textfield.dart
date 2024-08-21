import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String hintText;
  final TextEditingController inputController;
  final bool isObscured;
	final TextInputType keyboardType;
	final IconData? suffixIconButtonData;
	final VoidCallback? onTap;
	final IconData? prefixIconData;
	final FocusNode? focusNode;
	final String? errorText;
	final String? Function(String?)? validator;
	final String? Function(String)? onChanged;
  final void Function()? suffixIconOnPressed;
  
  const CustomTextField({
    super.key,
    required this.hintText,
    required this.inputController,
    this.isObscured = false,
		required this.keyboardType,
		this.suffixIconButtonData,
		this.onTap,
		this.prefixIconData,
		this.focusNode,
		this.errorText,
		this.validator,
		this.onChanged,
    this.suffixIconOnPressed
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: inputController,
      validator: validator,
      onTap: onTap,
      onChanged: onChanged,
      obscureText: isObscured,
      focusNode: focusNode,
      keyboardType: keyboardType,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
				suffixIcon: IconButton(
          onPressed: suffixIconOnPressed,
          icon: Icon(
            suffixIconButtonData,
            color: Theme.of(context).colorScheme.tertiary
          )
        ),
				prefixIcon: Icon(
          prefixIconData,
          color: Theme.of(context).colorScheme.tertiary
        ),
        errorText: errorText,
        errorStyle: TextStyle(
          color: Theme.of(context).colorScheme.error
        ),
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