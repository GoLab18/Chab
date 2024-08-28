import 'package:flutter/material.dart';

class AccountTile extends StatelessWidget {
  final String username;
  final bool isUsedNow;
  
  const AccountTile({
    super.key,
    required this.username,
    required this.isUsedNow
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        // TODO child widget null if image is there
        // backgroundImage: Image.asset(),
        // foregroundImage: Image.asset(),
        // onForegroundImageError: (exception, stackTrace) {
          
        // }
        child: Icon(
          Icons.person_outlined,
          color: Theme.of(context).colorScheme.inversePrimary
        ),
      ),
      title: Text(
        // TODO Display username
        "Username",
        style: TextStyle(
          color: Theme.of(context).colorScheme.inversePrimary
        )
      ),
      trailing: Icon(
        Icons.check_circle_outlined,
        color: Theme.of(context).colorScheme.inversePrimary
      )
    );
  }
}
