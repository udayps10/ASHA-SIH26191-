import 'package:drift/drift.dart';
import '../../models/camp.dart' as models;
import '../database/app_database.dart' as local;
import '../database/local_mappers.dart';

class LocalCampRepository {
  LocalCampRepository(this._database, {this.ownerUid});

  final local.AppDatabase _database;
  final String? ownerUid;

  Future<void> insertOrUpdate(models.Camp camp) => _database
      .into(_database.camps)
      .insertOnConflictUpdate(
        campToLocal(camp).copyWith(ownerUid: Value(ownerUid)),
      );

  Future<models.Camp?> getById(String id) async {
    final row =
        await (_database.select(_database.camps)
              ..where((table) => table.id.equals(id) & _ownerFilter(table)))
            .getSingleOrNull();
    return row == null ? null : campFromLocal(row);
  }

  Future<List<models.Camp>> getRecent({int limit = 100}) async {
    final rows =
        await (_database.select(_database.camps)
              ..where(_ownerFilter)
              ..orderBy([(table) => OrderingTerm.desc(table.updatedAt)])
              ..limit(limit))
            .get();
    return rows.map(campFromLocal).toList();
  }

  Future<List<models.Camp>> getActive() async {
    final rows =
        await (_database.select(_database.camps)
              ..where(
                (table) => table.active.equals(true) & _ownerFilter(table),
              )
              ..orderBy([(table) => OrderingTerm.asc(table.name)]))
            .get();
    return rows.map(campFromLocal).toList();
  }

  Expression<bool> _ownerFilter(local.$CampsTable table) => ownerUid == null
      ? const Constant(true)
      : table.ownerUid.equals(ownerUid!);
}
