import 'dart:convert';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:aasha/data/local/database/app_database.dart';
import 'package:aasha/data/sync/sync_service.dart';
import 'package:aasha/features/emergency/data/emergency_repository.dart';
import 'package:aasha/features/emergency/data/models/user_sos.dart';
import 'package:aasha/features/emergency/data/spring_boot_emergency_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});
  late AppDatabase database;

  setUp(() => database = AppDatabase(NativeDatabase.memory()));
  tearDown(() => database.close());

  test('posts an authenticated SOS and reports confirmed receipt', () async {
    final client = _RecordingClient(201, '{}');
    final sync = _onlineSync(database);
    final repository = SpringBootEmergencyRepository(
      client: client,
      syncService: sync,
      tokenProvider: () async => 'jwt-token',
      baseUrl: 'http://backend.test',
    );

    final result = await repository.submitSos(_sos('success'));

    expect(result.state, SosDeliveryState.submitted);
    expect(client.request.headers['Authorization'], 'Bearer jwt-token');
    final body = jsonDecode(client.body) as Map<String, dynamic>;
    expect(body['id'], 'success');
    expect(body.containsKey('userId'), isFalse);
    expect(
      (await sync.queue.getByStatus('completed')).single.entityId,
      'success',
    );
  });

  test('does not report success for unauthorized responses', () async {
    final sync = _onlineSync(database);
    final repository = SpringBootEmergencyRepository(
      client: _RecordingClient(401, '{}'),
      syncService: sync,
      tokenProvider: () async => 'expired-token',
    );

    final result = await repository.submitSos(_sos('unauthorized'));

    expect(result.state, SosDeliveryState.pendingLocal);
    expect(
      (await sync.queue.getByStatus('failed')).single.entityId,
      'unauthorized',
    );
    expect(result.message, isNot(contains('sent')));
  });

  test('does not report success after a network failure', () async {
    final sync = _onlineSync(database);
    final repository = SpringBootEmergencyRepository(
      client: _FailingClient(),
      syncService: sync,
      tokenProvider: () async => 'jwt-token',
    );

    final result = await repository.submitSos(_sos('offline'));

    expect(result.state, SosDeliveryState.pendingLocal);
    expect((await sync.queue.getByStatus('failed')).single.entityId, 'offline');
  });

  test('serializes all client SOS metadata', () {
    final json = _sos('serialized').toJson();

    expect(json['id'], 'serialized');
    expect(json['userId'], 'user-1');
    expect(json['latitude'], 19.1);
    expect(json['longitude'], 72.9);
    expect(json['accuracy'], 8.0);
    expect(json['message'], 'Need help');
    expect(json['status'], 'pending');
  });
}

SyncService _onlineSync(AppDatabase database) =>
    SyncService(database: database, internetCheck: () async => true)
      ..ownerUid = 'user-1';

UserSos _sos(String id) => UserSos(
  id: id,
  userId: 'user-1',
  latitude: 19.1,
  longitude: 72.9,
  accuracy: 8,
  message: 'Need help',
  createdAt: DateTime(2026, 9, 17, 12),
  status: UserSosStatus.pending,
);

class _RecordingClient extends http.BaseClient {
  _RecordingClient(this.statusCode, this.responseBody);

  final int statusCode;
  final String responseBody;
  late http.BaseRequest request;
  late String body;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    this.request = request;
    body = await request.finalize().bytesToString();
    return http.StreamedResponse(
      Stream.value(utf8.encode(responseBody)),
      statusCode,
      request: request,
    );
  }
}

class _FailingClient extends http.BaseClient {
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) =>
      Future.error(const SocketException('offline'));
}
