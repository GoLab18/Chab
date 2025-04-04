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
          return BlocBuilder<RoomsBloc, RoomsState>(
            builder: (context, roomsState) {
              if (usrState.status == UsrStatus.success && roomsState.status == RoomsStatus.success) {
                var rooms = roomsState.roomsList!;

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
                        key: ValueKey(rooms[index].id),
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
                        child: ChatRoomTile(rooms[index], key: ValueKey(rooms[index].id))
                      );
                    }
                  )
                );
              } else if (usrState.status == UsrStatus.loading || roomsState.status == RoomsStatus.loading) {
                return const CircularProgressIndicator();
              } else if (usrState.status == UsrStatus.failure|| roomsState.status == RoomsStatus.failure) {
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
