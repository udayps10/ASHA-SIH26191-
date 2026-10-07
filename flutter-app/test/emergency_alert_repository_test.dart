import 'dart:convert';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:aasha/core/utils/location_service.dart';
import 'package:aasha/data/local/database/app_database.dart' as local;
import 'package:aasha/data/local/repositories/local_alert_repository.dart';
import 'package:aasha/features/emergency/data/models/emergency_alert.dart';
import 'package:aasha/features/emergency/data/models/user_sos.dart';
import 'package:aasha/features/emergency/data/spring_boot_emergency_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});
  late local.AppDatabase database;

  setUp(() => database = local.AppDatabase(NativeDatabase.memory()));
  tearDown(() => database.close());

  test('parses an active alert response', () async {
    final repository = SpringBootEmergencyRepository(
      client: _JsonClient([_alertJson()]),
      localAlerts: LocalAlertRepository(database),
    );

    final alerts = await repository.getActiveAlerts();

    expect(alerts.single.title, 'Flood warning');
    expect(alerts.single.latitude, 19.1);
    expect(alerts.single.severity, EmergencySeverity.severe);
  });

  test('retains coordinates when an alert has no radius', () async {
    final data = _alertJson()..['radiusKm'] = null;
    final repository = SpringBootEmergencyRepository(
      client: _JsonClient([data]),
      localAlerts: LocalAlertRepository(database),
    );
    final alerts = await repository.getActiveAlerts();
    expect(alerts.single.latitude, 19.1);
    expect(alerts.single.radiusKm, isNull);
    expect(await repository.getActiveDisasterZones(), isEmpty);
  });

  test('serializes the SOS request fields for the backend contract', () {
    final sos = UserSos(
      id: 'sos-1',
      userId: 'user-1',
      latitude: 19.1,
      longitude: 72.9,
      accuracy: 8,
      message: 'Need help',
      createdAt: DateTime(2026, 9, 17, 12),
      status: UserSosStatus.pending,
    );

    expect(sos.toJson()['id'], 'sos-1');
    expect(sos.toJson()['userId'], 'user-1');
    expect(sos.toJson()['status'], 'pending');
    expect(sos.toJson()['createdAt'], '2026-09-17T12:00:00.000');
  });

  test('skips malformed records without failing the list', () async {
    final repository = SpringBootEmergencyRepository(
      client: _JsonClient([
        _alertJson(),
        {'title': 'Malformed'},
      ]),
      localAlerts: LocalAlertRepository(database),
    );

    final alerts = await repository.getActiveAlerts();

    expect(alerts, hasLength(1));
  });

  test('uses cached alerts after a network failure', () async {
    final local = LocalAlertRepository(database);
    final cached = EmergencyAlert.fromJson(_alertJson());
    await local.replaceActive([cached]);
    final repository = SpringBootEmergencyRepository(
      client: _FailingClient(),
      localAlerts: local,
    );

    final alerts = await repository.getActiveAlerts();

    expect(repository.lastFetchUsedCache, isTrue);
    expect(alerts.single.id, cached.id);
  });

  test('calculates relevance only for geographic alerts', () async {
    final repository = SpringBootEmergencyRepository(
      client: _JsonClient([_alertJson(), _alertJsonWithoutLocation()]),
      localAlerts: LocalAlertRepository(database),
    );
    final alerts = await repository.getActiveAlerts();
    final location = LocationResult(
      latitude: 19.1,
      longitude: 72.9,
      accuracy: 8,
    );

    expect(repository.distanceFromUser(alerts[0], location), closeTo(0, 0.01));
    expect(repository.distanceFromUser(alerts[1], location), isNull);
  });
}

Map<String, dynamic> _alertJson() => {
  'id': 7,
  'title': 'Flood warning',
  'message': 'Move to higher ground.',
  'type': 'FLOOD',
  'severity': 'SEVERE',
  'district': 'Raigad',
  'state': 'Maharashtra',
  'latitude': 19.1,
  'longitude': 72.9,
  'radiusKm': 10,
  'active': true,
  'createdAt': '2026-09-17T12:00:00',
};

Map<String, dynamic> _alertJsonWithoutLocation() => {
  'id': 8,
  'title': 'General warning',
  'message': 'Follow official instructions.',
  'type': 'WEATHER',
  'severity': 'MODERATE',
  'createdAt': '2026-09-17T12:00:00',
};

class _JsonClient extends http.BaseClient {
  _JsonClient(this.value);

  final List<Map<String, dynamic>> value;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    return http.StreamedResponse(
      Stream.value(utf8.encode(jsonEncode(value))),
      200,
      request: request,
    );
  }
}

class _FailingClient extends http.BaseClient {
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    return Future.error(const SocketException('offline'));
  }
}
