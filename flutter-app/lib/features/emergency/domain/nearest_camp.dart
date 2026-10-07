import '../../../data/models/camp.dart';
import 'safety_calculator.dart';

Camp? findNearestCamp({
  required double userLatitude,
  required double userLongitude,
  required Iterable<Camp> camps,
}) {
  Camp? nearest;
  var nearestDistance = double.infinity;

  for (final camp in camps) {
    if (!camp.active || camp.latitude == null || camp.longitude == null) {
      continue;
    }
    final distance = SafetyCalculator.distanceKmBetween(
      userLatitude,
      userLongitude,
      camp.latitude!,
      camp.longitude!,
    );
    if (distance < nearestDistance) {
      nearest = camp;
      nearestDistance = distance;
    }
  }
  return nearest;
}
