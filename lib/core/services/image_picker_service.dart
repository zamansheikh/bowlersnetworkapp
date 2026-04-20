import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';
import 'package:injectable/injectable.dart';

/// Thin wrapper around `image_picker`. Returns bytes + filename so callers
/// can hand the pair straight to [CloudUploadService.uploadFile].
///
/// Keeps feature code free of `XFile` juggling, and makes it trivial to
/// swap in a fake picker in tests.
@lazySingleton
class ImagePickerService {
  final ImagePicker _picker = ImagePicker();

  /// Pick a single image from the gallery. Returns null if the user cancels.
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
