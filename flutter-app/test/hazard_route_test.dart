import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:aasha/data/models/camp.dart';
import 'package:aasha/features/emergency/domain/hazard_route.dart';
import 'package:aasha/features/emergency/data/hazard_route_repository.dart';
import 'package:aasha/features/emergency/data/models/disaster_zone.dart';
import 'package:aasha/features/emergency/data/models/emergency_alert.dart';

void main() {
  const zone = DisasterZone(
    id: 'z',
    disasterType: 'FLOOD',
    latitude: 0,
    longitude: 0,
    radiusKm: 1,
    severity: EmergencySeverity.critical,
    title: 'Flood',
  );
  final camp = Camp(
    id: 'c',
    name: 'Camp',
    locationName: '',
    address: '',
    latitude: 0,
    longitude: .1,
    contactNumber: '',
    officerName: '',
    officerUid: '',
  );
  test('Crossing between outside vertices is rejected', () {
    expect(
      intersectsHazards([const LatLng(0, -.1), const LatLng(0, .1)], [zone]),
      isTrue,
    );
  });
  test('Detour outside boundary passes', () {
    expect(
      intersectsHazards(
        [
          const LatLng(0, -.1),
          const LatLng(.1, -.1),
          const LatLng(.1, .1),
          const LatLng(0, .1),
        ],
        [zone],
      ),
      isFalse,
    );
  });
  test('Origin inside hazard is rejected', () {
    expect(
      intersectsHazards([const LatLng(0, 0), const LatLng(0, .1)], [zone]),
      isTrue,
    );
  });
  test('100 metre boundary buffer is enforced', () {
    expect(
      intersectsHazards(
        [const LatLng(.0095, -.1), const LatLng(.0095, .1)],
        [zone],
      ),
      isTrue,
    );
  });
  test('Dateline crossing distance is correct', () {
    expect(
      segmentDistanceKm(
        const LatLng(0, 179.9),
        const LatLng(0, -179.9),
        const LatLng(0, 180),
      ),
      lessThan(.01),
    );
  });
  test('Chooses clear road alternative over blocked fastest route', () async {
    final repo = HazardRouteRepository(
      client: MockClient((request) async {
        expect(request.url.queryParameters['overview'], 'full');
        return http.Response(
          jsonEncode({
            'code': 'Ok',
            'routes': [
              {
                'geometry': {
                  'coordinates': [
                    [-.1, 0],
                    [.1, 0],
                  ],
                },
                'distance': 22000,
                'duration': 600,
              },
              {
                'geometry': {
                  'coordinates': [
                    [-.1, 0],
                    [-.1, .1],
                    [.1, .1],
                    [.1, 0],
                  ],
                },
                'distance': 44000,
                'duration': 1200,
              },
            ],
          }),
          200,
        );
      }),
    );
    final result = await repo.find(const LatLng(0, -.1), [camp], [zone]);
    expect(result!.kilometres, 44);
    expect(result.rejected, 1);
    repo.close();
  });
  test('Never returns blocked route as fallback', () async {
    final repo = HazardRouteRepository(
      client: MockClient(
        (_) async => http.Response(
          jsonEncode({
            'code': 'Ok',
            'routes': [
              {
                'geometry': {
                  'coordinates': [
                    [-.1, 0],
                    [.1, 0],
                  ],
                },
                'distance': 22000,
                'duration': 600,
              },
            ],
          }),
          200,
        ),
      ),
    );
    expect(await repo.find(const LatLng(0, -.1), [camp], [zone]), isNull);
    repo.close();
  });
  test('Network failure is explicit', () async {
    final repo = HazardRouteRepository(
      client: MockClient((_) async => http.Response('Unavailable', 503)),
    );
    await expectLater(
      repo.find(const LatLng(0, -.1), [camp], [zone]),
      throwsException,
    );
    repo.close();
  });
}
