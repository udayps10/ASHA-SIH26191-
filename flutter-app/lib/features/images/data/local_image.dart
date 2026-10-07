import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';

class LocalImage {
  const LocalImage({
    required this.file,
    required this.bytes,
    this.fileName,
    this.mimeType,
  });

  final XFile file;
  final Uint8List bytes;
  final String? fileName;
  final String? mimeType;
}

class ImageValidationResult {
  const ImageValidationResult.valid() : isValid = true, message = null;
  const ImageValidationResult.invalid(this.message) : isValid = false;

  final bool isValid;
  final String? message;
}
