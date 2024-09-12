import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:room_repository/room_repository.dart';
import 'package:user_repository/user_repository.dart';

import '../blocs/bloc/room_members_bloc.dart';
import '../blocs/message_bloc/message_bloc.dart';
import '../blocs/room_bloc/room_bloc.dart';
import '../blocs/usr_bloc/usr_bloc.dart';
import '../pages/chat_room_page.dart';
import '../util/date_util.dart';

class ChatRoomTile extends StatelessWidget {
  final Room room;

  const ChatRoomTile(
    this.room,
    {super.key}
  );

  String _getUserNames(List<Usr> users) {
    int maxChars = 33;
    String finalString = "";

    for (Usr user in users) {
      String newChars = "${user.name}, ";

      if (finalString.length + newChars.length <= maxChars) {
        finalString += newChars;
      } else {
        return finalString.substring(0, finalString.length - 2);
      }
    }
    
    return finalString.substring(0, finalString.length - 2);
  }

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
                builder: (BuildContext pageContext) => MultiBlocProvider(
                  providers: [
                    BlocProvider.value(
                      value: context.read<UsrBloc>()
                    ),
                    BlocProvider.value(
                      value: context.read<RoomMembersBloc>()
                    ),
                    BlocProvider(
                      create: (BuildContext roomBlocContext) => RoomBloc(
                        roomRepository: context.read<FirebaseRoomRepository>()
                      )..add(RoomWithMessagesRequested(roomId: room.id))
                    ),
                    BlocProvider(
                      create: (BuildContext messageBlocContext) => MessageBloc(
                        roomRepository: context.read<FirebaseRoomRepository>()
                      )
                    )
                  ],
                  child: const ChatRoomPage()
                )
              )
            );
          }
        ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: SizedBox(
          height: 60,
          child: BlocBuilder<RoomMembersBloc, RoomMembersState>(
            builder: (context, state) => StreamBuilder(
              stream: state.roomMembersStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting || !snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Align(
                    alignment: Alignment.center,
                    child: CircularProgressIndicator()
                  );
                }

                if (snapshot.hasError) {
                  return Text(
                    "Loading error",
                    style: TextStyle(
                      fontSize: 20,
                      color: Theme.of(context).colorScheme.inversePrimary
                    )
                  );
                }

                final usersList = snapshot.data!;
                Usr? privateChatFriend;
                
                if (room.isPrivate) {
                  privateChatFriend = (usersList[0].id == context.read<UsrBloc>().state.user!.id)
                    ? usersList[1]
                    : usersList[0];
                }

                return Row(
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
                          foregroundImage: room.isPrivate
                            ? privateChatFriend!.picture.isNotEmpty
                              ? NetworkImage(privateChatFriend.picture)
                              : null
                            : (room.picture != null && room.picture!.isNotEmpty)
                              ? NetworkImage(room.picture!)
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
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Chat room name
                              Text(
                                room.isPrivate
                                  ? privateChatFriend!.name
                                  : (room.name != null && room.name!.isNotEmpty)
                                    ? room.name!
                                    : _getUserNames(usersList), // max 33 chars can fit
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.inversePrimary,
                                )
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  // Most recent message
                                  Flexible(
                                    child: Row(
                                      children: [
                                        // Username of the sender for the group chat room
                                        if (!room.isPrivate) Padding(
                                          padding: const EdgeInsets.only(right: 4),
                                          child: Text(
                                            (room.lastMessageSenderId != context.read<UsrBloc>().state.user!.id)
                                              ? """${usersList.firstWhere((Usr member) =>
                                                member.id == room.lastMessageSenderId
                                              ).name}:"""
                                              : "You:",
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontWeight: FontWeight.w900,
                                              fontSize: 12,
                                              color: Theme.of(context).colorScheme.tertiary
                                            )
                                          )
                                        ),

                                        // Picture icon if it was apart of the last message
                                        if (room.lastMessageHasPicture) Padding(
                                          padding: const EdgeInsets.only(right: 8),
                                          child: Icon(
                                            Icons.photo_outlined,
                                            size: 14,
                                            color: Theme.of(context).colorScheme.tertiary
                                          )
                                        ),
                                        
                                        // Message content if not empty
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
                          )
                        )
                      )
                    )
                  ]
                );
              }
            )
          )
        )
      )
    );
  }
}
