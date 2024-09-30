import 'package:flutter/material.dart';

class UtilityTile extends StatelessWidget {
  final IconData iconData;
  final String title;
  final void Function() onTap;

  const UtilityTile({
    super.key,
    required this.iconData,
    required this.title,
    required this.onTap
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          elevation: 10,
          borderRadius: BorderRadius.circular(10),
          color: Theme.of(context).colorScheme.primary,
          child: InkWell(
            onTap: onTap,
            splashColor: Theme.of(context).colorScheme.tertiary.withOpacity(0.5),
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: 46,
              height: 46,
              child: Icon(
                iconData,
                size: 20,
                color: Theme.of(context).colorScheme.inversePrimary
              )
            )
          )
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.inversePrimary
            )
          )
        )
      ]
    );
  }
}