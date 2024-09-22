import 'package:chab/blocs/room_bloc/room_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:room_repository/room_repository.dart';
import 'package:user_repository/user_repository.dart';

import '../blocs/room_members_bloc/room_members_bloc.dart';
import '../blocs/rooms_bloc/rooms_bloc.dart';
import '../blocs/usr_bloc/usr_bloc.dart';
import '../components/chat_room_tile.dart';

class ChatRoomsListPage extends StatelessWidget {
  const ChatRoomsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    ScrollController scrollController = ScrollController();

    return Center(
      child: BlocBuilder<UsrBloc, UsrState>(
        builder: (context, usrState) {
          return BlocBuilder<RoomsBloc, RoomsState>(
              builder: (context, roomsState) {
                if (roomsState.status == RoomsStatus.success && usrState.status == UsrStatus.success) {
                  return StreamBuilder(
                    stream: roomsState.roomsList,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) return const CircularProgressIndicator();
                      
                      if (snapshot.hasError) {
                        return Text(
                          "Loading error",
                          style: TextStyle(
                            fontSize: 30,
                            color: Theme.of(context).colorScheme.inversePrimary
                          )
                        );
                      }
      
                      final rooms = snapshot.data;
      
                      return SizedBox(
                        child: ListView.builder(
                          controller: scrollController,
                          itemCount: rooms!.length,
                          itemBuilder: (BuildContext context, int index) {
                            final room = rooms[index];
      
                            return MultiBlocProvider(
                              providers: [
                                BlocProvider(
                                  create: (context) => RoomMembersBloc(
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
                                  create: (context) => RoomBloc(
                                    roomRepository: context.read<FirebaseRoomRepository>()
                                  )
                                )
                              ],
                            child: ChatRoomTile(rooms[index])
                          );
                          }
                        )
                      );
                    }
                  );
                } else if (roomsState.status == RoomsStatus.loading || usrState.status == UsrStatus.loading) {
                  return const CircularProgressIndicator();
                } else if (roomsState.status == RoomsStatus.failure || usrState.status == UsrStatus.failure) {
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
