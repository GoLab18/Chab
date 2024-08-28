import 'package:flutter/material.dart';

import '../components/button_template.dart';
import 'home_page.dart';

class ChangeAccountPage extends StatelessWidget {
  const ChangeAccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    int accountsAmount = 5;

    return Scaffold(
      appBar: AppBar(),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: accountsAmount + 1, // +1 is for the text field
              itemBuilder: (BuildContext context, int index) {
                if (index < accountsAmount) {
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
                } else {
                  // Information text
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4
                      ),
                      child: Text(
                        "You can add up to 5 accounts, between which you can switch freely without logging in.",
                        softWrap: true,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.tertiary
                        )
                      ),
                    ),
                  );
                }
              }
            )
          ),

          // Register new account button
          // TODO navigates to a slightly changed sign up page
          Padding(
            padding: const EdgeInsets.all(12),
            child: ButtonTemplate(
              buttonText: "Make a new account",
              onButtonPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) => const HomePage())
              )
            ),
          )
        ]
      )
    );
  }
}
