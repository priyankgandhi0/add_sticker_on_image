import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

extension BuildExtension on BuildContext {
  Future<void> pickImage({
    required Function(File file) onImageChoose,
    ImageSource source = ImageSource.gallery,
  }) async {
    ImagePicker picker = ImagePicker();
    var status = await (Platform.isIOS
        ? Permission.storage.request()
        : source == ImageSource.camera
            ? Permission.camera.request()
            : Permission.mediaLibrary.request());

    if (status.isGranted) {
      XFile? pickedFile = await picker.pickImage(source: source);
      if (pickedFile != null) {
        onImageChoose(File(pickedFile.path));
      }
    } else if (status.isDenied) {
      ScaffoldMessenger.of(this).showSnackBar(
        SnackBar(
          content: Text(
            'Without this permission app can not access the image.',
          ),
          action: SnackBarAction(
            label: 'Settings',
            textColor: Colors.white,
            onPressed: () {
              openAppSettings();
              ScaffoldMessenger.of(this).hideCurrentSnackBar();
            },
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else if (status.isPermanentlyDenied) {
      ScaffoldMessenger.of(this).showSnackBar(
        SnackBar(
          content: Text(
            'To access this feature please grant permission from settings.',
          ),
          action: SnackBarAction(
            label: 'Settings',
            textColor: Colors.white,
            onPressed: () {
              openAppSettings();
              ScaffoldMessenger.of(this).hideCurrentSnackBar();
            },
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
