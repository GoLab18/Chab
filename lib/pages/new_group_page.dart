import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:user_repository/user_repository.dart';

import '../blocs/search_bloc/search_bloc.dart';
import '../components/fields/transparent_editable_text_field.dart';
import '../components/search_bar_delegate.dart';
import '../components/tiles/add_group_member_tile.dart';
import '../cubits/staged_members_cubit.dart';
import '../util/picture_util.dart';

class NewGroupPage extends StatefulWidget {
  final String currUserId;

  const NewGroupPage(this.currUserId, {super.key});

  @override
  State<NewGroupPage> createState() => _NewGroupPageState();
}

class _NewGroupPageState extends State<NewGroupPage> {
  String? selectedImagePath;
  String selectedGroupName = "New Group";
  
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
                        
                        Stack(
                          alignment: Alignment.center,
                          clipBehavior: Clip.none,
                          fit: StackFit.loose,
                          children: [
                            // Group chat photo pick
                            CircleAvatar(
                              radius: 40,
                              foregroundImage: selectedImagePath == null ? null : FileImage(File(selectedImagePath!)),
                              child: Icon(
                                Icons.people_outlined,
                                color: Theme.of(context).colorScheme.inversePrimary
                              )
                            ),
                        
                            // Add a picture
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
                                  onPressed: () {
                                    PictureUtil.uploadAndCropPicture(
                                      context,
                                      null,
                                      (imagePath) {
                                        setState(() {
                                          selectedImagePath = imagePath;
                                        });
                                      }
                                    );
                                  },
                                  icon: Icon(
                                    Icons.add,
                                    size: 18,
                                    color: Theme.of(context).colorScheme.inversePrimary
                                  )
                                )
                              )
                            )
                          ]
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
                    // TODO create room
                  },
                  icon: Icon(Icons.check),
                  color: Theme.of(context).colorScheme.inversePrimary
                ),
              ]
            ),
        
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 0,
                  bottom: 6
                ),
                child: Divider(
                  color: Theme.of(context).colorScheme.tertiary
                )
              )
            ),
        
            // Added members
            BlocBuilder<StagedMembersCubit, List<Usr>>(
              builder: (context, stagedMembers) {
                return SliverList.builder(
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
                searchTarget: SearchTarget.members,
                currUserId: widget.currUserId,
                searchBloc: context.read<SearchBloc>(),
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