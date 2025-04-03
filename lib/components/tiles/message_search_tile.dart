import 'package:flutter/material.dart';
import 'package:room_repository/room_repository.dart';

class MessageSearchTile extends StatelessWidget {
  final Message message;
  final String name;
  final String? picUrl;
  final String currUserId;

  const MessageSearchTile({
    super.key,
    required this.message,
    required this.name,
    required this.picUrl,
    required this.currUserId
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Theme.of(context).colorScheme.secondary,
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Center(
          child: SizedBox(
            height: 60,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CircleAvatar(
                  radius: 30,
                  foregroundImage: (picUrl != null && picUrl!.isNotEmpty)
                    ? NetworkImage(picUrl!)
                    : null,
                  backgroundColor: Theme.of(context).colorScheme.tertiary,
                  child: Icon(
                    Icons.person_outlined,
                    color: Theme.of(context).colorScheme.inversePrimary
                  )
                ),
            
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: 10,
                      top: 8,
                      bottom: 8
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.inversePrimary,
                          )
                        ),

                        Text(
                          message.content,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.tertiary
                          )
                        )
                      ]
                    )
                  )
                )
              ]
            )
          )
        )
      )
    );
  }
}