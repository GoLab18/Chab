import 'package:flutter/material.dart';

class DrawerTile extends StatelessWidget {
  final IconData tileIcon;
  final String title;
  final void Function()? onTap;

  const DrawerTile({
    super.key,
    required this.tileIcon,
    required this.title,
    required this.onTap
  });


  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Icon(
        tileIcon,
        color: Theme.of(context).colorScheme.inversePrimary
      ),
      title: Center(
        child: Text(
          title,
          style: TextStyle(
            color: Theme.of(context).colorScheme.inversePrimary,
            fontSize: 16,
            fontWeight: FontWeight.bold
          )
        ),
      ),
      titleAlignment: ListTileTitleAlignment.center,
      trailing: Icon(
        Icons.arrow_back,
        color: Theme.of(context).colorScheme.inversePrimary
      )
    );
  }
}