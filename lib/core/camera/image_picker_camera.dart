import 'dart:io';

import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import 'camera_capture_controller.dart';

/// Uses the system camera UI; photos are never added to the public gallery.
class ImagePickerCamera implements PhotoCamera {
  ImagePickerCamera({ImagePicker? picker}) : _picker = picker ?? ImagePicker();
  final ImagePicker _picker;

  @override
  Future<String?> takePhoto() async {
    if (!Platform.isAndroid && !Platform.isIOS) {
      throw const CameraCaptureException(
        'Camera capture is available on Android and iPhone.',
      );
    }
    try {
      return (await _picker.pickImage(
        source: ImageSource.camera,
        requestFullMetadata: false,
      ))?.path;
    } on PlatformException catch (e) {
      throw CameraCaptureException(switch (e.code) {
        'camera_access_denied' ||
        'camera_access_restricted' ||
        'camera_access_denied_without_prompt' => 'Camera access is blocked. Allow camera access in device Settings, then try again.',
        'no_available_camera' ||
        'camera_unavailable' => 'No camera is available on this device.',
        _ => 'Could not open the camera. Please try again.',
      });
    }
  }

  /// Call at Android startup. Recovered photos must be presented for review,
  /// never auto-saved. The caller owns cleanup of returned cache paths.
  Future<List<String>> recoverLostPhotos() async {
    if (!Platform.isAndroid) return [];
    final response = await _picker.retrieveLostData();
    if (response.exception != null) {
      throw const CameraCaptureException(
        'An interrupted camera capture could not be recovered. Please try again.',
      );
    }
    return response.files?.map((file) => file.path).toList() ?? [];
  }
}
