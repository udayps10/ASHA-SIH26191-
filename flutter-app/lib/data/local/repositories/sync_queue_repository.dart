import 'dart:convert';

import 'package:drift/drift.dart';
import '../database/app_database.dart' as local;

class SyncQueueEntry {
  const SyncQueueEntry({
    required this.id,
    required this.entityType,
    required this.ownerUid,
    required this.entityId,
    required this.operationType,
    required this.payload,
    required this.createdAt,
    required this.retryCount,
    required this.lastAttemptAt,
    required this.syncStatus,
  });

  final int id;
  final String entityType;
  final String? ownerUid;
  final String entityId;
  final String operationType;
  final Map<String, dynamic> payload;
  final DateTime createdAt;
  final int retryCount;
  final DateTime? lastAttemptAt;
  final String syncStatus;
}

class SyncQueueRepository {
  SyncQueueRepository(this._database);

  final local.AppDatabase _database;

  Future<int> enqueue({
    String? ownerUid,
    required String entityType,
    required String entityId,
    required String operationType,
    required Map<String, dynamic> payload,
  }) {
    return _database
        .into(_database.syncQueue)
        .insert(
          local.SyncQueueCompanion.insert(
            ownerUid: Value(ownerUid),
            entityType: entityType,
            entityId: entityId,
            operationType: operationType,
            payload: jsonEncode(payload),
            createdAt: DateTime.now(),
            syncStatus: 'pending',
          ),
        );
  }

  Future<List<SyncQueueEntry>> getPending({String? ownerUid}) async {
    final rows =
        await (_database.select(_database.syncQueue)
              ..where(
                (table) =>
                    table.syncStatus.equals('pending') &
                    (ownerUid == null
                        ? const Constant(true)
                        : table.ownerUid.equals(ownerUid)),
              )
              ..orderBy([(table) => OrderingTerm.asc(table.createdAt)]))
            .get();
    return rows.map(_fromRow).toList();
  }

  Future<List<SyncQueueEntry>> getByStatus(
    String status, {
    String? ownerUid,
  }) async {
    final rows =
        await (_database.select(_database.syncQueue)
              ..where(
                (table) =>
                    table.syncStatus.equals(status) &
                    (ownerUid == null
                        ? const Constant(true)
                        : table.ownerUid.equals(ownerUid)),
              )
              ..orderBy([(table) => OrderingTerm.asc(table.createdAt)]))
            .get();
    return rows.map(_fromRow).toList();
  }

  Future<bool> hasUnsynced(
    String entityType,
    String entityId, {
    String? ownerUid,
  }) async {
    final row =
        await (_database.select(_database.syncQueue)
              ..where(
                (table) =>
                    table.entityType.equals(entityType) &
                    table.entityId.equals(entityId) &
                    table.syncStatus.isNotIn(['completed']) &
                    (ownerUid == null
                        ? const Constant(true)
                        : table.ownerUid.equals(ownerUid)),
              )
              ..limit(1))
            .getSingleOrNull();
    return row != null;
  }

  Future<void> markSyncing(int id) => _setStatus(id, 'syncing');
  Future<void> markCompleted(int id) => _setStatus(id, 'completed');

  Future<void> updatePayload(int id, Map<String, dynamic> payload) =>
      (_database.update(_database.syncQueue)
            ..where((table) => table.id.equals(id)))
          .write(local.SyncQueueCompanion(payload: Value(jsonEncode(payload))));

  Future<void> markFailed(int id) =>
      (_database.update(
        _database.syncQueue,
      )..where((table) => table.id.equals(id))).write(
        local.SyncQueueCompanion(
          syncStatus: const Value('failed'),
          lastAttemptAt: Value(DateTime.now()),
        ),
      );

  Future<void> incrementRetry(int id) =>
      (_database.update(_database.syncQueue)
            ..where((table) => table.id.equals(id)))
          .write(
            local.SyncQueueCompanion(
              retryCount: const Value.absent(),
              lastAttemptAt: Value(DateTime.now()),
            ),
          )
          .then((_) async {
            final row = await (_database.select(
              _database.syncQueue,
            )..where((table) => table.id.equals(id))).getSingle();
            await (_database.update(
              _database.syncQueue,
            )..where((table) => table.id.equals(id))).write(
              local.SyncQueueCompanion(retryCount: Value(row.retryCount + 1)),
            );
          });

  Future<void> _setStatus(int id, String status) =>
      (_database.update(
        _database.syncQueue,
      )..where((table) => table.id.equals(id))).write(
        local.SyncQueueCompanion(
          syncStatus: Value(status),
          lastAttemptAt: Value(DateTime.now()),
        ),
      );

  Future<SyncQueueEntry?> getById(int id) async {
    final row =
        await (_database.select(_database.syncQueue)
              ..where((table) => table.id.equals(id)))
            .getSingleOrNull();
    return row != null ? _fromRow(row) : null;
  }

  SyncQueueEntry _fromRow(local.SyncQueueData row) => SyncQueueEntry(
    id: row.id,
    entityType: row.entityType,
    ownerUid: row.ownerUid,
    entityId: row.entityId,
    operationType: row.operationType,
    payload: (jsonDecode(row.payload) as Map).cast<String, dynamic>(),
    createdAt: row.createdAt,
    retryCount: row.retryCount,
    lastAttemptAt: row.lastAttemptAt,
    syncStatus: row.syncStatus,
  );
}
