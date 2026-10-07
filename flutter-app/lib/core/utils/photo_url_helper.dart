import 'dart:convert';
import '../config/api_config.dart';

class PhotoUrlHelper {
  PhotoUrlHelper._();

  /// Convert stored normal-photo references to a public delivery URL.
  /// 
  /// Matches the logic in main.py:_normal_photo_url.
  static String? getDisplayUrl(String? photoValue) {
    if (photoValue == null || photoValue.isEmpty) {
      return null;
    }
    
    if (photoValue.startsWith('http://') || photoValue.startsWith('https://')) {
      return photoValue;
    }
    
    // Relative URL from our backend (e.g. /api/v1/images/file/...)
    if (photoValue.startsWith('/')) {
      return '${ApiConfig.matchingBaseUrl}$photoValue';
    }
    
    String? storageId;
    try {
      final decoded = json.decode(photoValue);
      if (decoded is Map) {
        storageId = (decoded['storageId'] ?? decoded['storage_id']) as String?;
      } else if (decoded is String) {
        storageId = decoded;
      }
    } catch (_) {
      storageId = photoValue;
    }
    
    if (storageId != null && storageId.isNotEmpty) {
      if (storageId.startsWith('cloudinary|')) {
        return _getCloudinaryUrl(storageId);
      }
    }
    
    return null;
  }

  static String? _getCloudinaryUrl(String storageId) {
    // storageId: cloudinary|resource_type|delivery_type|public_id
    // Example: cloudinary|image|upload|disasterconnect/normal/local_normal_uid_123
    final parts = storageId.split('|');
    if (parts.length == 4 && parts[0] == 'cloudinary') {
      final cloudName = const String.fromEnvironment('CLOUDINARY_CLOUD_NAME', defaultValue: 'disasterconnect');
      final resourceType = parts[1];
      final deliveryType = parts[2];
      final publicId = parts[3];
      
      // The publicId already contains the folder (e.g. disasterconnect/normal/...)
      // The correct Cloudinary URL format is:
      // https://res.cloudinary.com/<cloud_name>/<resource_type>/<delivery_type>/<public_id>
      return 'https://res.cloudinary.com/$cloudName/$resourceType/$deliveryType/$publicId';
    }
    return null;
  }
}
