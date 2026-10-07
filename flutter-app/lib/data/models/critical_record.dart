// ignore: constant_identifier_names
enum CriticalRecordStatus {
  // ignore: constant_identifier_names
  CRITICAL,
  // ignore: constant_identifier_names
  IDENTIFIED,
  // ignore: constant_identifier_names
  CONFIRMED_DECEASED,
  // ignore: constant_identifier_names
  RELEASED_TO_FAMILY,
}

class CriticalRecord {
  final String id;
  final String name;
  final int age;

  final String? photoUrl;
  final String? clothingPhotoUrl;
  final String? photoLocalPath;
  final String? clothingPhotoLocalPath;
  final String lastKnownClothing;

  final String campId;
  final String campName;

  final String officerUid;
  final String officerName;
  final String officerContact;

  final String foundLocation;
  final double? foundLatitude;
  final double? foundLongitude;
  final double? locationAccuracy;

  final String additionalDetails;
  final CriticalRecordStatus status;

  final DateTime foundAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  CriticalRecord({
    required this.id,
    required this.name,
    required this.age,
    this.photoUrl,
    this.clothingPhotoUrl,
    this.photoLocalPath,
    this.clothingPhotoLocalPath,
    required this.lastKnownClothing,
    required this.campId,
    required this.campName,
    required this.officerUid,
    required this.officerName,
    required this.officerContact,
    required this.foundLocation,
    this.foundLatitude,
    this.foundLongitude,
    this.locationAccuracy,
    required this.additionalDetails,
    required this.status,
    required this.foundAt,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'age': age,
      'photoUrl': photoUrl,
      'clothingPhotoUrl': clothingPhotoUrl,
      'lastKnownClothing': lastKnownClothing,
      'campId': campId,
      'campName': campName,
      'officerUid': officerUid,
      'officerName': officerName,
      'officerContact': officerContact,
      'foundLocation': foundLocation,
      'foundLatitude': foundLatitude,
      'foundLongitude': foundLongitude,
      'locationAccuracy': locationAccuracy,
      'additionalDetails': additionalDetails,
      'status': status.name,
      'foundAt': foundAt.toIso8601String(),
    };
  }

  factory CriticalRecord.fromMap(String id, Map<String, dynamic> map) {
    return CriticalRecord(
      id: id,
      name: map['name'] ?? '',
      age: map['age'] ?? 0,
      photoUrl: map['photoUrl'],
      clothingPhotoUrl: map['clothingPhotoUrl'],
      photoLocalPath: map['photoLocalPath'],
      clothingPhotoLocalPath: map['clothingPhotoLocalPath'],
      lastKnownClothing: map['lastKnownClothing'] ?? '',
      campId: map['campId'] ?? '',
      campName: map['campName'] ?? '',
      officerUid: map['officerUid'] ?? '',
      officerName: map['officerName'] ?? '',
      officerContact: map['officerContact'] ?? '',
      foundLocation: map['foundLocation'] ?? '',
      foundLatitude: (map['foundLatitude'] as num?)?.toDouble(),
      foundLongitude: (map['foundLongitude'] as num?)?.toDouble(),
      locationAccuracy: (map['locationAccuracy'] as num?)?.toDouble(),
      additionalDetails: map['additionalDetails'] ?? '',
      status: CriticalRecordStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => CriticalRecordStatus.CRITICAL,
      ),
      foundAt: _parseDate(map['foundAt']) ?? DateTime.now(),
      createdAt: _parseDate(map['createdAt']),
      updatedAt: _parseDate(map['updatedAt']),
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
