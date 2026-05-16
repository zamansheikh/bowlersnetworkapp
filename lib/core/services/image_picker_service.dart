import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:injectable/injectable.dart';

/// Crop shape passed to [ImagePickerService.pickAndCrop]. `circle` is for
/// avatars (the cropper renders a circular cutout but still writes a
/// square JPEG); `rect` is for cover photos with a custom aspect ratio.
enum CropShape { circle, rect }

/// Thin wrapper around `image_picker` + `image_cropper`. Returns bytes +
/// filename so callers can hand the pair straight to
/// [CloudUploadService.uploadFile].
///
/// Keeps feature code free of `XFile` / `CroppedFile` juggling, and makes
/// it trivial to swap in a fake picker in tests.
@lazySingleton
class ImagePickerService {
  final ImagePicker _picker = ImagePicker();
  final ImageCropper _cropper = ImageCropper();

  /// Pick a single image from [source]. Returns null if the user cancels.
  Future<PickedMedia?> pickImage({
    int imageQuality = 82,
    ImageSource source = ImageSource.gallery,
  }) async {
    final x = await _picker.pickImage(
      source: source,
      imageQuality: imageQuality,
    );
    if (x == null) return null;
    final bytes = await x.readAsBytes();
    return PickedMedia(bytes: bytes, name: x.name);
  }

  /// Pick from [source], then open the in-app cropper. Returns null if
  /// the user cancels either step. [aspectRatio] is width / height (1.0
  /// for square, 16/5 for the wide profile cover, etc.). [shape] only
  /// affects the cropper's UI overlay — the file written out is always
  /// a rectangular JPEG.
  Future<PickedMedia?> pickAndCrop({
    required ImageSource source,
    required double aspectRatio,
    required CropShape shape,
    int imageQuality = 90,
    String title = 'Crop',
    Color? accentColor,
  }) async {
    final picked = await _picker.pickImage(
      source: source,
      imageQuality: imageQuality,
    );
    if (picked == null) return null;
    final cropped = await _cropper.cropImage(
      sourcePath: picked.path,
      compressFormat: ImageCompressFormat.jpg,
      compressQuality: imageQuality,
      aspectRatio: CropAspectRatio(
        ratioX: aspectRatio,
        ratioY: 1,
      ),
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: title,
          toolbarColor: const Color(0xFF101010),
          toolbarWidgetColor: Colors.white,
          backgroundColor: const Color(0xFF101010),
          activeControlsWidgetColor: accentColor,
          cropStyle: shape == CropShape.circle
              ? CropStyle.circle
              : CropStyle.rectangle,
          hideBottomControls: false,
          lockAspectRatio: true,
        ),
        IOSUiSettings(
          title: title,
          aspectRatioLockEnabled: true,
          resetAspectRatioEnabled: false,
          cropStyle: shape == CropShape.circle
              ? CropStyle.circle
              : CropStyle.rectangle,
        ),
      ],
    );
    if (cropped == null) return null;
    final file = File(cropped.path);
    final bytes = await file.readAsBytes();
    // image_cropper appends a unique suffix to the file name — derive a
    // friendly name from the original pick so the upload uses .jpg.
    final originalName = picked.name;
    final dot = originalName.lastIndexOf('.');
    final base = dot > 0 ? originalName.substring(0, dot) : originalName;
    return PickedMedia(bytes: bytes, name: '$base.jpg');
  }

  /// Multiple images (for photo-posts). Returns an empty list on cancel.
  Future<List<PickedMedia>> pickImages({int imageQuality = 82, int? limit}) async {
    final xs = await _picker.pickMultiImage(
      imageQuality: imageQuality,
      limit: limit,
    );
    final out = <PickedMedia>[];
    for (final x in xs) {
      final bytes = await x.readAsBytes();
      out.add(PickedMedia(bytes: bytes, name: x.name));
    }
    return out;
  }

  /// Pick a video file (max duration the backend accepts = 90s, but we
  /// let the caller enforce that after picking).
  Future<PickedMedia?> pickVideo() async {
    final x = await _picker.pickVideo(source: ImageSource.gallery);
    if (x == null) return null;
    final bytes = await x.readAsBytes();
    return PickedMedia(bytes: bytes, name: x.name);
  }
}

class PickedMedia {
  const PickedMedia({required this.bytes, required this.name});

  final Uint8List bytes;
  final String name;
}
