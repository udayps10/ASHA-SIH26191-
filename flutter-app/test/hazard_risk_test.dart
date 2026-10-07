import 'package:flutter_test/flutter_test.dart';
import 'package:aasha/features/emergency/domain/safety_calculator.dart';
import 'package:aasha/features/emergency/domain/safety_zone.dart';

void main() {
  test('measured flood factors produce red with exact contributions', () {
    const f = HazardFactors(
      rainfallMmhr: 150,
      riverDistanceM: 100,
      elevationM: 410,
    );
    final result = RiskAssessor.evaluate(f);
    expect(result.riskScore, 85);
    expect(result.zone, SafetyZone.red);
    expect(result.factors!.map((v) => v.factorName), [
      'Heavy rainfall',
      'River proximity',
      'Low elevation',
    ]);
    expect(
      result.factors!.fold<double>(0, (sum, v) => sum + v.contributionScore),
      85,
    );
  });
  test('unknown inputs stay unknown and invalid inputs are rejected', () {
    expect(
      RiskAssessor.evaluate(const HazardFactors()).zone,
      SafetyZone.unknown,
    );
    expect(
      () => RiskAssessor.evaluate(const HazardFactors(rainfallMmhr: -1)),
      throwsArgumentError,
    );
    expect(
      () => RiskAssessor.evaluate(const HazardFactors(elevationM: double.nan)),
      throwsArgumentError,
    );
  });
  test('all four score boundaries are consistent', () {
    for (final pair in [
      (29, SafetyZone.green),
      (30, SafetyZone.yellow),
      (49, SafetyZone.yellow),
      (50, SafetyZone.orange),
      (79, SafetyZone.orange),
      (80, SafetyZone.red),
    ]) {
      expect(RiskAssessor.zoneFromScore(pair.$1), pair.$2);
    }
  });
  test('score saturates and forest reduces contributions', () {
    expect(
      RiskAssessor.computeRiskScore(
        const HazardFactors(
          rainfallMmhr: 150,
          riverDistanceM: 100,
          elevationM: 410,
          slopeDeg: 2,
          drainageCapacity: 1,
          historicalFloodIndex: 10,
          landUse: 'urban',
        ),
      ),
      100,
    );
    expect(
      RiskAssessor.computeRiskScore(
        const HazardFactors(rainfallMmhr: 150, landUse: 'forest'),
      ),
      30,
    );
  });
  test('map calculator accepts supplied factors and preserves distances', () {
    final result = SafetyCalculator.classify(
      userLatitude: 0,
      userLongitude: 0,
      disasterLatitude: 0,
      disasterLongitude: 0,
      radiusKm: 10,
      hazardFactors: const HazardFactors(
        rainfallMmhr: 150,
        riverDistanceM: 100,
        elevationM: 410,
      ),
    );
    expect(result.riskScore, 85);
    expect(result.distanceFromDisasterKm, 0);
  });
}
