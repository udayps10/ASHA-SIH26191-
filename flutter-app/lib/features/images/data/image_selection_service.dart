import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as image_codec;
import 'package:image_picker/image_picker.dart';

import 'local_image.dart';

abstract interface class ImageSelectionService {
  Future<LocalImage?> pickImage({ImageSource source = ImageSource.gallery});

  Future<LocalImage> compressImage(LocalImage image);

  Future<ImageValidationResult> validateImage(LocalImage image);
}

class LocalImageSelectionService implements ImageSelectionService {
  LocalImageSelectionService({ImagePicker? picker})
    : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;
  static const maxBytes = 10 * 1024 * 1024;
  static const allowedMimeTypes = {'image/jpeg', 'image/png', 'image/webp'};

  @override
  Future<LocalImage?> pickImage({
    ImageSource source = ImageSource.gallery,
  }) async {
    final file = await _picker.pickImage(source: source);
    if (file == null) return null;
    final bytes = await file.readAsBytes();
    return LocalImage(
      file: file,
      bytes: bytes,
      fileName: file.name,
      // Android camera providers do not always populate XFile.mimeType.
      // Detect it from the validated bytes so uploads work for both sources.
      mimeType: file.mimeType ?? _detectMimeType(bytes),
    );
  }

  @override
  Future<LocalImage> compressImage(LocalImage image) async {
    // Provider-neutral step: keep the original local file intact. A future
    // upload adapter may resize/compress a copy immediately before upload.
    return image;
  }

  @override
  Future<ImageValidationResult> validateImage(LocalImage image) async {
    if (image.bytes.length > maxBytes) {
      return const ImageValidationResult.invalid(
        'Image exceeds the 10 MB limit.',
      );
    }
    final mimeType = image.mimeType ?? image.file.mimeType;
    final fileName = image.fileName ?? image.file.name;
    final extension = fileName.toLowerCase().split('.').last;
    final detectedMimeType = _detectMimeType(image.bytes);
    if (!allowedMimeTypes.contains(detectedMimeType) ||
        (mimeType != null && mimeType != detectedMimeType) ||
        !{'jpg', 'jpeg', 'png', 'webp'}.contains(extension)) {
      return const ImageValidationResult.invalid('Unsupported image type.');
    }
    final decoded = image_codec.decodeImage(Uint8List.fromList(image.bytes));
    if (decoded == null) {
      return const ImageValidationResult.invalid('Image cannot be read.');
    }
    return const ImageValidationResult.valid();
  }

  String? _detectMimeType(Uint8List bytes) {
    if (bytes.length >= 3 &&
        bytes[0] == 0xff &&
        bytes[1] == 0xd8 &&
        bytes[2] == 0xff) {
      return 'image/jpeg';
    }
    if (bytes.length >= 8 &&
        bytes[0] == 0x89 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x4e &&
        bytes[3] == 0x47 &&
        bytes[4] == 0x0d &&
        bytes[5] == 0x0a &&
        bytes[6] == 0x1a &&
        bytes[7] == 0x0a) {
      return 'image/png';
    }
    if (bytes.length >= 12 &&
        String.fromCharCodes(bytes.sublist(0, 4)) == 'RIFF' &&
        String.fromCharCodes(bytes.sublist(8, 12)) == 'WEBP') {
      return 'image/webp';
    }
    return null;
  }
}
