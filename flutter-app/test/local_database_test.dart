import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:aasha/data/local/database/app_database.dart';
import 'package:aasha/data/local/repositories/local_camp_repository.dart';
import 'package:aasha/data/local/repositories/local_critical_record_repository.dart';
import 'package:aasha/data/local/repositories/local_normal_record_repository.dart';
import 'package:aasha/data/local/repositories/sync_queue_repository.dart';
import 'package:aasha/data/models/camp.dart' as camp_model;
import 'package:aasha/data/models/critical_record.dart' as critical_model;
import 'package:aasha/data/models/normal_record.dart' as normal_model;

void main() {
  late AppDatabase database;
  late LocalCampRepository camps;
  late LocalNormalRecordRepository normalRecords;
  late LocalCriticalRecordRepository criticalRecords;
  late SyncQueueRepository syncQueue;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    camps = LocalCampRepository(database);
    normalRecords = LocalNormalRecordRepository(database);
    criticalRecords = LocalCriticalRecordRepository(database);
    syncQueue = SyncQueueRepository(database);
  });

  tearDown(() => database.close());

  test('inserts, reads, and updates a camp', () async {
    final camp = camp_model.Camp(
      id: 'camp-1',
      name: 'Relief Camp',
      locationName: 'North Zone',
      address: 'Main Road',
      contactNumber: '12345',
      officerName: 'Officer One',
      officerUid: 'officer-1',
    );

    await camps.insertOrUpdate(camp);
    expect((await camps.getById('camp-1'))?.name, 'Relief Camp');

    await camps.insertOrUpdate(
      camp_model.Camp(
        id: camp.id,
        name: 'Updated Camp',
        locationName: camp.locationName,
        address: camp.address,
        contactNumber: camp.contactNumber,
        officerName: camp.officerName,
        officerUid: camp.officerUid,
        active: false,
      ),
    );
    expect((await camps.getById('camp-1'))?.name, 'Updated Camp');
    expect(await camps.getActive(), isEmpty);
  });

  test('inserts and searches normal records locally', () async {
    await normalRecords.insertOrUpdate(
      _normalRecord('normal-1', 'Asha Sharma', 28),
    );
    await normalRecords.insertOrUpdate(
      _normalRecord('normal-2', 'Ravi Kumar', 40),
    );

    final matches = await normalRecords.search(
      name: 'asha',
      age: 28,
      campId: 'camp-1',
      status: 'AT_CAMP',
    );
    expect(matches.map((record) => record.id), ['normal-1']);
  });

  test('inserts and searches critical records locally', () async {
    await criticalRecords.insertOrUpdate(
      _criticalRecord('critical-1', 'Missing Person', 31),
    );
    await criticalRecords.insertOrUpdate(
      _criticalRecord('critical-2', 'Another Person', 45),
    );

    final matches = await criticalRecords.search(
      name: 'missing',
      age: 31,
      campId: 'camp-1',
      status: 'CRITICAL',
    );
    expect(matches.map((record) => record.id), ['critical-1']);
    expect(
      (await criticalRecords.getById('critical-1'))?.lastKnownClothing,
      'Blue jacket',
    );
  });

  test('enqueues and updates sync operations', () async {
    final id = await syncQueue.enqueue(
      entityType: 'normal_record',
      entityId: 'normal-1',
      operationType: 'create',
      payload: {'name': 'Asha Sharma'},
    );

    expect(
      (await syncQueue.getPending()).single.payload['name'],
      'Asha Sharma',
    );
    await syncQueue.markSyncing(id);
    await syncQueue.markFailed(id);
    await syncQueue.incrementRetry(id);
    expect((await syncQueue.getPending()), isEmpty);

    await syncQueue.markCompleted(id);
    final row = await (database.select(
      database.syncQueue,
    )..where((table) => table.id.equals(id))).getSingle();
    expect(row.syncStatus, 'completed');
    expect(row.retryCount, 1);
  });

  test('persists data when the database is reopened', () async {
    final directory = await Directory.systemTemp.createTemp(
      'disaster_connect_test_',
    );
    final file = File(
      '${directory.path}${Platform.pathSeparator}database.sqlite',
    );
    final first = AppDatabase(NativeDatabase(file));
    await LocalCampRepository(first).insertOrUpdate(
      camp_model.Camp(
        id: 'persistent-camp',
        name: 'Persistent Camp',
        locationName: 'Zone',
        address: 'Address',
        contactNumber: '12345',
        officerName: 'Officer',
        officerUid: 'officer',
      ),
    );
    await first.close();

    final reopened = AppDatabase(NativeDatabase(file));
    expect(
      (await LocalCampRepository(reopened).getById('persistent-camp'))?.name,
      'Persistent Camp',
    );
    await reopened.close();
    await directory.delete(recursive: true);
  });
}

normal_model.NormalRecord _normalRecord(String id, String name, int age) =>
    normal_model.NormalRecord(
      id: id,
      name: name,
      age: age,
      campId: 'camp-1',
      campName: 'Camp One',
      officerUid: 'officer-1',
      officerName: 'Officer One',
      officerContact: '12345',
      status: normal_model.NormalRecordStatus.AT_CAMP,
      additionalDetails: 'Details',
      foundAt: DateTime(2026, 8, 14),
    );

critical_model.CriticalRecord _criticalRecord(
  String id,
  String name,
  int age,
) => critical_model.CriticalRecord(
  id: id,
  name: name,
  age: age,
  lastKnownClothing: 'Blue jacket',
  campId: 'camp-1',
  campName: 'Camp One',
  officerUid: 'officer-1',
  officerName: 'Officer One',
  officerContact: '12345',
  foundLocation: 'Hospital',
  additionalDetails: 'Details',
  status: critical_model.CriticalRecordStatus.CRITICAL,
  foundAt: DateTime(2026, 8, 14),
);
