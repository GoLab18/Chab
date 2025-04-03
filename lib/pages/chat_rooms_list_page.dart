import 'package:chab/blocs/room_bloc/room_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:room_repository/room_repository.dart';
import 'package:user_repository/user_repository.dart';

import '../blocs/room_members_bloc/room_members_bloc.dart';
import '../blocs/rooms_bloc/rooms_bloc.dart';
import '../blocs/usr_bloc/usr_bloc.dart';
import '../components/prompts/is_empty_message_widget.dart';
import '../components/tiles/chat_room_tile.dart';

class ChatRoomsListPage extends StatelessWidget {
  const ChatRoomsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    ScrollController scrollController = ScrollController();

    return Center(
      child: BlocBuilder<UsrBloc, UsrState>(
        builder: (context, usrState) {
          if (usrState.status == UsrStatus.loading) {
            return const CircularProgressIndicator();
          }
          
          if (usrState.status == UsrStatus.failure) {
            return Text(
              "Loading error",
              style: TextStyle(
                fontSize: 30,
                color: Theme.of(context).colorScheme.inversePrimary
              )
            );
          }

          return BlocBuilder<RoomsBloc, RoomsState>(
            builder: (context, roomsState) {
              if (roomsState.status == RoomsStatus.success) {
                return StreamBuilder(
                  stream: roomsState.roomsList,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting || !snapshot.hasData) {
                      return const CircularProgressIndicator();
                    }
                    
                    if (snapshot.hasError) {
                      return Text(
                        "Loading error",
                        style: TextStyle(
                          fontSize: 30,
                          color: Theme.of(context).colorScheme.inversePrimary
                        )
                      );
                    }
    
                    List<Room> rooms = snapshot.data!;  // TODO AnimatedList widget impl

                    if (rooms.isEmpty) {
                      return IsEmptyMessageWidget(
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.tertiary,
                        text: "No chat rooms yet",
                        iconData: Icons.groups_2_outlined,
                      );
                    }
    
                    return SizedBox(
                      child: ListView.builder(
                        controller: scrollController,
                        itemCount: rooms.length,
                        itemBuilder: (BuildContext context, int index) {
                          Room room = rooms[index];

                          return MultiBlocProvider(
                            key: ValueKey(room.id),
                            providers: [
                              BlocProvider(
                                create: (_) => RoomMembersBloc(
                                  userRepository: context.read<FirebaseUserRepository>()
                                )..add(
                                  room.isPrivate
                                    ? PrivateChatRoomMembersRequested(
                                      roomId: room.id,
                                      currentUserId: usrState.user!.id
                                    )
                                    : GroupChatRoomMembersRequested(room.id)
                                )
                              ),
                              BlocProvider(
                                create: (_) => RoomBloc(
                                  roomRepository: context.read<FirebaseRoomRepository>()
                                )
                              )
                            ],
                            child: ChatRoomTile(rooms[index], key: ValueKey(rooms[index].id))   // TODO i think this ValueKey will be a game changer
                          );
                        }
                      )
                    );
                  }
                );
              } else if (roomsState.status == RoomsStatus.loading) {
                return const CircularProgressIndicator();
              } else if (roomsState.status == RoomsStatus.failure) {
                return Text(
                  "Loading error",
                  style: TextStyle(
                    fontSize: 30,
                    color: Theme.of(context).colorScheme.inversePrimary
                  )
                );
              }
    
              throw Exception("Non-existent rooms_bloc state");
            }
          );
        }
      )
    );
  }
}
