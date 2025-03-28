import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/change_usr_info_bloc/change_usr_info_bloc.dart';
import '../blocs/usr_bloc/usr_bloc.dart';
import '../components/avatar_action.dart';
import '../components/fields/dynamic_editable_field.dart';
import '../components/fields/editable_field.dart';
import '../components/app_bars/options_app_bar.dart';
import '../util/picture_util.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late TextEditingController _bioController;
  late FocusNode _usernameFocusNode;
  late FocusNode _emailFocusNode;
  late FocusNode _bioFocusNode;

  // Boolean flag for handling edit state of user fields and the confirmation button
  bool _isInEditState = false;

  // Boolean flag for showing circular progress indicator if update not finished yet for username
  bool _isUsernameLoaded = true;

  // Boolean flag for showing circular progress indicator if update not finished yet for user email
  bool _isEmailLoaded = true;

  // Boolean flag for showing circular progress indicator if update not finished yet for user bio
  bool _isBioLoaded = true;

  // Boolean flag for handling ChangeUserData event and _isUsernameLoaded flag
  bool _usernameChanged = false;

  // Boolean flag for handling ChangeUserData event and _isEmailLoaded flag
  bool _emailChanged = false;

  // Boolean flag for handling ChangeUserData event and _isBioLoaded flag
  bool _bioChanged = false;

  @override
  void initState() {
    super.initState();
    
    _usernameController = TextEditingController(text: context.read<UsrBloc>().state.user!.name);
    _emailController = TextEditingController(text: context.read<UsrBloc>().state.user!.email);
    _bioController = TextEditingController(text: context.read<UsrBloc>().state.user!.bio);
    _usernameFocusNode = FocusNode()..addListener(handleFocusChange);
    _emailFocusNode = FocusNode()..addListener(handleFocusChange);
    _bioFocusNode = FocusNode()..addListener(handleFocusChange);
  }

  void handleFocusChange() {
    bool previousIsInEditState = _isInEditState;
    _isInEditState = _usernameFocusNode.hasFocus || _emailFocusNode.hasFocus || _bioFocusNode.hasFocus;
    
    if (previousIsInEditState  != _isInEditState) setState(() {});
  }

  void onEditStateFinished() {
    _usernameFocusNode.unfocus();
    _emailFocusNode.unfocus();
    _bioFocusNode.unfocus();

    _usernameChanged = _usernameController.text != context.read<UsrBloc>().state.user!.name;
    _emailChanged = _emailController.text != context.read<UsrBloc>().state.user!.email;
    _bioChanged = _bioController.text != context.read<UsrBloc>().state.user!.bio;

    if (_usernameChanged || _emailChanged || _bioChanged) {
      context.read<ChangeUsrInfoBloc>().add(
        ChangeUsrData(
          context.read<UsrBloc>().state.user!.copyWith(
            email: _emailChanged ? _emailController.text : null,
            name: _usernameChanged ? _usernameController.text : null,
            bio: _bioChanged ? _bioController.text : null
          )
        )
      );
    }

    setState(() {
    _isInEditState = false;
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _bioController.dispose();
    _usernameFocusNode.removeListener(handleFocusChange);
    _emailFocusNode.removeListener(handleFocusChange);
    _bioFocusNode.removeListener(handleFocusChange);
    _usernameFocusNode.dispose();
    _emailFocusNode.dispose();
    _bioFocusNode.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ChangeUsrInfoBloc, ChangeUsrInfoState>(
      listener: (context, state) {
        if (state is UploadPictureSuccess) {
          final updatedUser = context.read<UsrBloc>().state.user!.copyWith(picture: state.pictureStorageUrl);

          context.read<UsrBloc>().add(
            UpdateUser(
              updatedUser: updatedUser
            )
          );
        } else if (state is ChangeUsrDataSuccess) {
          if (_usernameChanged) _isUsernameLoaded = true;
          if (_emailChanged) _isEmailLoaded = true;
          if (_bioChanged) _isBioLoaded = true;

          context.read<UsrBloc>().add(UpdateUser(updatedUser: state.user));
        } else if (state is ChangeUsrDataPending) {
          if (_usernameChanged) _isUsernameLoaded = false;
          if (_emailChanged) _isEmailLoaded = false;
          if (_bioChanged) _isBioLoaded = false;
        }
      },
      child: BlocBuilder<UsrBloc, UsrState>(
        builder: (context, state) {
          if (state.status == UsrStatus.success) {
            if (_usernameChanged) _usernameController.text = state.user!.name;
            if (_emailChanged) _emailController.text = state.user!.email;
            if (_bioChanged) _bioController.text = state.user!.bio;
          }

          return Scaffold(
            appBar: OptionsAppBar(
              titleText: "Profile",
              isInEditState: _isInEditState,
              onEditStateFinished: onEditStateFinished,
            ),
            body: Center(
              child: switch (state.status) {
                UsrStatus.success => SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Profile picture
                      Padding(
                        padding: const EdgeInsets.only(bottom: 30),
                        child: AvatarAction(
                          radius: 50,
                          avatarImage: state.user!.picture.isNotEmpty
                            ? NetworkImage(state.user!.picture)
                            : null,
                          circleAvatarBackgroundIconData: Icons.person_outlined,
                          actionContainerSize: 36,
                          actionIcon: Icon(
                            Icons.add,
                            size: 20,
                            color: Theme.of(context).colorScheme.inversePrimary
                          ),
                          onActionPressed: () {
                            PictureUtil.uploadAndCropPicture(
                              context,
                              mounted,
                              (imagePath) => context.read<ChangeUsrInfoBloc>().add(
                                UploadPicture(
                                  picture: imagePath,
                                  userId: context.read<UsrBloc>().state.user!.id
                                )
                              )
                            );
                          }
                        )
                      ),

                      // Username
                      DynamicEditableField(
                        controller: _usernameController,
                        focusNode: _usernameFocusNode,
                        keyboardType: TextInputType.text,
                        description: "Username",
                        isUpdatedTextLoaded: _isUsernameLoaded,
                        maxChars: 20,
                        hintText: "Username.."
                      ),

                      // Email
                      EditableField(
                        controller: _emailController,
                        focusNode: _emailFocusNode,
                        keyboardType: TextInputType.text,
                        description: "Email",
                        isUpdatedTextLoaded: _isEmailLoaded,
                        hintText: "Email.."
                      ),

                      // Bio
                      DynamicEditableField(
                        controller: _bioController,
                        focusNode: _bioFocusNode,
                        keyboardType: TextInputType.text,
                        description: "Your bio",
                        isUpdatedTextLoaded: _isBioLoaded,
                        maxChars: 70,
                        hintText: "Present yourself.."
                      )
                    ]
                  )
                ),
                UsrStatus.loading => const CircularProgressIndicator(),
                UsrStatus.failure => Text(
                  "Loading error",
                  style: TextStyle(
                    fontSize: 30,
                    color: Theme.of(context).colorScheme.inversePrimary
                  )
                )
              }
            )
          );
        }
      )
    );
  }
}
