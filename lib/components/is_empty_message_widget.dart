import 'package:flutter/material.dart';

class IsEmptyMessageWidget extends StatelessWidget {
  const IsEmptyMessageWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      "No friends? Add some :)",
      style: TextStyle(
        fontSize: 30,
        color: Theme.of(context).colorScheme.inversePrimary
      )
    );
  }
}