import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// Presents the two supported local image sources without exposing any
/// storage or upload details to the screens that use it.
Future<ImageSource?> chooseImageSource(BuildContext context) {
  return showModalBottomSheet<ImageSource>(
    context: context,
    builder: (sheetContext) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('Choose from Gallery'),
            onTap: () => Navigator.pop(sheetContext, ImageSource.gallery),
          ),
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text('Take Photo with Camera'),
            onTap: () => Navigator.pop(sheetContext, ImageSource.camera),
          ),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );
}
