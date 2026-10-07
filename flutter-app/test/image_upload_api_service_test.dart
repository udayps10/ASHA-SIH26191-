import 'dart:convert';
import 'dart:typed_data';

import 'package:aasha/features/images/data/image_upload_api_service.dart';
import 'package:aasha/features/images/data/local_image.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  test('serializes a normal image upload as multipart form data', () async {
    late http.BaseRequest sent;
    final client = MockClient((request) async {
      sent = request;
      return http.Response(
        jsonEncode({
          'provider': 'cloudinary',
          'storageId': 'opaque-id',
          'assetId': 'normal/record-1',
          'resourceType': 'image',
          'deliveryType': 'upload',
          'accessType': 'public_normal_result',
          'contentType': 'image/jpeg',
          'sizeBytes': 4,
        }),
        200,
      );
    });
    final image = LocalImage(
      file: XFile.fromData(
        Uint8List.fromList([0, 1, 2, 3]),
        name: 'person.jpg',
        mimeType: 'image/jpeg',
      ),
      bytes: Uint8List.fromList([0, 1, 2, 3]),
      fileName: 'person.jpg',
      mimeType: 'image/jpeg',
    );

    final result = await HttpImageUploadApiService(
      client: client,
      baseUrl: 'http://localhost:8000',
    ).uploadNormalPhoto(recordId: 'record-1', image: image);

    expect(sent, isA<http.Request>());
    final multipart = sent as http.Request;
    expect(multipart.headers['content-type'], contains('multipart/form-data'));
    expect(multipart.body, contains('record-1'));
    expect(multipart.body, contains('person.jpg'));
    expect(result.provider, 'cloudinary');
    expect(result.storageId, 'opaque-id');
  });
}
