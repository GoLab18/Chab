import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import '../blocs/change_usr_info_bloc/change_usr_info_bloc.dart';
import '../blocs/usr_bloc/usr_bloc.dart';
import '../components/editable_field.dart';
import '../components/options_app_bar.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late TextEditingController _captionController;
  late FocusNode _usernameFocusNode;
  late FocusNode _emailFocusNode;
  late FocusNode _captionFocusNode;

  // Boolean flag for handling edit state of user fields and the confirmation button
  bool _isInEditState = false;

  // Boolean flag for showing circular progress indicator if update not finished yet for username
  bool _isUsernameLoaded = true;

  // Boolean flag for showing circular progress indicator if update not finished yet for user email
  bool _isEmailLoaded = true;

  // Boolean flag for handling ChangeUserData event and _isUsernameLoaded flag
  bool usernameChanged = false;

  // Boolean flag for handling ChangeUserData event and _isEmailLoaded flag
  bool emailChanged = false;

  @override
  void initState() {
    super.initState();
    
    _usernameController = TextEditingController();
    _emailController = TextEditingController();
    _captionController = TextEditingController();
    _usernameFocusNode = FocusNode()..addListener(handleFocusChange);
    _emailFocusNode = FocusNode()..addListener(handleFocusChange);
    _captionFocusNode = FocusNode()..addListener(handleFocusChange);
  }

  Future<void> uploadUserPicture() async {
    Color primaryColor = Theme.of(context).colorScheme.primary;
    Color toolbarWidgetColor = Theme.of(context).colorScheme.inversePrimary;
    
    ImagePicker imagePicker = ImagePicker();

    XFile? image = await imagePicker.pickImage(
      source: ImageSource.gallery,
      maxHeight: 320,
      maxWidth: 320,
      imageQuality: 60
    );

    CroppedFile? croppedImage;
    
    if (image != null) {
      croppedImage = await ImageCropper().cropImage(
        sourcePath: image.path,
        aspectRatio: const CropAspectRatio(
          ratioX: 1,
          ratioY: 1
        ),
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: "Crop Image",
            toolbarColor: primaryColor,
            activeControlsWidgetColor: primaryColor,
            toolbarWidgetColor: toolbarWidgetColor,
            aspectRatioPresets: [
              CropAspectRatioPreset.square
            ]
          ),
          IOSUiSettings(
            title: "Crop Image",
            aspectRatioPresets: [
              CropAspectRatioPreset.square
            ]
          )
        ]
      );
    }

    if (croppedImage != null) {
      context.read<ChangeUsrInfoBloc>().add(
        UploadPicture(
          picture: croppedImage!.path,
          userId: context.read<UsrBloc>().state.user!.id
        )
      );
    }
  }

  void handleFocusChange() {
    bool previousIsInEditState = _isInEditState;
    _isInEditState = _usernameFocusNode.hasFocus || _emailFocusNode.hasFocus || _captionFocusNode.hasFocus;
    
    if (previousIsInEditState  != _isInEditState) setState(() {});
  }

  void onEditStateFinished() {
    _usernameFocusNode.unfocus();
    _emailFocusNode.unfocus();
    _captionFocusNode.unfocus();

    usernameChanged = _usernameController.text != context.read<UsrBloc>().state.user!.name;
    emailChanged = _emailController.text != context.read<UsrBloc>().state.user!.email;

    if (usernameChanged || emailChanged) {
      context.read<ChangeUsrInfoBloc>().add(
        ChangeUsrData(
          context.read<UsrBloc>().state.user!.copyWith(
            email: emailChanged ? _emailController.text : null,
            name: usernameChanged ? _usernameController.text : null
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
    _captionController.dispose();
    _usernameFocusNode.removeListener(handleFocusChange);
    _emailFocusNode.removeListener(handleFocusChange);
    _captionFocusNode.removeListener(handleFocusChange);
    _usernameFocusNode.dispose();
    _emailFocusNode.dispose();
    _captionFocusNode.dispose();

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
          if (usernameChanged) _isUsernameLoaded = true;
          if (emailChanged) _isEmailLoaded = true;
          context.read<UsrBloc>().add(UpdateUser(updatedUser: state.user));
        } else if (state is ChangeUsrDataPending) {
          if (usernameChanged) _isUsernameLoaded = false;
          if (emailChanged) _isEmailLoaded = false;
        }
      },
      child: BlocBuilder<UsrBloc, UsrState>(
        builder: (context, state) {
          if (state.status == UsrStatus.success) {
            _usernameController.text = state.user!.name;
            _emailController.text = state.user!.email;
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
                        child: Stack(
                          alignment: Alignment.center,
                          clipBehavior: Clip.none,
                          fit: StackFit.loose,
                          children: [
                            CircleAvatar(
                              radius: 50,
                              foregroundImage: (state.user!.picture.isNotEmpty)
                                  ? NetworkImage(state.user!.picture)
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
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.secondary,
                                  shape: BoxShape.circle
                                ),
                                child: IconButton(
                                  padding: EdgeInsets.zero,
                                  onPressed: uploadUserPicture,
                                  icon: Icon(
                                    Icons.add,
                                    size: 20,
                                    color: Theme.of(context).colorScheme.inversePrimary
                                  )
                                )
                              )
                            )
                          ]
                        )
                      ),

                      // Username
                      EditableField(
                        controller: _usernameController,
                        focusNode: _usernameFocusNode,
                        keyboardType: TextInputType.text,
                        description: "Username",
                        isUpdatedTextLoaded: _isUsernameLoaded
                      ),

                      // Email
                      EditableField(
                        controller: _emailController,
                        focusNode: _emailFocusNode,
                        keyboardType: TextInputType.text,
                        description: "Email",
                        isUpdatedTextLoaded: _isEmailLoaded
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
