import 'package:drift/drift.dart';

import 'app_database_connection_io.dart'
    if (dart.library.js_interop) 'app_database_connection_web.dart';

part 'app_database.g.dart';

class Camps extends Table {
  TextColumn get id => text()();
  TextColumn get ownerUid => text().nullable()();
  TextColumn get name => text()();
  TextColumn get locationName => text()();
  TextColumn get address => text()();
  RealColumn get latitude => real().nullable()();
  RealColumn get longitude => real().nullable()();
  RealColumn get locationAccuracy => real().nullable()();
  TextColumn get contactNumber => text()();
  TextColumn get officerName => text()();
  TextColumn get officerUid => text()();
  BoolColumn get active => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class NormalRecords extends Table {
  TextColumn get id => text()();
  TextColumn get ownerUid => text().nullable()();
  TextColumn get name => text()();
  IntColumn get age => integer()();
  TextColumn get photoUrl => text().nullable()();
  TextColumn get photoLocalPath => text().nullable()();
  TextColumn get campId => text()();
  TextColumn get campName => text()();
  TextColumn get officerUid => text()();
  TextColumn get officerName => text()();
  TextColumn get officerContact => text()();
  TextColumn get status => text()();
  TextColumn get additionalDetails => text()();
  DateTimeColumn get foundAt => dateTime()();
  DateTimeColumn get createdAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class CriticalRecords extends Table {
  TextColumn get id => text()();
  TextColumn get ownerUid => text().nullable()();
  TextColumn get name => text()();
  IntColumn get age => integer()();
  TextColumn get photoUrl => text().nullable()();
  TextColumn get clothingPhotoUrl => text().nullable()();
  TextColumn get photoLocalPath => text().nullable()();
  TextColumn get clothingPhotoLocalPath => text().nullable()();
  TextColumn get lastKnownClothing => text()();
  TextColumn get campId => text()();
  TextColumn get campName => text()();
  TextColumn get officerUid => text()();
  TextColumn get officerName => text()();
  TextColumn get officerContact => text()();
  TextColumn get foundLocation => text()();
  RealColumn get foundLatitude => real().nullable()();
  RealColumn get foundLongitude => real().nullable()();
  RealColumn get locationAccuracy => real().nullable()();
  TextColumn get additionalDetails => text()();
  TextColumn get status => text()();
  DateTimeColumn get foundAt => dateTime()();
  DateTimeColumn get createdAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class EmergencyAlerts extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get message => text().nullable()();
  TextColumn get type => text()();
  TextColumn get severity => text()();
  TextColumn get district => text().nullable()();
  TextColumn get state => text().nullable()();
  RealColumn get latitude => real().nullable()();
  RealColumn get longitude => real().nullable()();
  RealColumn get radiusKm => real().nullable()();
  BoolColumn get active => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get cachedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class SyncQueue extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get ownerUid => text().nullable()();
  TextColumn get entityType => text()();
  TextColumn get entityId => text()();
  TextColumn get operationType => text()();
  TextColumn get payload => text()();
  DateTimeColumn get createdAt => dateTime()();
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastAttemptAt => dateTime().nullable()();
  TextColumn get syncStatus => text()();
}

@DriftDatabase(
  tables: [Camps, NormalRecords, CriticalRecords, EmergencyAlerts, SyncQueue],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.addColumn(camps, camps.ownerUid);
        await m.addColumn(normalRecords, normalRecords.ownerUid);
        await m.addColumn(criticalRecords, criticalRecords.ownerUid);
        await m.addColumn(syncQueue, syncQueue.ownerUid);
      }
      if (from < 3) {
        await m.addColumn(normalRecords, normalRecords.photoLocalPath);
        await m.addColumn(criticalRecords, criticalRecords.photoLocalPath);
        await m.addColumn(
          criticalRecords,
          criticalRecords.clothingPhotoLocalPath,
        );
      }
      if (from < 4) {
        await m.createTable(emergencyAlerts);
      }
    },
  );

  static QueryExecutor _openConnection() => openConnection();

  factory AppDatabase.open() => AppDatabase(_openConnection());
}

class LocalDatabase {
  LocalDatabase._();

  static final LocalDatabase instance = LocalDatabase._();
  final AppDatabase database = AppDatabase.open();

  Future<void> initialize() async {
    await database.customSelect('SELECT 1').get();
  }

  Future<void> close() => database.close();
}
