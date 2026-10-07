import 'package:drift/drift.dart';
import '../../models/normal_record.dart' as models;
import '../database/app_database.dart' as local;
import '../database/local_mappers.dart';

class LocalNormalRecordRepository {
  LocalNormalRecordRepository(this._database, {this.ownerUid});

  final local.AppDatabase _database;
  final String? ownerUid;

  Future<void> insertOrUpdate(models.NormalRecord record) => _database
      .into(_database.normalRecords)
      .insertOnConflictUpdate(
        normalToLocal(record).copyWith(ownerUid: Value(ownerUid)),
      );

  Future<models.NormalRecord?> getById(String id) async {
    final row =
        await (_database.select(_database.normalRecords)
              ..where((table) => table.id.equals(id) & _ownerFilter(table)))
            .getSingleOrNull();
    return row == null ? null : normalFromLocal(row);
  }

  Future<void> updateImageState(
    String id, {
    String? photoUrl,
    String? photoLocalPath,
  }) async {
    await (_database.update(
      _database.normalRecords,
    )..where((table) => table.id.equals(id) & _ownerFilter(table))).write(
      local.NormalRecordsCompanion(
        photoUrl: Value(photoUrl),
        photoLocalPath: Value(photoLocalPath),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<List<models.NormalRecord>> getRecent({int limit = 100}) async {
    final rows =
        await (_database.select(_database.normalRecords)
              ..where(_ownerFilter)
              ..orderBy([(table) => OrderingTerm.desc(table.updatedAt)])
              ..limit(limit))
            .get();
    return rows.map(normalFromLocal).toList();
  }

  Future<List<models.NormalRecord>> search({
    String? name,
    int? age,
    String? campId,
    String? status,
  }) async {
    final rows =
        await (_database.select(_database.normalRecords)
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
        .map(normalFromLocal)
        .toList();
  }

  Expression<bool> _ownerFilter(local.$NormalRecordsTable table) =>
      ownerUid == null
      ? const Constant(true)
      : table.ownerUid.equals(ownerUid!);
}
