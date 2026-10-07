import '../../domain/safety_calculator.dart';
import 'emergency_alert.dart';

class DisasterZone {
  final String id;
  final String disasterType;
  final double latitude;
  final double longitude;
  final double radiusKm;
  final EmergencySeverity severity;
  final String title;
  final bool active;
  final HazardFactors? hazardFactors;

  const DisasterZone({
    required this.id,
    required this.disasterType,
    required this.latitude,
    required this.longitude,
    required this.radiusKm,
    required this.severity,
    required this.title,
    this.active = true,
    this.hazardFactors,
  });
}
