import 'package:flutter/material.dart';
import 'package:room_repository/room_repository.dart';

import '../pages/chat_room_page.dart';
import '../util/date_util.dart';

class ChatRoomTile extends StatelessWidget {
  final Room room;

  const ChatRoomTile(
    this.room,
    {super.key}
  );

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Theme.of(context).colorScheme.secondary,
      onTap: () => Future.delayed(
          const Duration(milliseconds: 200),
          () {
            if (!context.mounted) return;

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) => const ChatRoomPage()
              ),
            );
          },
        ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                fit: StackFit.loose,
                children: [
                  // Chat room photo
                  CircleAvatar(
                    radius: 30,
                    foregroundImage: (room.picture.isNotEmpty)
                      ? NetworkImage(room.picture)
                      : null,
                    backgroundColor: Theme.of(context).colorScheme.tertiary,
                    child: Icon(
                      Icons.person_outlined,
                      color: Theme.of(context).colorScheme.inversePrimary
                    )
                  ),
          
                  // Online status
                  Visibility(
                    visible: true,
                    child: Positioned(
                      bottom: 0,
                      right: 0,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface,
                              shape: BoxShape.circle
                            ),
                          ),
        
                          Container(
                            width: 12,
                            height: 12,
                            decoration: const BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle
                            )
                          )
                        ] 
                      )
                    )
                  )
                ]
              ),
          
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 10,
                    top: 2,
                    bottom: 2
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical:  6),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Chat room name
                        Text(
                          // room.name,
                          room.name,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.inversePrimary
                          )
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Most recent message
                            Flexible(
                              child: Row(
                                children: [
                                  if (room.lastMessageHasPicture) Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: Icon(
                                      Icons.photo_outlined,
                                      size: 14,
                                      color: Theme.of(context).colorScheme.tertiary
                                    )
                                  ),
                                              
                                  if (room.lastMessageContent.isNotEmpty) Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(right: 12),
                                      child: Text(
                                        room.lastMessageContent,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Theme.of(context).colorScheme.tertiary
                                        )
                                      )
                                    )
                                  )
                                ]
                              )
                            ),
                            
                            // Last message's timestamp
                            Text(
                              DateUtil.getCurrentDate(room.lastMessageTimestamp.toDate()),
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.tertiary
                              )
                            )
                          ]
                        )
                      ]
                    ),
                  )
                )
              )
            ]
          )
        )
      )
    );
  }
}