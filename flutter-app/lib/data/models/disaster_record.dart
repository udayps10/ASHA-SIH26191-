enum RecordStatus { found, atCamp, identified, united }

enum RecordType { normal, critical }

class DisasterRecord {
  final String id;
  final String fullName;
  final int age;
  final String? photoUrl;
  final String? lastKnownClothing;
  final String? clothingPhotoUrl;
  final String camp;
  final String officerName;
  final String officerContact;
  final DateTime dateTimeFound;
  final String? additionalDetails;
  final RecordStatus status;
  final RecordType type;
  final double? matchConfidence;

  DisasterRecord({
    required this.id,
    required this.fullName,
    required this.age,
    this.photoUrl,
    this.lastKnownClothing,
    this.clothingPhotoUrl,
    required this.camp,
    required this.officerName,
    required this.officerContact,
    required this.dateTimeFound,
    this.additionalDetails,
    required this.status,
    required this.type,
    this.matchConfidence,
  });
}
