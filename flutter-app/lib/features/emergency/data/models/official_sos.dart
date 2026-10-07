enum OfficialSosStatus { received, acknowledged, resolved, cancelled }

class OfficialSos {
  final String id;
  final String userUid;
  final double latitude;
  final double longitude;
  final double accuracy;
  final String? message;
  final OfficialSosStatus status;
  final DateTime createdAt;
  final DateTime receivedAt;
  final DateTime updatedAt;

  const OfficialSos({
    required this.id,
    required this.userUid,
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    this.message,
    required this.status,
    required this.createdAt,
    required this.receivedAt,
    required this.updatedAt,
  });

  factory OfficialSos.fromJson(Map<String, dynamic> json) {
    final status = OfficialSosStatus.values.firstWhere(
      (value) =>
          value.name.toUpperCase() == json['status']?.toString().toUpperCase(),
      orElse: () => throw const FormatException('Invalid SOS status'),
    );
    return OfficialSos(
      id: _requiredText(json['id']),
      userUid: _requiredText(json['userUid']),
      latitude: _requiredNumber(json['latitude']),
      longitude: _requiredNumber(json['longitude']),
      accuracy: _requiredNumber(json['accuracy']),
      message: json['message'] as String?,
      status: status,
      createdAt: _requiredDate(json['createdAt']),
      receivedAt: _requiredDate(json['receivedAt']),
      updatedAt: _requiredDate(json['updatedAt']),
    );
  }

  static String _requiredText(dynamic value) {
    if (value is String && value.trim().isNotEmpty) return value;
    throw const FormatException('Missing SOS text field');
  }

  static double _requiredNumber(dynamic value) {
    final number = value is num ? value.toDouble() : double.tryParse('$value');
    if (number != null && number.isFinite) return number;
    throw const FormatException('Invalid SOS number field');
  }

  static DateTime _requiredDate(dynamic value) {
    final date = value is DateTime
        ? value
        : DateTime.tryParse(value?.toString() ?? '');
    if (date != null) return date;
    throw const FormatException('Invalid SOS timestamp');
  }
}
