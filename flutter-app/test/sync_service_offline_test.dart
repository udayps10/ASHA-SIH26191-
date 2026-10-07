import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:aasha/data/local/database/app_database.dart';
import 'package:aasha/data/models/critical_record.dart' as critical_model;
import 'package:aasha/data/models/normal_record.dart' as normal_model;
import 'package:aasha/data/sync/sync_service.dart';

void main() {
  late AppDatabase database;
  late SyncService service;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    service = SyncService(database: database, internetCheck: () async => false)
      ..ownerUid = 'official-1';
  });

  tearDown(() => database.close());

  test('saves a normal record locally and queues it while offline', () async {
    await service.saveNormal(_normalRecord(), operationType: 'create');

    expect(await service.normalRecords.getRecent(), hasLength(1));
    expect(
      (await service.queue.getPending(ownerUid: 'official-1')),
      hasLength(1),
    );
    expect(
      (await service.queue.getPending(
        ownerUid: 'official-1',
      )).single.entityType,
      'normal_record',
    );
  });

  test(
    'saves a critical record locally without exposing it through another owner',
    () async {
      await service.saveCritical(_criticalRecord(), operationType: 'create');
      expect(await service.criticalRecords.getRecent(), hasLength(1));

      final other = SyncService(
        database: database,
        internetCheck: () async => false,
      )..ownerUid = 'official-2';
      expect(await other.criticalRecords.getRecent(), isEmpty);
    },
  );

  test('offline state does not attempt a network sync', () async {
    expect(await service.isOnline(), isFalse);
    await service.syncAll();
    expect(service.phase, SyncPhase.offline);
  });

  test(
    'offline normal record preserves its pending local image path',
    () async {
      await service.saveNormal(
        _normalRecord(photoLocalPath: r'C:\pending\normal.jpg'),
        operationType: 'create',
      );

      final record = await service.normalRecords.getRecent();
      expect(record.single.photoLocalPath, r'C:\pending\normal.jpg');
      expect(
        (await service.queue.getPending(
          ownerUid: 'official-1',
        )).single.payload['photoLocalPath'],
        r'C:\pending\normal.jpg',
      );
    },
  );

  test(
    'offline critical record preserves both pending local image paths',
    () async {
      await service.saveCritical(
        _criticalRecord(
          photoLocalPath: r'C:\pending\critical.jpg',
          clothingPhotoLocalPath: r'C:\pending\clothing.jpg',
        ),
        operationType: 'create',
      );

      final record = await service.criticalRecords.getRecent();
      expect(record.single.photoLocalPath, r'C:\pending\critical.jpg');
      expect(record.single.clothingPhotoLocalPath, r'C:\pending\clothing.jpg');
    },
  );
}

normal_model.NormalRecord _normalRecord({String? photoLocalPath}) =>
    normal_model.NormalRecord(
      id: '',
      name: 'Offline Person',
      age: 34,
      campId: 'camp-1',
      campName: 'Cached Camp',
      officerUid: 'official-1',
      officerName: 'Officer',
      officerContact: '12345',
      status: normal_model.NormalRecordStatus.AT_CAMP,
      additionalDetails: 'Offline details',
      foundAt: DateTime(2026, 8, 14),
      photoLocalPath: photoLocalPath,
    );

critical_model.CriticalRecord _criticalRecord({
  String? photoLocalPath,
  String? clothingPhotoLocalPath,
}) => critical_model.CriticalRecord(
  id: '',
  name: 'Offline Critical Person',
  age: 44,
  lastKnownClothing: 'Blue jacket',
  campId: 'camp-1',
  campName: 'Cached Camp',
  officerUid: 'official-1',
  officerName: 'Officer',
  officerContact: '12345',
  foundLocation: 'Hospital',
  additionalDetails: 'Offline details',
  status: critical_model.CriticalRecordStatus.CRITICAL,
  foundAt: DateTime(2026, 8, 14),
  photoLocalPath: photoLocalPath,
  clothingPhotoLocalPath: clothingPhotoLocalPath,
);
