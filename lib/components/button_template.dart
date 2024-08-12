import 'package:flutter/material.dart';

class ButtonTemplate extends StatelessWidget {
  final String buttonText;
  final void Function()? onButtonPressed;


  const ButtonTemplate({
    super.key,
    required this.buttonText,
    required this.onButtonPressed
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onButtonPressed,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary,
          borderRadius: BorderRadius.circular(8)
        ),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Text(
            buttonText,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).colorScheme.inversePrimary
            )
          )
        )
      )
    );
  }
}