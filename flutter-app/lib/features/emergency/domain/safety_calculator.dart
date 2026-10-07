import 'dart:math' as math;
import 'safety_zone.dart';

/// Supply measured values only. Missing factors are not inferred from alerts.
class HazardFactors {
  final double? rainfallMmhr,
      elevationM,
      slopeDeg,
      riverDistanceM,
      drainageCapacity,
      historicalFloodIndex;
  final String? landUse;
  const HazardFactors({
    this.rainfallMmhr,
    this.elevationM,
    this.slopeDeg,
    this.riverDistanceM,
    this.drainageCapacity,
    this.historicalFloodIndex,
    this.landUse,
  });
}

/// Rule-based contributions, not SHAP or a trained probability model.
class RiskAssessor {
  static const redMin = 80, orangeMin = 50, yellowMin = 30;
  static SafetyZone zoneFromScore(int score) => score >= redMin
      ? SafetyZone.red
      : score >= orangeMin
      ? SafetyZone.orange
      : score >= yellowMin
      ? SafetyZone.yellow
      : SafetyZone.green;

  static List<SafetyFactor> contributions(HazardFactors f) {
    final values = <SafetyFactor>[];
    void add(String name, double points) => values.add(
      SafetyFactor(
        factorName: name,
        contributionScore: points.abs(),
        isNegative: points < 0,
      ),
    );
    void validate(double? value, String name, double min, double max) {
      if (value != null && (!value.isFinite || value < min || value > max)) {
        throw ArgumentError('Invalid $name');
      }
    }

    validate(f.rainfallMmhr, 'rainfall', 0, 2000);
    validate(f.elevationM, 'elevation', -500, 9000);
    validate(f.slopeDeg, 'slope', 0, 90);
    validate(f.riverDistanceM, 'river distance', 0, 40000000);
    validate(f.drainageCapacity, 'drainage', 0, 10);
    validate(f.historicalFloodIndex, 'history', 0, 10);
    final rain = f.rainfallMmhr;
    if (rain != null) {
      add(
        rain > 120
            ? 'Heavy rainfall'
            : rain > 80
            ? 'Moderate rainfall'
            : 'Reported rainfall',
        rain > 120
            ? 35
            : rain > 80
            ? 25
            : rain > 0
            ? 10
            : 0,
      );
    }
    final river = f.riverDistanceM;
    if (river != null) {
      add(
        'River proximity',
        river <= 150
            ? 30
            : river <= 300
            ? 22
            : 0,
      );
    }
    final elevation = f.elevationM;
    if (elevation != null) {
      add(
        elevation < 430 ? 'Low elevation' : 'Elevation',
        elevation < 430 ? 20 : 0,
      );
    }
    final slope = f.slopeDeg;
    if (slope != null) {
      add(
        'Flat terrain',
        slope < 5
            ? 10
            : slope < 15
            ? 5
            : 0,
      );
    }
    final drainage = f.drainageCapacity;
    if (drainage != null) {
      add(
        'Limited drainage',
        drainage <= 3
            ? 15
            : drainage <= 5
            ? 5
            : 0,
      );
    }
    final history = f.historicalFloodIndex;
    if (history != null) add('Historical flood risk', history * 1.5);
    final land = f.landUse?.toLowerCase().trim();
    if (land != null) {
      add(
        land == 'forest' || land == 'green' ? 'Vegetation cover' : 'Land use',
        land == 'urban' || land == 'concrete'
            ? 8
            : land == 'forest' || land == 'green'
            ? -5
            : 0,
      );
    }
    return values;
  }

  static int computeRiskScore(HazardFactors f) => contributions(f)
      .fold<double>(
        0,
        (sum, v) =>
            sum + (v.isNegative ? -v.contributionScore : v.contributionScore),
      )
      .clamp(0, 100)
      .round();
  static String buildExplanation(HazardFactors f, int score) {
    final factors = contributions(f).where((v) => v.contributionScore > 0);
    return factors.isEmpty
        ? 'No contributing measurements available'
        : factors.map((v) => v.factorName).join('\n');
  }

  static SafetyResult evaluate(
    HazardFactors f, {
    double? distanceKm,
    double? radiusKm,
  }) {
    final factors = contributions(f);
    if (factors.isEmpty) return const SafetyResult(zone: SafetyZone.unknown);
    final score = computeRiskScore(f);
    return SafetyResult(
      zone: zoneFromScore(score),
      riskScore: score,
      distanceFromDisasterKm: distanceKm,
      radiusKm: radiusKm,
      factors: factors.where((v) => v.contributionScore > 0).toList(),
    );
  }
}

class SafetyCalculator {
  static const double redThreshold = 0.30;
  static const double yellowThreshold = 0.70;
  static const double earthRadiusKm = 6371.0;

  static SafetyResult classify({
    required double userLatitude,
    required double userLongitude,
    required double disasterLatitude,
    required double disasterLongitude,
    required double radiusKm,
    HazardFactors? hazardFactors,
  }) {
    if (!_validCoordinate(userLatitude, userLongitude) ||
        !_validCoordinate(disasterLatitude, disasterLongitude) ||
        !radiusKm.isFinite ||
        radiusKm <= 0) {
      return const SafetyResult(zone: SafetyZone.unknown);
    }

    final distanceKm = distanceKmBetween(
      userLatitude,
      userLongitude,
      disasterLatitude,
      disasterLongitude,
    );
    if (hazardFactors != null) {
      final measured = RiskAssessor.evaluate(
        hazardFactors,
        distanceKm: distanceKm,
        radiusKm: radiusKm,
      );
      if (measured.zone != SafetyZone.unknown) return measured;
    }
    final percentage = distanceKm / radiusKm;
    final zone = percentage <= redThreshold
        ? SafetyZone.red
        : percentage <= yellowThreshold
        ? SafetyZone.yellow
        : percentage <= 1
        ? SafetyZone.green
        : SafetyZone.safe;

    return SafetyResult(
      zone: zone,
      distanceFromDisasterKm: distanceKm,
      radiusKm: radiusKm,
      percentageOfRadius: percentage,
      riskScore: percentage <= redThreshold
          ? (100 - percentage / redThreshold * 20).round().clamp(80, 100)
          : percentage <= yellowThreshold
          ? (49 -
                    (percentage - redThreshold) /
                        (yellowThreshold - redThreshold) *
                        19)
                .round()
                .clamp(30, 49)
          : percentage <= 1
          ? (29 - (percentage - yellowThreshold) / (1 - yellowThreshold) * 28)
                .round()
                .clamp(1, 29)
          : null,
      factors: [
        SafetyFactor(
          factorName: percentage <= 1
              ? 'Within reported disaster radius (${distanceKm.toStringAsFixed(1)} km from center); proximity estimate'
              : 'Outside reported disaster radius; local hazard measurements unavailable',
          contributionScore: 0,
        ),
      ],
    );
  }

  static double distanceKmBetween(
    double firstLatitude,
    double firstLongitude,
    double secondLatitude,
    double secondLongitude,
  ) {
    if (!_validCoordinate(firstLatitude, firstLongitude) ||
        !_validCoordinate(secondLatitude, secondLongitude)) {
      return double.nan;
    }

    final latitudeDelta = _radians(secondLatitude - firstLatitude);
    final longitudeDelta = _radians(secondLongitude - firstLongitude);
    final firstLatitudeRadians = _radians(firstLatitude);
    final secondLatitudeRadians = _radians(secondLatitude);
    final a =
        math.pow(math.sin(latitudeDelta / 2), 2) +
        math.cos(firstLatitudeRadians) *
            math.cos(secondLatitudeRadians) *
            math.pow(math.sin(longitudeDelta / 2), 2);
    final centralAngle = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadiusKm * centralAngle;
  }

  static bool _validCoordinate(double latitude, double longitude) {
    return latitude.isFinite &&
        longitude.isFinite &&
        latitude >= -90 &&
        latitude <= 90 &&
        longitude >= -180 &&
        longitude <= 180;
  }

  static double _radians(double degrees) => degrees * math.pi / 180;
}
