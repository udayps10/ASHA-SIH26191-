import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:aasha/features/emergency/data/emergency_repository.dart';
import 'package:aasha/features/emergency/data/models/user_sos.dart';
import 'package:aasha/data/local/database/app_database.dart';
import 'package:aasha/data/sync/sync_service.dart';

void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() => database.close());

  test('local repository exposes no unverified alerts or disasters', () async {
    final sync = SyncService(
      database: database,
      internetCheck: () async => false,
    )..ownerUid = 'user-1';
    final repository = LocalEmergencyRepository(syncService: sync);
    final sos = UserSos(
      id: 'local-test',
      userId: 'user-1',
      latitude: 19,
      longitude: 72,
      accuracy: 10,
      createdAt: DateTime(2026, 1, 1),
      status: UserSosStatus.pending,
    );

    expect(await repository.getActiveAlerts(), isEmpty);
    expect(await repository.getActiveDisasterZones(), isEmpty);
    final result = await repository.submitSos(sos);

    expect(result.state, SosDeliveryState.pendingLocal);
    expect(result.message, contains('saved locally'));
    final entry = (await sync.queue.getPending()).single;
    expect(entry.entityType, 'user_sos');
    expect(entry.payload['id'], sos.id);
    expect(entry.payload['userId'], sos.userId);
    expect(entry.payload['latitude'], sos.latitude);
    expect(entry.payload['longitude'], sos.longitude);
    expect(entry.payload['createdAt'], sos.createdAt.toIso8601String());
  });

  test('successful SOS transport completes the existing queue entry', () async {
    final sync = SyncService(
      database: database,
      internetCheck: () async => true,
      sosSubmitter: (_) async {},
    )..ownerUid = 'user-1';
    final result = await LocalEmergencyRepository(syncService: sync).submitSos(
      UserSos(
        id: 'successful-test',
        userId: 'user-1',
        latitude: 19,
        longitude: 72,
        accuracy: 10,
        createdAt: DateTime(2026, 1, 1),
        status: UserSosStatus.pending,
      ),
    );

    expect(result.state, SosDeliveryState.submitted);
    expect(
      (await sync.queue.getByStatus('completed')).single.entityId,
      'successful-test',
    );
  });

  test('failed SOS transport leaves a retryable failed queue entry', () async {
    final sync = SyncService(
      database: database,
      internetCheck: () async => true,
      sosSubmitter: (_) async => throw StateError('transport unavailable'),
    )..ownerUid = 'user-1';
    final result = await LocalEmergencyRepository(syncService: sync).submitSos(
      UserSos(
        id: 'failed-test',
        userId: 'user-1',
        latitude: 19,
        longitude: 72,
        accuracy: 10,
        createdAt: DateTime(2026, 1, 1),
        status: UserSosStatus.pending,
      ),
    );

    expect(result.state, SosDeliveryState.pendingLocal);
    final entry = (await sync.queue.getByStatus('failed')).single;
    expect(entry.entityId, 'failed-test');
    expect(entry.retryCount, 1);
    expect(result.message, isNot(contains('delivered')));
  });
}
