import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/rooms_bloc/rooms_bloc.dart';
import '../components/is_empty_message_widget.dart';
import '../components/chat_room_tile.dart';

class ChatRoomsListPage extends StatelessWidget {
  const ChatRoomsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    ScrollController scrollController = ScrollController();

    return Center(
      child: BlocBuilder<RoomsBloc, RoomsState>(
        builder: (context, state) {
          if (state.status == RoomsStatus.success) {
            return StreamBuilder(
              stream: state.roomsList,
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

                if (!snapshot.hasData || snapshot.data!.isEmpty) return const IsEmptyMessageWidget();

                final rooms = snapshot.data;

                return SizedBox(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: rooms!.length,
                    itemBuilder: (BuildContext context, int index) => ChatRoomTile(rooms[index])
                  )
                );
              }
            );
          } else if (state.status == RoomsStatus.loading) {
            return const CircularProgressIndicator();
          } else if (state.status == RoomsStatus.failure) {
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
      ),
    );
  }
}
