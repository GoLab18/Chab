import 'package:flutter/material.dart';

class MessageDivider extends StatelessWidget {
  final String dateString;

  const MessageDivider(this.dateString, {super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 4,
          vertical: 14
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Divider(
                color: Theme.of(context).dividerColor,
                thickness: 0.6
              )
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Container(
                color: Colors.transparent,
                child: Text(
                  dateString,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.inversePrimary
                  )
                )
              )
            ),
            Expanded(
              child: Divider(
                color: Theme.of(context).dividerColor,
                thickness: 0.6
              )
            )
          ]
        )
      )
    );
  }
}