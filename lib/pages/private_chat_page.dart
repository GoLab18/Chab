import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:user_repository/user_repository.dart';

import '../blocs/room_bloc/room_bloc.dart';
import '../blocs/room_members_bloc/room_members_bloc.dart';
import '../components/tiles/utility_tile.dart';

class PrivateChatPage extends StatelessWidget {
  final Usr initialData;
  
  const PrivateChatPage(this.initialData, {super.key});

  @override
  Widget build(BuildContext context) {
    final RoomState roomState = context.read<RoomBloc>().state;
    final RoomMembersState roomMembersState = context.read<RoomMembersBloc>().state;

    return SafeArea(
      top: false,
      bottom: false,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: Center(
          child: StreamBuilder<Usr>(
            initialData: initialData,
            stream: roomMembersState.privateChatRoomFriend,
            builder: (context, snapshot) => CustomScrollView(
              slivers: [
                SliverAppBar(
                  pinned: true,
                  floating: true,
                  expandedHeight: 136.0,
                  flexibleSpace: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: FlexibleSpaceBar(
                      background: Center(
                        child: Column(
                          children: [
                            const SizedBox(height: 80),

                            CircleAvatar(
                              radius: 40,
                              foregroundImage: snapshot.data!.picture != ""
                                ? NetworkImage(snapshot.data!.picture)
                                : null
                            )
                          ]
                        )
                      )
                    )
                  )
                ),
                
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Group name
                        Padding(
                          padding: const EdgeInsets.only(
                            top: 18,
                            left: 16,
                            right: 16
                          ),
                          child: Column(
                            children: [
                              // Username
                              Text(
                                snapshot.data!.name,
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Theme.of(context).colorScheme.inversePrimary
                                )
                              ),

                              // TODO Nickname
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  "HeidiLMFAO",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Theme.of(context).colorScheme.tertiary
                                  )
                                ),
                              )
                            ],
                          )
                        ),

                        Padding(
                          padding: const EdgeInsets.only(
                            left: 16,
                            right: 16
                          ),
                          child: Divider(
                            color: Theme.of(context).colorScheme.tertiary
                          )
                        ),
                        
                        GridView.count(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 4,
                          children: [
                            // TODO audio, video, pinned messages, search messages, notifications toggle, search files, nickname(s), leave group/delete friend, mute
                            UtilityTile(
                              title: "Audio",
                              iconData: Icons.phone_outlined,
                              onTap: () {}
                            ),
                            UtilityTile(
                              title: "Video",
                              iconData: Icons.video_camera_front_outlined,
                              onTap: () {}
                            ),
                            UtilityTile(
                              title: "Mute",
                              iconData: Icons.notifications_outlined,
                              onTap: () {}
                            ),
                            UtilityTile(
                              title: "Files",
                              iconData: Icons.folder_outlined,
                              onTap: () {}
                            ),
                            UtilityTile(
                              title: "Nicknames",
                              iconData: Icons.badge_outlined,
                              onTap: () {}
                            ),
                            UtilityTile(
                              title: "Messages",
                              iconData: Icons.search_outlined,
                              onTap: () {}
                            ),
                            UtilityTile(
                              title: "Pinned",
                              iconData: Icons.push_pin_outlined,
                              onTap: () {}
                            ),
                            UtilityTile(
                              title: "Unfriend",
                              iconData: Icons.person_remove_outlined,
                              onTap: () {}
                            )
                          ]
                        ),

                        Padding(
                          padding: const EdgeInsets.only(
                            left: 16,
                            right: 16
                          ),
                          child: Divider(
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