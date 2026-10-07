import 'dart:io';

import 'package:path_provider/path_provider.dart';

import 'local_image.dart';

/// Keeps the selected bytes on the device until the existing sync queue has
/// successfully uploaded them. It never places image bytes in Firestore.
class LocalImageStore {
  const LocalImageStore();

  Future<String> save(LocalImage image, {required String prefix}) async {
    final directory = await getApplicationDocumentsDirectory();
    final imagesDirectory = Directory(
      '${directory.path}${Platform.pathSeparator}pending_images',
    );
    await imagesDirectory.create(recursive: true);
    final extension = (image.fileName ?? image.file.name).split('.').last;
    final path =
        '${imagesDirectory.path}${Platform.pathSeparator}${prefix}_${DateTime.now().microsecondsSinceEpoch}.$extension';
    await File(path).writeAsBytes(image.bytes, flush: true);
    return path;
  }
}
