import 'dart:math' as math;
import 'package:latlong2/latlong.dart';
import '../data/models/disaster_zone.dart';

/// Minimum great-circle segment distance, including crossings between vertices.
double segmentDistanceKm(LatLng a, LatLng b, LatLng point) {
  const distance = Distance();
  final ab = distance(a, b) / 6371000;
  final ap = distance(a, point) / 6371000;
  if (ab < 1e-12) return ap * 6371;
  double bearing(LatLng from, LatLng to) {
    final p = from.latitudeInRad, q = to.latitudeInRad;
    final d = to.longitudeInRad - from.longitudeInRad;
    return math.atan2(
      math.sin(d) * math.cos(q),
      math.cos(p) * math.sin(q) - math.sin(p) * math.cos(q) * math.cos(d),
    );
  }

  final angle = bearing(a, point) - bearing(a, b);
  final along = math.atan2(math.sin(ap) * math.cos(angle), math.cos(ap));
  if (along < 0 || along > ab) {
    return math.min(distance(a, point), distance(b, point)) / 1000;
  }
  return math.asin((math.sin(ap) * math.sin(angle)).clamp(-1.0, 1.0)).abs() *
      6371;
}

bool intersectsHazards(List<LatLng> points, Iterable<DisasterZone> zones) {
  if (points.length < 2) return true;
  for (final zone in zones.where((z) => z.active)) {
    final center = LatLng(zone.latitude, zone.longitude);
    for (var i = 1; i < points.length; i++) {
      // Full affected boundary plus a 100 m buffer, not just the red core.
      if (segmentDistanceKm(points[i - 1], points[i], center) <=
          zone.radiusKm + .1) {
        return true;
      }
    }
  }
  return false;
}
