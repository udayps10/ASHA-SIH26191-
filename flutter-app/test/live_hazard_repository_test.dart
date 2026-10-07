import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:aasha/features/emergency/data/live_hazard_repository.dart';
import 'package:aasha/features/emergency/domain/safety_zone.dart';

void main() {
  final live = LiveHazard.fromJson({
    'riskScore': 25,
    'rainfallMmhr': 12,
    'elevationM': 42,
  });
  test('live weather never downgrades a reported red zone', () {
    const red = SafetyResult(zone: SafetyZone.red, riskScore: 85, radiusKm: 10);
    expect(live.combine(red), same(red));
  });
  test('weather can increase a lower score and retains distance metadata', () {
    const reported = SafetyResult(
      zone: SafetyZone.green,
      riskScore: 10,
      radiusKm: 10,
      distanceFromDisasterKm: 8,
    );
    final result = live.combine(reported);
    expect(result.riskScore, 25);
    expect(result.radiusKm, 10);
    expect(result.distanceFromDisasterKm, 8);
  });
  test('missing weather cannot erase a reported risk', () {
    final unknown = LiveHazard.fromJson({'riskScore': null, 'elevationM': 42});
    expect(unknown.combine(null).zone, SafetyZone.unknown);
    expect(unknown.details, contains('Rainfall: unavailable'));
    expect(() => LiveHazard.fromJson({'riskScore': 0}), throwsFormatException);
  });
  test('fetch uses configured backend and passes coordinates', () async {
    final repository = LiveHazardRepository(
      baseUrl: 'https://aasha.test',
      client: MockClient((request) async {
        expect(request.url.path, '/api/hazard/risk');
        expect(request.url.queryParameters['lat'], '26.2');
        return http.Response(
          '{"riskScore":25,"rainfallMmhr":12,"elevationM":42}',
          200,
        );
      }),
    );
    expect((await repository.fetch(26.2, 85)).rainfallMmhr, 12);
    repository.close();
  });
  test('provider failure is surfaced for fallback', () async {
    final repository = LiveHazardRepository(
      client: MockClient((_) async => http.Response('{}', 503)),
    );
    await expectLater(repository.fetch(0, 0), throwsStateError);
    repository.close();
  });
}
