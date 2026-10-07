import 'dart:typed_data';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as image_codec;
import 'package:image_picker/image_picker.dart';
import 'package:aasha/features/images/data/image_selection_service.dart';
import 'package:aasha/features/images/data/local_image.dart';

void main() {
  final service = LocalImageSelectionService();

  Future<ImageValidationResult> validate(
    Uint8List bytes,
    String name,
    String mimeType,
  ) {
    final file = XFile.fromData(bytes, mimeType: mimeType);
    return service.validateImage(
      LocalImage(file: file, bytes: bytes, fileName: name, mimeType: mimeType),
    );
  }

  test('valid JPEG, PNG, and WEBP images are accepted', () async {
    final source = image_codec.Image(width: 2, height: 2);
    final jpeg = await validate(Uint8List.fromList(image_codec.encodeJpg(source)), 'a.jpg', 'image/jpeg');
    final png = await validate(Uint8List.fromList(image_codec.encodePng(source)), 'a.png', 'image/png');
    expect(jpeg.isValid, isTrue, reason: jpeg.message);
    expect(png.isValid, isTrue, reason: png.message);
    final webp = base64Decode(
      'UklGRjoAAABXRUJQVlA4IC4AAACQAQCdASoCAAIAAUAmJaACdLoAA5gA/vtV4/+lwf/S4P/pcH/pcH8bss4bpAAA',
    );
    final webpResult = await validate(webp, 'a.webp', 'image/webp');
    expect(webpResult.isValid, isTrue, reason: webpResult.message);
  });

  test('unsupported and oversized images are rejected', () async {
    expect((await validate(Uint8List.fromList([1, 2, 3]), 'a.exe', 'application/octet-stream')).isValid, isFalse);
    expect((await validate(Uint8List.fromList(List.filled(LocalImageSelectionService.maxBytes + 1, 0)), 'a.jpg', 'image/jpeg')).isValid, isFalse);
  });
}
