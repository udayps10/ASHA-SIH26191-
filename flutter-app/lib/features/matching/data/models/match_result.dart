abstract class MatchResult {
  MatchResult({
    required this.recordId,
    required this.name,
    required this.age,
    required this.campName,
    required this.officerName,
    required this.officerContact,
    required this.matchConfidence,
    this.matchLabel,
    this.explanation,
  });

  final String recordId;
  final String name;
  final int age;
  final String campName;
  final String officerName;
  final String officerContact;
  /// Supplied by the future AI service; Flutter does not calculate it.
  final num matchConfidence;
  final String? matchLabel;
  final String? explanation;
}

class NormalMatchResult extends MatchResult {
  NormalMatchResult({
    required super.recordId,
    required super.name,
    required super.age,
    required super.campName,
    required super.officerName,
    required super.officerContact,
    required super.matchConfidence,
    super.matchLabel,
    super.explanation,
    this.photoUrl,
    this.status,
  });

  final String? photoUrl;
  final String? status;

  factory NormalMatchResult.fromJson(Map<String, dynamic> json) {
    return NormalMatchResult(
      recordId: _requiredString(json, 'recordId', 'record_id'),
      name: _requiredString(json, 'name'),
      age: _requiredInt(json, 'age'),
      photoUrl: _optionalString(json, 'photoUrl', 'photo_url'),
      campName: _requiredString(json, 'campName', 'camp_name'),
      officerName: _requiredString(json, 'officerName', 'officer_name'),
      officerContact: _requiredString(json, 'officerContact', 'officer_contact'),
      status: json['status'] as String?,
      matchConfidence: _requiredNum(
        json,
        'matchConfidence',
        'match_score',
        'match_confidence',
      ),
      matchLabel: _optionalString(json, 'matchLabel', 'match_label'),
      explanation: json['explanation'] as String?,
    );
  }
}

class CriticalMatchResult extends MatchResult {
  CriticalMatchResult({
    required super.recordId,
    required super.name,
    required super.age,
    required super.campName,
    required super.officerName,
    required super.officerContact,
    required super.matchConfidence,
    super.matchLabel,
    super.explanation,
    this.lastKnownClothing,
  });

  final String? lastKnownClothing;

  factory CriticalMatchResult.fromJson(Map<String, dynamic> json) {
    // This intentionally maps only the public safe fields. There is no
    // photoUrl or clothingPhotoUrl property on this presentation model.
    return CriticalMatchResult(
      recordId: _requiredString(json, 'recordId', 'record_id'),
      name: _requiredString(json, 'name'),
      age: _requiredInt(json, 'age'),
      lastKnownClothing: _optionalString(json, 'lastKnownClothing', 'last_known_clothing'),
      campName: _requiredString(json, 'campName', 'camp_name'),
      officerName: _requiredString(json, 'officerName', 'officer_name'),
      officerContact: _requiredString(json, 'officerContact', 'officer_contact'),
      matchConfidence: _requiredNum(
        json,
        'matchConfidence',
        'match_score',
        'match_confidence',
      ),
      matchLabel: _optionalString(json, 'matchLabel', 'match_label'),
      explanation: json['explanation'] as String?,
    );
  }
}

String _requiredString(Map<String, dynamic> json, String key, [String? alias]) {
  final value = json[key] ?? (alias == null ? null : json[alias]);
  return value is String ? value : '';
}

int _requiredInt(Map<String, dynamic> json, String key, [String? alias]) {
  final value = json[key] ?? (alias == null ? null : json[alias]);
  if (value is int) return value;
  if (value is num) return value.toInt();
  return 0;
}

num _requiredNum(
  Map<String, dynamic> json,
  String key,
  [String? alias,
  String? secondAlias]
) {
  final value = json[key] ??
      (alias == null ? null : json[alias]) ??
      (secondAlias == null ? null : json[secondAlias]);
  if (value is num) return value;
  return 0;
}

String? _optionalString(Map<String, dynamic> json, String key, String alias) {
  final value = json[key] ?? json[alias];
  return value is String ? value : null;
}
