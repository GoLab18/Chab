import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:user_repository/user_repository.dart';

import '../blocs/room_bloc/room_bloc.dart';
import '../blocs/room_members_bloc/room_members_bloc.dart';
import '../blocs/room_operations_bloc/room_operations_bloc.dart';
import '../components/fields/transparent_editable_text_field.dart';
import '../components/tiles/user_tile.dart';
import '../components/tiles/utility_tile.dart';
import '../util/picture_util.dart';
import '../util/room_name_util.dart';

class GroupChatPage extends StatelessWidget {
  final Map<String, Usr> initialData;

  const GroupChatPage(this.initialData, {super.key});
  
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
          child: StreamBuilder<Map<String, Usr>>(
            initialData: initialData,
            stream: roomMembersState.roomMembersStream,
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
                            
                            Stack(
                              alignment: Alignment.center,
                              clipBehavior: Clip.none,
                              fit: StackFit.loose,
                              children: [
                                // Group chat photo
                                CircleAvatar(
                                  radius: 40,
                                  foregroundImage: (roomState.status == ChatRoomStatus.success && roomState.roomTuple!.room.picture!.isNotEmpty)
                                    ? NetworkImage(roomState.roomTuple!.room.picture!)
                                    : null,
                                  child: Icon(
                                    Icons.person_outlined,
                                    color: Theme.of(context).colorScheme.inversePrimary
                                  )
                                ),
                            
                                // Upload a picture
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(       // TODO make a seperate widget of this stack (it is used here and inside profile_page)
                                    width: 30,            // TODO also maybe make the IconButton navigate to chat page for private_chat_page
                                    height: 30,
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.secondary,
                                      shape: BoxShape.circle
                                    ),
                                    child: IconButton(
                                      padding: EdgeInsets.zero,
                                      onPressed: () => PictureUtil.uploadAndCropPicture(
                                        context,
                                        null,
                                        (imagePath) => context.read<RoomOperationsBloc>().add(
                                          UploadRoomPicture(roomState.roomTuple!.room.id, imagePath)
                                        )
                                      ),
                                      icon: Icon(
                                        Icons.add,
                                        size: 18,
                                        color: Theme.of(context).colorScheme.inversePrimary
                                      )
                                    )
                                  )
                                )
                              ]
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
                              List<Usr>? usrList;
                    
                              String roomName = roomState.roomTuple!.room.name!;
                    
                              if (roomName.isEmpty) {
                                usrList = snapshot.data!.values.toList();
                              }
                    
                              return TransparentEditableTextField(
                                initialText: usrList == null
                                  ? roomName
                                  : RoomNameUtil.getUserNames(usrList),
                                isUpdatedTextLoaded: snapshot.hasData,
                                onSubmission: (text) {
                                  if (roomState.status == ChatRoomStatus.success) {
                                    context.read<RoomOperationsBloc>().add(
                                      UpdateChatRoom(
                                        roomState.roomTuple!.room.copyWith(name: text)
                                      )
                                    );
                                  }
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
                          ),
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
                            child: roomMembersState.status == ChatRoomMembersStatus.loading
                              ? const SizedBox(
                                height: 100,
                                child: CircularProgressIndicator()
                              )
                              : Builder(
                                builder: (context) {
                                  if (!snapshot.hasData) {
                                    return const Center(
                                      child: CircularProgressIndicator()
                                    );
                                  }
                                  
                                  if (snapshot.hasError || snapshot.data!.isEmpty) {
                                    return Text(
                                      "Loading error",
                                      style: TextStyle(
                                        fontSize: 20,
                                        color: Theme.of(context).colorScheme.inversePrimary
                                      )
                                    );
                                  }
                          
                                  var usersList = snapshot.data!.values.toList();
                                  
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
          )
        )
      )
    );
  }
}