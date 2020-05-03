import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class MediaService {
  static MediaService instance = MediaService();

  Future<File> getImageFromLibrary() {
    return ImagePicker.pickImage(source: ImageSource.gallery);
  }

  Future<File> getProfileImageFromLibrary() async {
    File image = await ImagePicker.pickImage(source: ImageSource.gallery);
  
    return (image!=null)?ImageCropper.cropImage(
        sourcePath: image.path,
        maxHeight: 512,
        maxWidth: 512,
        aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
        androidUiSettings: AndroidUiSettings(
          toolbarTitle: 'Crop Image',
          toolbarColor: Colors.grey[300],
          toolbarWidgetColor: Colors.black,
          lockAspectRatio: true,
        ),
        iosUiSettings: IOSUiSettings(
          title: 'Crop Image',
          aspectRatioLockEnabled: true,
          resetAspectRatioEnabled: false,
        )):null;
  }

  Future<File> getImageMessageFromLibrary() async {
    File image = await ImagePicker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      return ImageCropper.cropImage(
          sourcePath: image.path,
          androidUiSettings: AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            toolbarColor: Colors.grey[300],
            toolbarWidgetColor: Colors.black,
          ),
          iosUiSettings: IOSUiSettings(
            title: 'Crop Image',
          ));
    }
    return null;
  }
}
