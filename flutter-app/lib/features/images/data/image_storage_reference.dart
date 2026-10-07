class ImageStorageReference {
  const ImageStorageReference({
    required this.provider,
    required this.storageId,
    required this.assetId,
    required this.resourceType,
    required this.deliveryType,
    required this.accessType,
    required this.contentType,
    required this.sizeBytes,
  });

  final String provider;
  final String storageId;
  final String assetId;
  final String resourceType;
  final String deliveryType;
  final String accessType;
  final String contentType;
  final int sizeBytes;

  Map<String, dynamic> toJson() => {
    'provider': provider,
    'storageId': storageId,
    'assetId': assetId,
    'resourceType': resourceType,
    'deliveryType': deliveryType,
    'accessType': accessType,
    'contentType': contentType,
    'sizeBytes': sizeBytes,
  };

  factory ImageStorageReference.fromJson(Map<String, dynamic> json) {
    String stringValue(String camel, String snake) {
      final value = json[camel] ?? json[snake];
      if (value is! String || value.isEmpty) {
        throw FormatException('Missing or invalid image field: $camel');
      }
      return value;
    }

    final size = json['sizeBytes'] ?? json['size_bytes'];
    if (size is! num) {
      throw const FormatException('Missing or invalid image field: sizeBytes');
    }
    return ImageStorageReference(
      provider: stringValue('provider', 'provider'),
      storageId: stringValue('storageId', 'storage_id'),
      assetId: stringValue('assetId', 'asset_id'),
      resourceType: stringValue('resourceType', 'resource_type'),
      deliveryType: stringValue('deliveryType', 'delivery_type'),
      accessType: stringValue('accessType', 'access_type'),
      contentType: stringValue('contentType', 'content_type'),
      sizeBytes: size.toInt(),
    );
  }
}
