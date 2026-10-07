import 'package:flutter_test/flutter_test.dart';
import 'package:aasha/features/emergency/domain/safety_calculator.dart';
import 'package:aasha/features/emergency/domain/nearest_camp.dart';
import 'package:aasha/features/emergency/domain/safety_zone.dart';
import 'package:aasha/data/models/camp.dart';

void main() {
  const radiusKm = 10.0;

  SafetyResult atFraction(double fraction) {
    final distanceDegrees = radiusKm * fraction / 111.195;
    return SafetyCalculator.classify(
      userLatitude: distanceDegrees,
      userLongitude: 0,
      disasterLatitude: 0,
      disasterLongitude: 0,
      radiusKm: radiusKm,
    );
  }

  test('classifies the disaster center as red', () {
    expect(atFraction(0).zone, SafetyZone.red);
  });

  test('classifies 20 percent as red', () {
    expect(atFraction(0.2).zone, SafetyZone.red);
  });

  test('keeps exactly 30 percent red and moves just above it to yellow', () {
    expect(atFraction(0.3).zone, SafetyZone.red);
    expect(atFraction(0.301).zone, SafetyZone.yellow);
  });

  test('classifies 50 percent as yellow', () {
    expect(atFraction(0.5).zone, SafetyZone.yellow);
  });

  test('classifies 80 percent as green', () {
    expect(atFraction(0.8).zone, SafetyZone.green);
  });

  test('keeps exactly 70 percent yellow and moves just above it to green', () {
    expect(atFraction(0.7).zone, SafetyZone.yellow);
    expect(atFraction(0.701).zone, SafetyZone.green);
  });

  test('classifies the radius boundary as green', () {
    expect(atFraction(1).zone, SafetyZone.green);
  });

  test('classifies outside the radius as safe', () {
    expect(atFraction(1.01).zone, SafetyZone.safe);
  });

  test('returns unknown for zero radius and invalid coordinates', () {
    final zeroRadius = SafetyCalculator.classify(
      userLatitude: 0,
      userLongitude: 0,
      disasterLatitude: 0,
      disasterLongitude: 0,
      radiusKm: 0,
    );
    final invalidCoordinates = SafetyCalculator.classify(
      userLatitude: 91,
      userLongitude: 0,
      disasterLatitude: 0,
      disasterLongitude: 0,
      radiusKm: radiusKm,
    );

    expect(zeroRadius.zone, SafetyZone.unknown);
    expect(invalidCoordinates.zone, SafetyZone.unknown);
    expect(
      SafetyCalculator.classify(
        userLatitude: 0,
        userLongitude: 0,
        disasterLatitude: 0,
        disasterLongitude: 0,
        radiusKm: -1,
      ).zone,
      SafetyZone.unknown,
    );
  });

  test('calculates a known one degree latitude distance', () {
    final distance = SafetyCalculator.distanceKmBetween(0, 0, 1, 0);
    expect(distance, closeTo(111.195, 0.2));
  });

  test('finds the nearest active camp with coordinates', () {
    final nearest = findNearestCamp(
      userLatitude: 0,
      userLongitude: 0,
      camps: [
        _camp('far', latitude: 1),
        _camp('near', latitude: .1),
        _camp('inactive', latitude: .01, active: false),
        _camp('missing-location'),
      ],
    );

    expect(nearest?.id, 'near');
  });
}

Camp _camp(String id, {double? latitude, bool active = true}) => Camp(
  id: id,
  name: id,
  locationName: id,
  address: id,
  latitude: latitude,
  longitude: latitude == null ? null : 0,
  contactNumber: '',
  officerName: '',
  officerUid: '',
  active: active,
);
