import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:room_repository/room_repository.dart';
import 'package:user_repository/user_repository.dart';

import '../../blocs/messages_bloc/messages_bloc.dart';
import '../../blocs/room_members_bloc/room_members_bloc.dart';
import '../../blocs/message_bloc/message_bloc.dart';
import '../../blocs/room_bloc/room_bloc.dart';
import '../../blocs/search_bloc/search_bloc.dart';
import '../../blocs/usr_bloc/usr_bloc.dart';
import '../../pages/chat_room_page.dart';
import '../../util/date_util.dart';
import '../../util/room_name_util.dart';

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
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (BuildContext pageContext) => MultiBlocProvider(
            providers: [
              BlocProvider.value(
                value: context.read<UsrBloc>()
              ),
              BlocProvider.value(
                value: context.read<SearchBloc>()
              ),
              BlocProvider.value(
                value: context.read<RoomBloc>()..add(RoomRequested(room.id))
              ),
              BlocProvider.value(
                value: context.read<RoomMembersBloc>()
              ),
              BlocProvider(
                create: (BuildContext messageBlocContext) => MessageBloc(
                  roomRepository: context.read<FirebaseRoomRepository>()
                )
              ),
              BlocProvider(
                create: (BuildContext messagesBlocContext) => MessagesBloc(
                  roomRepository: context.read<FirebaseRoomRepository>()
                )..add(MessagesRequested(room.id))
              )
            ],
            child: const ChatRoomPage()
          )
        )
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Center(
          child: SizedBox(
            height: 60,
            child: BlocBuilder<RoomMembersBloc, RoomMembersState>(
              builder: (context, state) {
                if (
                  state.status == RoomMembersStatus.loading
                  || (state.privateChatRoomFriend == null && state.groupMembers == null)
                ) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state.status == RoomMembersStatus.failure) {
                  return Text(
                    "Loading error",
                    style: TextStyle(
                      fontSize: 24,
                      color: Theme.of(context).colorScheme.inversePrimary
                    )
                  );
                }

                return switch (room.isPrivate) {
                  
                  // Private chat room tile
                  true => Builder(
                    builder: (context) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Stack(
                            alignment: Alignment.center,
                            clipBehavior: Clip.none,
                            fit: StackFit.loose,
                            children: [
                              // Chat room photo -> friends photo
                              CircleAvatar(
                                radius: 30,
                                foregroundImage: state.privateChatRoomFriend!.picture.isNotEmpty
                                  ? NetworkImage(state.privateChatRoomFriend!.picture)
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
                                    // Friend's name
                                    Text(
                                      state.privateChatRoomFriend!.name, // max 33 chars can fit
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
                                              // "You" tag on current user's message
                                              if (room.lastMessageSenderId == context.read<UsrBloc>().state.user!.id) Padding(
                                                padding: const EdgeInsets.only(right: 4),
                                                child: Text(
                                                  "You:",
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
                                              if (room.lastMessageHasPicture != null && room.lastMessageHasPicture!) Padding(
                                                padding: const EdgeInsets.only(right: 8),
                                                child: Icon(
                                                  Icons.photo_outlined,
                                                  size: 14,
                                                  color: Theme.of(context).colorScheme.tertiary
                                                )
                                              ),
                      
                                              (room.lastMessageContent != null)
                                                // Message content if not empty
                                                ? Expanded(
                                                    child: Padding(
                                                      padding: const EdgeInsets.only(right: 12),
                                                      child: (room.lastMessageContent!.isNotEmpty)
                                                        ? Text(
                                                          room.lastMessageContent!,
                                                          maxLines: 1,
                                                          overflow: TextOverflow.ellipsis,
                                                          style: TextStyle(
                                                            fontSize: 12,
                                                            color: Theme.of(context).colorScheme.tertiary
                                                          )
                                                        )
                                                        : null
                                                    )
                                                  )
                                                : Text(
                                                  "Say hi!",
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                    color: Theme.of(context).colorScheme.inversePrimary
                                                  )
                                                )
                                            ]
                                          )
                                        ),
                                        
                                        // Last message's timestamp
                                        Text(
                                          DateUtil.getShortDateFormatFromNow(room.lastMessageTimestamp.toDate()),
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
                  ),
                            
                  // Group chat room tile
                  false => Builder(
                    builder: (context) {
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
                                foregroundImage:
                                (room.picture != null && room.picture!.isNotEmpty)
                                  ? NetworkImage(room.picture!)
                                  : null,
                                backgroundColor: Theme.of(context).colorScheme.tertiary,
                                child: Icon(
                                  Icons.people_outlined,
                                  color: Theme.of(context).colorScheme.inversePrimary
                                )
                              ),
                              
                              // Online status
                              Visibility(
                                visible: false,
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
                                        )
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
                                child: Builder(
                                  builder: (_) {
                                    List<Usr> usersList = state.groupMembers!.values.toList();
                            
                                    return Column(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Chat room's name
                                        Text(
                                          (room.name != null && room.name!.isNotEmpty)
                                            ? room.name!
                                            : RoomNameUtil.getUserNames(usersList),
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
                                                  Padding(
                                                    padding: const EdgeInsets.only(right: 4),
                                                    child: Text(
                                                      (room.lastMessageContent != null)
                                                        ? (room.lastMessageSenderId != context.read<UsrBloc>().state.user!.id)
                                                          ? """${usersList.firstWhere((Usr member) =>
                                                            member.id == room.lastMessageSenderId
                                                          ).name}:"""
                                                          : "You:"
                                                        : "",
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
                                                  if (room.lastMessageHasPicture != null && room.lastMessageHasPicture!) Padding(
                                                    padding: const EdgeInsets.only(right: 8),
                                                    child: Icon(
                                                      Icons.photo_outlined,
                                                      size: 14,
                                                      color: Theme.of(context).colorScheme.tertiary
                                                    )
                                                  ),
                                    
                                                  // TODO getting kicked out message instead of the normal one
                                                  
                                                  (room.lastMessageContent != null)
                                                    // Message content if not empty
                                                    ? Expanded(
                                                        child: Padding(
                                                          padding: const EdgeInsets.only(right: 12),
                                                          child: (room.lastMessageContent!.isNotEmpty)
                                                            ? Text(
                                                              room.lastMessageContent!,
                                                              maxLines: 1,
                                                              overflow: TextOverflow.ellipsis,
                                                              style: TextStyle(
                                                                fontSize: 12,
                                                                color: Theme.of(context).colorScheme.tertiary
                                                              )
                                                            )
                                                            : null
                                                        )
                                                      )
                                                    : Text(
                                                      "Say hi!",
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        fontWeight: FontWeight.bold,
                                                        color: Theme.of(context).colorScheme.inversePrimary
                                                      )
                                                    )
                                                ]
                                              )
                                            ),
                                            // Last message's timestamp / room creation timestamp / getting kicked out timestamp
                                            Text(
                                              DateUtil.getShortDateFormatFromNow(room.lastMessageTimestamp.toDate()),
                                              style: TextStyle(
                                                color: Theme.of(context).colorScheme.tertiary
                                              )
                                            )
                                          ]
                                        )
                                      ]
                                    );
                                  }
                                )
                              )
                            )
                          )
                        ]
                      );
                    }
                  )
                };
              }
            )
          )
        )
      )
    );
  }
}
