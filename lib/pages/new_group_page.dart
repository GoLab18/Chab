import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:user_repository/user_repository.dart';

import '../blocs/room_operations_bloc/room_operations_bloc.dart';
import '../blocs/search_bloc/search_bloc.dart';
import '../blocs/usr_bloc/usr_bloc.dart';
import '../components/avatar_action.dart';
import '../components/fields/transparent_editable_text_field.dart';
import '../components/prompts/is_empty_message_widget.dart';
import '../components/search_bar_delegate.dart';
import '../components/tiles/add_group_member_tile.dart';
import '../cubits/staged_members_cubit.dart';
import '../util/picture_util.dart';

class NewGroupPage extends StatefulWidget {
  const NewGroupPage({super.key});

  @override
  State<NewGroupPage> createState() => _NewGroupPageState();
}

class _NewGroupPageState extends State<NewGroupPage> {
  String? selectedImagePath;
  String selectedGroupName = "Group";
  
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: false,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              floating: true,
              expandedHeight: 186.0,
              flexibleSpace: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: FlexibleSpaceBar(
                  background: Center(
                    child: Column(
                      children: [
                        const SizedBox(height: 80),

                        AvatarAction(
                          radius: 40,
                          avatarImage: selectedImagePath == null ? null : FileImage(File(selectedImagePath!)),
                          circleAvatarBackgroundIconData: Icons.people_outlined,
                          actionContainerSize: 30,
                          actionIcon: Icon(
                            Icons.add,
                            size: 18,
                            color: Theme.of(context).colorScheme.inversePrimary
                          ),
                          onActionPressed: () {
                            PictureUtil.uploadAndCropPicture(
                              context,
                              null,
                              (imagePath) {
                                setState(() {
                                  selectedImagePath = imagePath;
                                });
                              }
                            );
                          }
                        ),
        
                        // Selected chat group name
                        Padding(
                          padding: const EdgeInsets.only(top: 18, left: 16, right: 16),
                          child: TransparentEditableTextField(
                            initialText: selectedGroupName,
                            isUpdatedTextLoaded: true,
                            onSubmission: (text) {
                              setState(() {
                                selectedGroupName = text;
                              });
                            }
                          )
                        )
                      ]
                    )
                  )
                )
              ),
              actions: [
                IconButton(
                  onPressed: () {
                    var newMembers = context.read<StagedMembersCubit>().state;
                    newMembers.add(context.read<UsrBloc>().state.user!);

                    context.read<RoomOperationsBloc>().add(CreateGroupChatRoom(selectedGroupName, selectedImagePath, newMembers));

                    Navigator.pop(context); // TODO don't tell me this is the problem here
                  },
                  icon: Icon(Icons.check),
                  color: Theme.of(context).colorScheme.inversePrimary
                ),
              ]
            ),

            // Chosen members info
            BlocBuilder<StagedMembersCubit, List<Usr>>(
              builder: (context, stagedMembers) {
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Container(
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
                              "Chosen Members",
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.inversePrimary
                              )
                            ),
                        
                            // Members amount
                            Text(
                              stagedMembers.length.toString(),
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.secondary
                              )
                            )
                          ]
                        )
                      )
                    )
                  )
                );
              }
            ),

            // Added members
            BlocBuilder<StagedMembersCubit, List<Usr>>(
              builder: (context, stagedMembers) {
                return stagedMembers.isNotEmpty
                  ? SliverList.builder(
                  itemCount: stagedMembers.length,
                  itemBuilder: (context, index) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: AddGroupMemberTile(
                      user: stagedMembers[index],
                      callbackIcon: Icons.clear_outlined,
                      isMemberSubjectToAddition: false,
                      onButtonInvoked: (user) {
                        context.read<StagedMembersCubit>().unstageMember(user);
                      }
                    )
                  )
                )
                : SliverFillRemaining(
                  hasScrollBody: false,
                  child: IsEmptyMessageWidget(
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.tertiary,
                    text: "No staged members yet",
                    iconData: Icons.people_outlined,
                  ),
                );
              }
            )
          ]
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.inversePrimary,
          shape: const CircleBorder(),
          onPressed: () {
            showSearch(
              context: context,
              delegate: SearchBarDelegate(
                searchTarget: SearchTarget.newGroupMembers,
                searchBloc: context.read<SearchBloc>(),
                usrBloc: context.read<UsrBloc>(),
                stagedMembersCubit: context.read<StagedMembersCubit>()
              )
            );
          },
          child: const Icon(Icons.person_add_alt_outlined)
        )
      )
    );
  }
}