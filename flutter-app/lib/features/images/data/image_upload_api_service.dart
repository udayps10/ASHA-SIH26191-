import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../../../core/config/api_config.dart';
import '../../../core/utils/authenticated_client.dart';
import 'image_storage_reference.dart';
import 'local_image.dart';

abstract interface class ImageUploadApiService {
  Future<ImageStorageReference> uploadNormalPhoto({
    required String recordId,
    required LocalImage image,
  });

  Future<ImageStorageReference> uploadCriticalPhoto({
    required String recordId,
    required LocalImage image,
  });

  Future<ImageStorageReference> uploadCriticalClothing({
    required String recordId,
    required LocalImage image,
  });

  Future<ImageStorageReference> uploadMatchInput({
    required String requestId,
    required LocalImage image,
  });

  Future<void> deleteTemporary(String assetId);

  Future<String?> getImageUrl(String storageId);
}

class HttpImageUploadApiService implements ImageUploadApiService {
  HttpImageUploadApiService({http.Client? client, String? baseUrl})
    : _client = client ?? AuthenticatedClient(),
      _baseUrl = (baseUrl ?? ApiConfig.matchingBaseUrl).replaceFirst(
        RegExp(r'/$'),
        '',
      );

  final http.Client _client;
  final String _baseUrl;
  static const _timeout = Duration(seconds: 30);

  @override
  Future<ImageStorageReference> uploadNormalPhoto({
    required String recordId,
    required LocalImage image,
  }) => _upload('/api/v1/images/normal', 'record_id', recordId, image);

  @override
  Future<ImageStorageReference> uploadCriticalPhoto({
    required String recordId,
    required LocalImage image,
  }) => _upload('/api/v1/images/critical', 'record_id', recordId, image);

  @override
  Future<ImageStorageReference> uploadCriticalClothing({
    required String recordId,
    required LocalImage image,
  }) =>
      _upload('/api/v1/images/critical-clothing', 'record_id', recordId, image);

  @override
  Future<ImageStorageReference> uploadMatchInput({
    required String requestId,
    required LocalImage image,
  }) => _upload('/api/v1/images/match-input', 'request_id', requestId, image);

  @override
  Future<void> deleteTemporary(String assetId) async {
    try {
      final response = await _client
          .delete(
            Uri.parse(
              '$_baseUrl/api/v1/images/temporary/${Uri.encodeComponent(assetId)}',
            ),
          )
          .timeout(_timeout);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ImageUploadApiException(
          response.statusCode,
          _message(response.body),
        );
      }
    } on ImageUploadApiException {
      rethrow;
    } on TimeoutException {
      throw ImageUploadApiException(0, 'Image cleanup timed out.');
    } on SocketException {
      throw ImageUploadApiException(0, 'Image storage is unavailable.');
    }
  }

  @override
  Future<String?> getImageUrl(String storageId) async {
    // storageId is the relative path (e.g. "normal/id/photo.jpg")
    if (storageId.startsWith('/')) return '$_baseUrl$storageId';
    if (storageId.startsWith('http')) return storageId;
    return '$_baseUrl/api/v1/images/file/$storageId';
  }

  Future<ImageStorageReference> _upload(
    String path,
    String identifierName,
    String identifier,
    LocalImage image,
  ) async {
    final mime =
        image.mimeType ??
        image.file.mimeType ??
        _mimeTypeFromFileName(image.fileName ?? image.file.name);
    if (mime.isEmpty) {
      throw const ImageUploadApiException(400, 'Image type is unknown.');
    }
    final request = http.MultipartRequest('POST', Uri.parse('$_baseUrl$path'))
      ..fields[identifierName] = identifier
      ..files.add(
        http.MultipartFile.fromBytes(
          'file',
          image.bytes,
          filename: image.fileName ?? image.file.name,
          contentType: MediaType.parse(mime),
        ),
      );
    try {
      final response = await _client.send(request).timeout(_timeout);
      final body = await response.stream.bytesToString();
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ImageUploadApiException(response.statusCode, _message(body));
      }
      final decoded = jsonDecode(body);
      if (decoded is! Map) {
        throw const FormatException('Image response is not an object');
      }
      return ImageStorageReference.fromJson(Map<String, dynamic>.from(decoded));
    } on ImageUploadApiException {
      rethrow;
    } on TimeoutException {
      throw ImageUploadApiException(0, 'Image upload timed out.');
    } on SocketException {
      throw ImageUploadApiException(0, 'Image storage is unavailable.');
    } on FormatException {
      throw ImageUploadApiException(
        0,
        'Image storage returned an invalid response.',
      );
    }
  }

  String _mimeTypeFromFileName(String fileName) {
    return switch (fileName.toLowerCase().split('.').last) {
      'jpg' || 'jpeg' => 'image/jpeg',
      'png' => 'image/png',
      'webp' => 'image/webp',
      _ => '',
    };
  }

  String _message(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map && decoded['detail'] is String) {
        return decoded['detail'] as String;
      }
      if (decoded is Map && decoded['message'] is String) {
        return decoded['message'] as String;
      }
    } catch (_) {}
    return 'Image upload failed.';
  }
}

class ImageUploadApiException implements Exception {
  const ImageUploadApiException(this.statusCode, this.message);
  final int statusCode;
  final String message;

  @override
  String toString() => 'ImageUploadApiException($statusCode): $message';
}
