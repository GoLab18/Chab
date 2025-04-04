import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

/// Utility class for image related operations.
class PictureUtil {

  /// Takes care of fetching a picture from phone's gallery.
  /// 
  /// Requires the [context] of the parent widget, 
  /// [mounted] getter that is supposed to be set null on stateless widget calling this method and
  /// [onImagePicked] function that has an image path [String] for use.
  static Future<void> uploadAndCropPicture(BuildContext context, bool? mounted, void Function(String) onImagePicked) async {
    Color primaryColor = Theme.of(context).colorScheme.primary;
    Color toolbarWidgetColor = Theme.of(context).colorScheme.inversePrimary;
    
    ImagePicker imagePicker = ImagePicker();

    XFile? image = await imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 100
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

    if ((mounted == null || mounted) && croppedImage != null) {
      onImagePicked(croppedImage.path);
    }
  }
}