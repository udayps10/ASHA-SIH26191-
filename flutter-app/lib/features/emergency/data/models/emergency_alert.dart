enum EmergencySeverity { low, moderate, severe, critical }

class EmergencyAlert {
  final String id;
  final String title;
  final String message;
  final String disasterType;
  final EmergencySeverity severity;
  final String? district;
  final String? state;
  final double? latitude;
  final double? longitude;
  final double? radiusKm;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final bool active;

  const EmergencyAlert({
    required this.id,
    required this.title,
    required this.message,
    required this.disasterType,
    required this.severity,
    this.district,
    this.state,
    this.latitude,
    this.longitude,
    this.radiusKm,
    required this.createdAt,
    this.expiresAt,
    this.active = true,
  });

  factory EmergencyAlert.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final title = json['title'];
    final type = json['type'];
    final createdAt = _dateTime(json['createdAt']);
    if (id == null ||
        title is! String ||
        title.trim().isEmpty ||
        type is! String ||
        type.trim().isEmpty ||
        createdAt == null) {
      throw const FormatException('Invalid emergency alert');
    }
    final latitude = _number(json['latitude']);
    final longitude = _number(json['longitude']);
    // NDMA alerts often omit a radius; give mapped alerts a visible local zone.
    final radiusKm =
        _number(json['radiusKm']) ??
        (latitude != null && longitude != null ? 10.0 : null);
    if ((latitude == null) != (longitude == null) ||
        (radiusKm != null && (latitude == null || longitude == null)) ||
        (latitude != null &&
            (!latitude.isFinite || latitude < -90 || latitude > 90)) ||
        (longitude != null &&
            (!longitude.isFinite || longitude < -180 || longitude > 180)) ||
        (radiusKm != null && (!radiusKm.isFinite || radiusKm <= 0))) {
      throw const FormatException('Invalid emergency alert location');
    }
    return EmergencyAlert(
      id: id.toString(),
      title: title.trim(),
      message: json['message'] is String ? json['message'] as String : '',
      disasterType: type.trim(),
      severity: _severity(json['severity']),
      district: _text(json['district']),
      state: _text(json['state']),
      latitude: latitude,
      longitude: longitude,
      radiusKm: radiusKm,
      createdAt: createdAt,
      expiresAt: _dateTime(json['expiresAt']),
      active: json['active'] is bool ? json['active'] as bool : true,
    );
  }

  static EmergencySeverity _severity(dynamic value) {
    final normalized = value?.toString().toLowerCase();
    return EmergencySeverity.values.firstWhere(
      (severity) => severity.name == normalized,
      orElse: () => EmergencySeverity.moderate,
    );
  }

  static String? _text(dynamic value) =>
      value is String && value.trim().isNotEmpty ? value.trim() : null;

  static double? _number(dynamic value) {
    if (value is num) return value.toDouble();
    return value is String ? double.tryParse(value) : null;
  }

  static DateTime? _dateTime(dynamic value) {
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}
