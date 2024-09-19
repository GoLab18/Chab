import 'package:flutter/material.dart';

class IsEmptyMessageWidget extends StatelessWidget {
  const IsEmptyMessageWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      "Empty",
      style: TextStyle(
        fontSize: 30,
        color: Theme.of(context).colorScheme.inversePrimary
      )
    );
  }
}