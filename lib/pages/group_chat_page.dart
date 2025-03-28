import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:user_repository/user_repository.dart';

import '../blocs/room_bloc/room_bloc.dart';
import '../blocs/room_members_bloc/room_members_bloc.dart';
import '../blocs/room_operations_bloc/room_operations_bloc.dart';
import '../components/avatar_action.dart';
import '../components/fields/transparent_editable_text_field.dart';
import '../components/tiles/user_tile.dart';
import '../components/tiles/utility_tile.dart';
import '../util/picture_util.dart';
import '../util/room_name_util.dart';

class GroupChatPage extends StatelessWidget {
  const GroupChatPage({super.key});
  
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: false,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: Center(
          child: BlocBuilder<RoomBloc, RoomState>(
            builder: (context, roomState) {
              return BlocBuilder<RoomMembersBloc, RoomMembersState>(
                builder: (context, roomMembersState) => CustomScrollView(
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

                                AvatarAction(
                                  radius: 40,
                                  avatarImage: (
                                    roomState.status == RoomStatus.success
                                    && roomState.room != null
                                    && roomState.room!.picture!.isNotEmpty
                                  )
                                    ? NetworkImage(roomState.room!.picture!)
                                    : null,
                                  circleAvatarBackgroundIconData: Icons.people_outlined,
                                  actionContainerSize: 30,
                                  actionIcon: Icon(
                                    Icons.add,
                                    size: 18,
                                    color: Theme.of(context).colorScheme.inversePrimary
                                  ),
                                  onActionPressed: () {
                                    if (roomState.status == RoomStatus.success && roomState.room != null) {
                                      PictureUtil.uploadAndCropPicture(
                                        context,
                                        null,
                                        (imagePath) => context.read<RoomOperationsBloc>().add(
                                          UploadRoomPicture(roomState.room!.id, imagePath)
                                        )
                                      );
                                    }
                                  }
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
                              child: Builder(
                                builder: (context) {
                                  if (roomState.status == RoomStatus.failure) {
                                    return Text(
                                      "Error",
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Theme.of(context).colorScheme.error
                                      )
                                    );
                                  }

                                  if (roomState.status == RoomStatus.loading || roomState.room == null) {
                                    return CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Theme.of(context).colorScheme.primary
                                    );
                                  }

                                  List<Usr>? usrList;
                        
                                  String roomName = roomState.room!.name!;
                        
                                  if (roomName.isEmpty) {
                                    usrList = roomMembersState.groupMembers!.values.toList();
                                  }
                                  
                                  return TransparentEditableTextField(
                                    initialText: usrList == null
                                      ? roomName
                                      : RoomNameUtil.getUserNames(usrList),
                                    isUpdatedTextLoaded: roomMembersState.groupMembers != null,
                                    onSubmission: (text) {
                                      context.read<RoomOperationsBloc>().add(
                                        UpdateChatRoom(
                                          roomState.room!.copyWith(name: text)
                                        )
                                      );
                                    }
                                  );
                                }
                              )
                            ),
    
                            Padding(
                              padding: const EdgeInsets.only(
                                top: 0,
                                bottom: 6,
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
                                // TODO audio, video, search messages, notifications toggle, search files, nickname(s), leave group/delete friend, mute
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
                                  title: "Add",
                                  iconData: Icons.person_add_outlined,
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
                                  title: "Leave",
                                  iconData: Icons.exit_to_app_outlined,
                                  onTap: () {}
                                )
                              ]
                            ),
                                    
                            // Members
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.all(8),
                                child: roomMembersState.status == RoomMembersStatus.loading
                                  ? const SizedBox(
                                    height: 100,
                                    child: CircularProgressIndicator()
                                  )
                                  : Builder(
                                    builder: (context) {
                                      if (roomMembersState.groupMembers == null) {
                                        return const Center(
                                          child: CircularProgressIndicator()
                                        );
                                      }
                                      
                                      if (roomMembersState.status == RoomMembersStatus.failure || roomMembersState.groupMembers!.isEmpty) {
                                        return Text(
                                          "Loading error",
                                          style: TextStyle(
                                            fontSize: 20,
                                            color: Theme.of(context).colorScheme.inversePrimary
                                          )
                                        );
                                      }
                              
                                      var usersList = roomMembersState.groupMembers!.values.toList();
                                      
                                      return Padding(
                                        padding: const EdgeInsets.only(
                                          top: 6,
                                          bottom: 8,
                                          left: 8,
                                          right: 8
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.stretch,
                                          children: [
                                            // Members info
                                            Container(
                                              decoration: BoxDecoration(
                                                color: Colors.transparent,
                                                border: Border.symmetric(
                                                  horizontal: BorderSide(
                                                    color: Theme.of(context).colorScheme.tertiary
                                                  )
                                                )
                                              ),
                                              child: Padding(
                                                padding: const EdgeInsets.all(8),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Text(
                                                      "Group Members",
                                                      style: TextStyle(
                                                        color: Theme.of(context).colorScheme.inversePrimary
                                                      )
                                                    ),
                                                
                                                    // Members amount
                                                    Text(
                                                      usersList.length.toString(),
                                                      style: TextStyle(
                                                        color: Theme.of(context).colorScheme.secondary
                                                      )
                                                    )
                                                  ]
                                                )
                                              )
                                            ),
                        
                                            // Members
                                            ...List.generate(
                                              usersList.length,
                                              (index) => UserTile(usersList[index])
                                            )
                                          ] 
                                        )
                                      );
                                    }
                                  )
                              )
                            )
                          ]
                        )
                      )
                    )
                  ]
                )
              );
            }
          )
        )
      )
    );
  }
}