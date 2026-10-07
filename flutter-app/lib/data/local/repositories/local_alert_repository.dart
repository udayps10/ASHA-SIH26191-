import 'package:drift/drift.dart';

import '../../../features/emergency/data/models/emergency_alert.dart';
import '../database/app_database.dart' as local;
import '../database/local_mappers.dart';

class LocalAlertRepository {
  LocalAlertRepository(this._database);

  final local.AppDatabase _database;

  Future<List<EmergencyAlert>> getActive() async {
    final rows =
        await (_database.select(_database.emergencyAlerts)
              ..where((table) => table.active.equals(true))
              ..orderBy([(table) => OrderingTerm.desc(table.createdAt)]))
            .get();
    return rows.map(emergencyAlertFromLocal).toList();
  }

  Future<void> replaceActive(List<EmergencyAlert> alerts) async {
    await _database.transaction(() async {
      await (_database.delete(
        _database.emergencyAlerts,
      )..where((table) => table.active.equals(true))).go();
      for (final alert in alerts) {
        await _database
            .into(_database.emergencyAlerts)
            .insertOnConflictUpdate(emergencyAlertToLocal(alert));
      }
    });
  }
}
