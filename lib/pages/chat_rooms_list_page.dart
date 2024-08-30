import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/room_bloc/room_bloc.dart';
import '../components/is_empty_message_widget.dart';
import '../components/user_list_tile.dart';

class ChatRoomsListPage extends StatefulWidget {
  const ChatRoomsListPage({super.key});

  @override
  State<ChatRoomsListPage> createState() => _ChatRoomsListPageState();
}

class _ChatRoomsListPageState extends State<ChatRoomsListPage> {
  bool isEmpty = true;

  // TODO
  // @override
  // void initState() {
  //   context.read<RoomBloc>().add(UserRoomsRequested(
  //     userId: 
  //   ));

  //   super.initState();
  // }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: BlocBuilder<RoomBloc, RoomState>(
        builder: (context, state) {
          if (state.status == ChatRoomStatus.success) {
            return state.roomsList != null 
              ? ListView.builder(
                  itemCount: state.roomsList!.length,
                  itemBuilder: (BuildContext context, int index) {
                    return const UserListTile();
                  }
                )
              : const IsEmptyMessageWidget();
          } else if (state.status == ChatRoomStatus.loading) {
            return const CircularProgressIndicator();
          } else if (state.status == ChatRoomStatus.failure) {
            return Text(
              "Loading error",
              style: TextStyle(
                fontSize: 30,
                color: Theme.of(context).colorScheme.inversePrimary
              )
            );
          }

          throw Exception("Non-existent room_bloc state");
        }
      ),
    );
  }
}
