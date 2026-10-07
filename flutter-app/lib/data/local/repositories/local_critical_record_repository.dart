import 'package:drift/drift.dart';
import '../../models/critical_record.dart' as models;
import '../database/app_database.dart' as local;
import '../database/local_mappers.dart';

/// Official/local-layer repository. Do not expose this repository to normal-user features.
class LocalCriticalRecordRepository {
  LocalCriticalRecordRepository(this._database, {this.ownerUid});

  final local.AppDatabase _database;
  final String? ownerUid;

  Future<void> insertOrUpdate(models.CriticalRecord record) => _database
      .into(_database.criticalRecords)
      .insertOnConflictUpdate(
        criticalToLocal(record).copyWith(ownerUid: Value(ownerUid)),
      );

  Future<models.CriticalRecord?> getById(String id) async {
    final row =
        await (_database.select(_database.criticalRecords)
              ..where((table) => table.id.equals(id) & _ownerFilter(table)))
            .getSingleOrNull();
    return row == null ? null : criticalFromLocal(row);
  }

  Future<void> updateImageState(
    String id, {
    String? photoUrl,
    String? photoLocalPath,
    String? clothingPhotoUrl,
    String? clothingPhotoLocalPath,
  }) async {
    await (_database.update(
      _database.criticalRecords,
    )..where((table) => table.id.equals(id) & _ownerFilter(table))).write(
      local.CriticalRecordsCompanion(
        photoUrl: Value(photoUrl),
        photoLocalPath: Value(photoLocalPath),
        clothingPhotoUrl: Value(clothingPhotoUrl),
        clothingPhotoLocalPath: Value(clothingPhotoLocalPath),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<List<models.CriticalRecord>> getRecent({int limit = 100}) async {
    final rows =
        await (_database.select(_database.criticalRecords)
              ..where(_ownerFilter)
              ..orderBy([(table) => OrderingTerm.desc(table.updatedAt)])
              ..limit(limit))
            .get();
    return rows.map(criticalFromLocal).toList();
  }

  Future<List<models.CriticalRecord>> search({
    String? name,
    int? age,
    String? campId,
    String? status,
  }) async {
    final rows =
        await (_database.select(_database.criticalRecords)
              ..where(_ownerFilter)
              ..orderBy([(table) => OrderingTerm.desc(table.updatedAt)]))
            .get();
    final query = name?.trim().toLowerCase();
    return rows
        .where(
          (row) =>
              query == null ||
              query.isEmpty ||
              row.name.toLowerCase().contains(query),
        )
        .where((row) => age == null || row.age == age)
        .where((row) => campId == null || row.campId == campId)
        .where((row) => status == null || row.status == status)
        .map(criticalFromLocal)
        .toList();
  }

  Expression<bool> _ownerFilter(local.$CriticalRecordsTable table) =>
      ownerUid == null
      ? const Constant(true)
      : table.ownerUid.equals(ownerUid!);
}
