import 'package:flutter_test/flutter_test.dart';

import 'package:aasha/data/models/camp.dart';
import 'package:aasha/features/emergency/domain/nearest_camp.dart';
import 'package:aasha/features/emergency/domain/safety_calculator.dart';
import 'package:aasha/features/emergency/domain/safety_zone.dart';

void main() {
  test('center safety state uses the existing calculator', () {
    final result = SafetyCalculator.classify(
      userLatitude: 0,
      userLongitude: 0,
      disasterLatitude: 0,
      disasterLongitude: 0,
      radiusKm: 10,
    );

    expect(result.zone, SafetyZone.red);
  });

  test('center uses the nearest active camp only', () {
    final nearest = findNearestCamp(
      userLatitude: 0,
      userLongitude: 0,
      camps: [
        _camp('far', 1),
        _camp('near', .1),
        _camp('inactive', .01, active: false),
      ],
    );

    expect(nearest?.id, 'near');
  });
}

Camp _camp(String id, double latitude, {bool active = true}) => Camp(
  id: id,
  name: id,
  locationName: id,
  address: id,
  latitude: latitude,
  longitude: 0,
  contactNumber: '',
  officerName: '',
  officerUid: '',
  active: active,
);
