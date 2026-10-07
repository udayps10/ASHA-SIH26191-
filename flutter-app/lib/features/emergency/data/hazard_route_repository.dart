import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import '../../../data/models/camp.dart';
import '../domain/hazard_route.dart';
import 'models/disaster_zone.dart';

class CheckedCampRoute {
  final Camp camp;
  final List<LatLng> points;
  final double kilometres;
  final double minutes;
  final int rejected;
  const CheckedCampRoute(
    this.camp,
    this.points,
    this.kilometres,
    this.minutes,
    this.rejected,
  );
}

class HazardRouteRepository {
  final http.Client _client;
  HazardRouteRepository({http.Client? client})
    : _client = client ?? http.Client();
  void close() => _client.close();

  Future<CheckedCampRoute?> find(
    LatLng start,
    List<Camp> camps,
    List<DisasterZone> zones,
  ) async {
    const distance = Distance();
    final candidates =
        camps
            .where(
              (c) =>
                  c.active &&
                  c.latitude != null &&
                  c.longitude != null &&
                  c.latitude!.isFinite &&
                  c.longitude!.isFinite &&
                  c.latitude!.abs() <= 90 &&
                  c.longitude!.abs() <= 180,
            )
            .toList()
          ..sort(
            (a, b) => distance(
              start,
              LatLng(a.latitude!, a.longitude!),
            ).compareTo(distance(start, LatLng(b.latitude!, b.longitude!))),
          );
    var rejected = 0;
    var failures = 0;
    CheckedCampRoute? best;
    for (final camp in candidates.take(3)) {
      final end = LatLng(camp.latitude!, camp.longitude!);
      if (zones.any(
        (z) =>
            z.active &&
            distance(end, LatLng(z.latitude, z.longitude)) / 1000 <=
                z.radiusKm + .1,
      )) {
        rejected++;
        continue;
      }
      try {
        final uri = Uri.https(
          'router.project-osrm.org',
          '/route/v1/driving/${start.longitude},${start.latitude};${end.longitude},${end.latitude}',
          {
            'alternatives': 'true',
            'geometries': 'geojson',
            'overview': 'full',
            'radiuses': '100;100',
          },
        );
        final response = await _client
            .get(uri)
            .timeout(const Duration(seconds: 10));
        if (response.statusCode != 200) {
          throw const FormatException('Routing unavailable');
        }
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        if (data['code'] == 'NoRoute' || data['code'] == 'NoSegment') continue;
        if (data['code'] != 'Ok') {
          throw const FormatException('Routing unavailable');
        }
        for (final route in data['routes'] as List) {
          final points = (route['geometry']['coordinates'] as List)
              .map(
                (p) =>
                    LatLng((p[1] as num).toDouble(), (p[0] as num).toDouble()),
              )
              .toList();
          if (points.length < 2 ||
              points.any(
                (p) =>
                    !p.latitude.isFinite ||
                    !p.longitude.isFinite ||
                    p.latitude.abs() > 90 ||
                    p.longitude.abs() > 180,
              )) {
            throw const FormatException('Invalid route geometry');
          }
          // Also check connectors from the requested points to snapped roads.
          if (intersectsHazards([start, ...points, end], zones)) {
            rejected++;
            continue;
          }
          final km = (route['distance'] as num).toDouble() / 1000;
          final minutes = (route['duration'] as num).toDouble() / 60;
          if (!km.isFinite || !minutes.isFinite || km < 0 || minutes < 0) {
            throw const FormatException('Invalid route');
          }
          if (best == null || minutes < best.minutes) {
            best = CheckedCampRoute(camp, points, km, minutes, rejected);
          }
        }
      } catch (_) {
        failures++;
      }
    }
    if (best != null) {
      return CheckedCampRoute(
        best.camp,
        best.points,
        best.kilometres,
        best.minutes,
        rejected,
      );
    }
    if (failures > 0) {
      throw Exception(
        'Road routing unavailable. Try again with an internet connection.',
      );
    }
    return null;
  }
}
