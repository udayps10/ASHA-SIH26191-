class Camp {
  final String id;
  final String name;
  final String locationName;
  final String address;
  final double? latitude;
  final double? longitude;
  final String contactNumber;
  final String officerName;
  final String officerUid;
  final bool active;
  final double? locationAccuracy;
  final DateTime? createdAt;

  Camp({
    required this.id,
    required this.name,
    required this.locationName,
    required this.address,
    this.latitude,
    this.longitude,
    required this.contactNumber,
    required this.officerName,
    required this.officerUid,
    this.active = true,
    this.locationAccuracy,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'locationName': locationName,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'contactNumber': contactNumber,
      'officerName': officerName,
      'officerUid': officerUid,
      'active': active,
      'locationAccuracy': locationAccuracy,
    };
  }

  factory Camp.fromMap(String id, Map<String, dynamic> map) {
    return Camp(
      id: id,
      name: map['name'] ?? '',
      locationName: map['locationName'] ?? '',
      address: map['address'] ?? '',
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      contactNumber: map['contactNumber'] ?? '',
      officerName: map['officerName'] ?? '',
      officerUid: map['officerUid'] ?? '',
      active: map['active'] ?? true,
      locationAccuracy: (map['locationAccuracy'] as num?)?.toDouble(),
      createdAt: _parseDate(map['createdAt']),
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    if (value is Map && value.containsKey('seconds')) {
      return DateTime.fromMillisecondsSinceEpoch(value['seconds'] * 1000);
    }
    return null;
  }
}
