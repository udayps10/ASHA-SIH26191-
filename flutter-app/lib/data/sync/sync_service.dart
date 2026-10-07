// ignore_for_file: prefer_initializing_formals
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

import '../local/database/app_database.dart'
    hide Camp, NormalRecord, CriticalRecord;
import '../local/repositories/local_camp_repository.dart';
import '../local/repositories/local_critical_record_repository.dart';
import '../local/repositories/local_normal_record_repository.dart';
import '../local/repositories/sync_queue_repository.dart';
import '../models/camp.dart';
import '../models/critical_record.dart';
import '../models/normal_record.dart';
import '../../features/images/data/image_upload_api_service.dart';
import '../../features/images/data/local_image.dart';
import '../../features/emergency/data/models/user_sos.dart';

enum SyncPhase { idle, offline, syncing, complete, failed }

class SyncService extends ChangeNotifier {
  static final SyncService instance = SyncService();

  SyncService({
    AppDatabase? database,
    FirebaseFirestore? firestore,
    Future<bool> Function()? internetCheck,
    ImageUploadApiService? imageUploadService,
    Future<void> Function(Map<String, dynamic> payload)? sosSubmitter,
  }) : _database = database ?? LocalDatabase.instance.database,
       _firestoreOverride = firestore,
       _internetCheck = internetCheck,
       _imageUploadService = imageUploadService ?? HttpImageUploadApiService(),
       _sosSubmitter = sosSubmitter;

  final AppDatabase _database;
  final FirebaseFirestore? _firestoreOverride;
  final Future<bool> Function()? _internetCheck;
  final ImageUploadApiService _imageUploadService;
  Future<void> Function(Map<String, dynamic> payload)? _sosSubmitter;
  late final SyncQueueRepository queue = SyncQueueRepository(_database);

  /// LEGACY: Firebase Firestore dependency for background synchronization.
  /// Production path now uses Spring Boot + MySQL + MinIO.
  FirebaseFirestore get _firestore =>
      _firestoreOverride ?? FirebaseFirestore.instance;

  SyncPhase phase = SyncPhase.idle;
  bool? online;
  DateTime? lastSuccessfulSync;
  String? lastError;
  String? ownerUid;
  bool _syncing = false;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  Timer? _syncPollTimer;

  LocalCampRepository get camps =>
      LocalCampRepository(_database, ownerUid: ownerUid);
  LocalNormalRecordRepository get normalRecords =>
      LocalNormalRecordRepository(_database, ownerUid: ownerUid);
  LocalCriticalRecordRepository get criticalRecords =>
      LocalCriticalRecordRepository(_database, ownerUid: ownerUid);

  void configureSosSubmitter(
    Future<void> Function(Map<String, dynamic> payload) submitter,
  ) {
    _sosSubmitter = submitter;
  }

  Future<void> startSession(String uid) async {
    if (ownerUid == uid && _connectivitySubscription != null) {
      unawaited(syncAll());
      return;
    }
    await stopSession();
    ownerUid = uid;
    await _claimLegacyRows(uid);

    // Immediate check and then listen for changes.
    unawaited(
      isOnline().then((online) {
        if (online) unawaited(syncAll());
      }),
    );

    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((
      results,
    ) {
      final isConnected = !results.contains(ConnectivityResult.none);
      if (isConnected) unawaited(syncAll());
    });
    _syncPollTimer = Timer.periodic(
      const Duration(seconds: 15),
      (_) => unawaited(syncAll()),
    );
  }

  Future<void> stopSession() async {
    await _connectivitySubscription?.cancel();
    _connectivitySubscription = null;
    _syncPollTimer?.cancel();
    _syncPollTimer = null;
    ownerUid = null;
    phase = SyncPhase.idle;
    online = null;
    notifyListeners();
  }

  Future<bool> isOnline() async {
    final result = await (_internetCheck ?? _defaultInternetCheck)();
    online = result;
    if (!result && !_syncing) phase = SyncPhase.offline;
    notifyListeners();
    return result;
  }

  Future<bool> _defaultInternetCheck() async {
    try {
      final connectivity = await Connectivity().checkConnectivity();
      if (connectivity.contains(ConnectivityResult.none)) return false;
      
      // Perform a neutral DNS lookup to verify internet access
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 5));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  Future<void> syncAll() async {
    if (_syncing || ownerUid == null) return;
    if (!await isOnline()) return;
    debugPrint('[SyncService] sync started for owner=$ownerUid');
    _syncing = true;
    phase = SyncPhase.syncing;
    lastError = null;
    notifyListeners();
    try {
      // Push local changes first. A pull failure must never prevent a locally
      // saved record from reaching Firestore.
      await processPendingQueue();
      await pullLatestData();
      await _enforceRetention();
      lastSuccessfulSync = DateTime.now();
      phase = SyncPhase.complete;
    } catch (error) {
      lastError = error.toString();
      phase = SyncPhase.failed;
      debugPrint('[SyncService] sync failed: $error');
    } finally {
      _syncing = false;
      notifyListeners();
    }
  }

  Future<void> pullLatestData() async {
    final uid = ownerUid;
    if (uid == null) return;
    final campSnapshot = await _firestore
        .collection('camps')
        .where('active', isEqualTo: true)
        .get();
    for (final doc in campSnapshot.docs) {
      if (!await queue.hasUnsynced('camp', doc.id, ownerUid: uid)) {
        await camps.insertOrUpdate(Camp.fromMap(doc.id, doc.data()));
      }
    }

    final normalSnapshot = await _firestore.collection('normal_records').get();
    for (final doc in normalSnapshot.docs.take(100)) {
      if (!await queue.hasUnsynced('normal_record', doc.id, ownerUid: uid)) {
        await normalRecords.insertOrUpdate(
          NormalRecord.fromMap(doc.id, doc.data()),
        );
      }
    }

    final criticalSnapshot = await _firestore
        .collection('critical_records')
        .get();
    for (final doc in criticalSnapshot.docs.take(100)) {
      if (!await queue.hasUnsynced('critical_record', doc.id, ownerUid: uid)) {
        await criticalRecords.insertOrUpdate(
          CriticalRecord.fromMap(doc.id, doc.data()),
        );
      }
    }
  }

  Future<void> syncCamps() => pullLatestData();
  Future<void> syncNormalRecords() => pullLatestData();
  Future<void> syncCriticalRecords() => pullLatestData();

  Future<void> processPendingQueue() async {
    final uid = ownerUid;
    if (uid == null) return;
    final entries =
        [
            ...await queue.getPending(ownerUid: uid),
            ...await queue.getByStatus('failed', ownerUid: uid),
          ].where(_retryIsDue).toList()
          ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    for (final entry in entries) {
      if (entry.retryCount >= 8) continue;
      await queue.markSyncing(entry.id);
      try {
        final payload = Map<String, dynamic>.from(entry.payload);
        await _uploadPendingImages(entry, payload);
        await _firestore
            .collection(_collectionFor(entry.entityType))
            .doc(entry.entityId)
            .set(_toFirestoreMap(payload), SetOptions(merge: true));
        await queue.markCompleted(entry.id);
      } catch (error) {
        await queue.incrementRetry(entry.id);
        await queue.markFailed(entry.id);
        lastError = error.toString();
        debugPrint('[SyncService] queue item ${entry.id} failed: $error');
      }
    }
  }

  Future<void> _uploadPendingImages(
    SyncQueueEntry entry,
    Map<String, dynamic> payload,
  ) async {
    if (entry.entityType == 'normal_record') {
      final localPath = payload['photoLocalPath'] as String?;
      if (localPath != null && localPath.isNotEmpty) {
        final image = await _readLocalImage(localPath);
        final reference = await _imageUploadService.uploadNormalPhoto(
          recordId: entry.entityId,
          image: image,
        );
        payload['photoUrl'] = jsonEncode(reference.toJson());
        payload['photoLocalPath'] = null;
        await normalRecords.updateImageState(
          entry.entityId,
          photoUrl: payload['photoUrl'] as String,
          // Keep the local copy for the official detail screen. The queued
          // payload is cleared, so later updates do not upload it again.
          photoLocalPath: localPath,
        );
        await queue.updatePayload(entry.id, payload);
      }
    } else if (entry.entityType == 'critical_record') {
      final personPath = payload['photoLocalPath'] as String?;
      final clothingPath = payload['clothingPhotoLocalPath'] as String?;
      if (personPath != null && personPath.isNotEmpty) {
        final reference = await _imageUploadService.uploadCriticalPhoto(
          recordId: entry.entityId,
          image: await _readLocalImage(personPath),
        );
        payload['photoUrl'] = jsonEncode(reference.toJson());
        payload['photoLocalPath'] = null;
      }
      if (clothingPath != null && clothingPath.isNotEmpty) {
        final reference = await _imageUploadService.uploadCriticalClothing(
          recordId: entry.entityId,
          image: await _readLocalImage(clothingPath),
        );
        payload['clothingPhotoUrl'] = jsonEncode(reference.toJson());
        payload['clothingPhotoLocalPath'] = null;
      }
      if (personPath != null || clothingPath != null) {
        await criticalRecords.updateImageState(
          entry.entityId,
          photoUrl: payload['photoUrl'] as String?,
          photoLocalPath: personPath,
          clothingPhotoUrl: payload['clothingPhotoUrl'] as String?,
          clothingPhotoLocalPath: clothingPath,
        );
        await queue.updatePayload(entry.id, payload);
      }
    }
  }

  Future<LocalImage> _readLocalImage(String path) async {
    final file = File(path);
    if (!await file.exists()) throw StateError('Pending image is missing');
    final bytes = await file.readAsBytes();
    final extension = path.toLowerCase().split('.').last;
    final mime = switch (extension) {
      'jpg' || 'jpeg' => 'image/jpeg',
      'png' => 'image/png',
      'webp' => 'image/webp',
      _ => 'application/octet-stream',
    };
    return LocalImage(
      file: XFile(path, name: path.split(Platform.pathSeparator).last),
      bytes: bytes,
      fileName: path.split(Platform.pathSeparator).last,
      mimeType: mime,
    );
  }

  bool _retryIsDue(SyncQueueEntry entry) {
    if (entry.lastAttemptAt == null || entry.retryCount == 0) return true;
    final seconds = (1 << (entry.retryCount.clamp(0, 8))).toInt();
    return DateTime.now().difference(entry.lastAttemptAt!).inSeconds >= seconds;
  }

  Future<int> saveNormal(
    NormalRecord record, {
    required String operationType,
  }) async {
    await _ensureSession();
    final value = record.id.isEmpty ? _withNormalId(record) : record;
    debugPrint('[ADD NORMAL] localRecordId=${value.id} localSaveStarted=true');
    try {
      await normalRecords.insertOrUpdate(value);
    } catch (error, stackTrace) {
      debugPrint('[ADD NORMAL][LOCAL_SAVE] failed: $error');
      debugPrint('$stackTrace');
      rethrow;
    }
    debugPrint('[ADD NORMAL] localSaveSucceeded=true queueInsertStarted=true');
    late final int queueId;
    try {
      queueId = await queue.enqueue(
        ownerUid: ownerUid,
        entityType: 'normal_record',
        entityId: value.id,
        operationType: operationType,
        payload: _normalPayload(value),
      );
    } catch (error, stackTrace) {
      debugPrint('[ADD NORMAL][QUEUE_INSERT] failed: $error');
      debugPrint('$stackTrace');
      rethrow;
    }

    debugPrint(
      '[ADD NORMAL] queueInsertSucceeded=true onlineCheckStarted=true',
    );
    // Implementation of "Online-First": try immediate sync if connected.
    if (await isOnline()) {
      debugPrint('[ADD NORMAL] online=true immediateSyncStarted=true');
      try {
        await _syncSingleItem(queueId);
        debugPrint('[ADD NORMAL] immediateSyncSucceeded=true');
      } catch (error) {
        debugPrint('[ADD NORMAL] immediateSyncFailed: $error');
        // Fallback to background sync is already handled by the queue entry.
      }
    } else {
      debugPrint('[ADD NORMAL] online=false backgroundSyncScheduled=true');
    }

    return queueId;
  }

  Future<int> saveCritical(
    CriticalRecord record, {
    required String operationType,
  }) async {
    await _ensureSession();
    final value = record.id.isEmpty ? _withCriticalId(record) : record;
    debugPrint(
      '[ADD CRITICAL] localRecordId=${value.id} localSaveStarted=true',
    );
    try {
      await criticalRecords.insertOrUpdate(value);
    } catch (error, stackTrace) {
      debugPrint('[ADD CRITICAL][LOCAL_SAVE] failed: $error');
      debugPrint('$stackTrace');
      rethrow;
    }
    debugPrint(
      '[ADD CRITICAL] localSaveSucceeded=true queueInsertStarted=true',
    );
    late final int queueId;
    try {
      queueId = await queue.enqueue(
        ownerUid: ownerUid,
        entityType: 'critical_record',
        entityId: value.id,
        operationType: operationType,
        payload: _criticalPayload(value),
      );
    } catch (error, stackTrace) {
      debugPrint('[ADD CRITICAL][QUEUE_INSERT] failed: $error');
      debugPrint('$stackTrace');
      rethrow;
    }

    debugPrint(
      '[ADD CRITICAL] queueInsertSucceeded=true onlineCheckStarted=true',
    );
    if (await isOnline()) {
      debugPrint('[ADD CRITICAL] online=true immediateSyncStarted=true');
      try {
        await _syncSingleItem(queueId);
        debugPrint('[ADD CRITICAL] immediateSyncSucceeded=true');
      } catch (error) {
        debugPrint('[ADD CRITICAL] immediateSyncFailed: $error');
      }
    } else {
      debugPrint('[ADD CRITICAL] online=false backgroundSyncScheduled=true');
    }

    return queueId;
  }

  Future<int> saveCamp(Camp camp, {required String operationType}) async {
    await _ensureSession();
    final value = camp.id.isEmpty ? _withCampId(camp) : camp;
    await camps.insertOrUpdate(value);
    final queueId = await queue.enqueue(
      ownerUid: ownerUid,
      entityType: 'camp',
      entityId: value.id,
      operationType: operationType,
      payload: _campPayload(value),
    );

    if (await isOnline()) {
      try {
        await _syncSingleItem(queueId);
      } catch (_) {}
    }

    return queueId;
  }

  Future<bool> saveSos(UserSos sos) async {
    final queueId = await queue.enqueue(
      ownerUid: sos.userId ?? ownerUid,
      entityType: 'user_sos',
      entityId: sos.id,
      operationType: 'create',
      payload: {
        'id': sos.id,
        'userId': sos.userId,
        'latitude': sos.latitude,
        'longitude': sos.longitude,
        'accuracy': sos.accuracy,
        'message': sos.message,
        'createdAt': sos.createdAt.toIso8601String(),
        'status': sos.status.name,
      },
    );

    if (await isOnline()) {
      try {
        await _syncSingleItem(queueId);
        return true;
      } catch (_) {
        return false;
      }
    }
    return false;
  }

  Future<void> _syncSingleItem(int queueId) async {
    final entry = await queue.getById(queueId);
    if (entry == null || entry.syncStatus == 'completed') return;

    await queue.markSyncing(entry.id);
    try {
      final payload = Map<String, dynamic>.from(entry.payload);
      await _uploadPendingImages(entry, payload);
      final sosSubmitter = _sosSubmitter;
      if (entry.entityType == 'user_sos' && sosSubmitter != null) {
        await sosSubmitter(payload);
      } else {
        await _firestore
            .collection(_collectionFor(entry.entityType))
            .doc(entry.entityId)
            .set(_toFirestoreMap(payload), SetOptions(merge: true));
      }
      await queue.markCompleted(entry.id);
    } catch (error) {
      await queue.incrementRetry(entry.id);
      await queue.markFailed(entry.id);
      rethrow;
    }
  }

  String _collectionFor(String type) => switch (type) {
    'camp' => 'camps',
    'normal_record' => 'normal_records',
    'critical_record' => 'critical_records',
    'user_sos' => 'user_sos',
    _ => throw ArgumentError('Unknown sync entity: $type'),
  };

  Future<void> _ensureSession() async {
    if (ownerUid != null) return;
    // uid must be passed via startSession() from AppState
  }

  Future<void> ensureSession() => _ensureSession();

  Map<String, dynamic> _toFirestoreMap(Map<String, dynamic> payload) {
    final result = <String, dynamic>{};
    payload.forEach((key, value) {
      if (key.endsWith('LocalPath')) return;
      if (value is String &&
          (key.endsWith('At') || key == 'foundAt') &&
          DateTime.tryParse(value) != null) {
        result[key] = Timestamp.fromDate(DateTime.parse(value));
      } else {
        result[key] = value;
      }
    });
    return result;
  }

  Map<String, dynamic> _normalPayload(NormalRecord r) => {
    'name': r.name,
    'age': r.age,
    'photoUrl': r.photoUrl,
    'photoLocalPath': r.photoUrl == null ? r.photoLocalPath : null,
    'campId': r.campId,
    'campName': r.campName,
    'officerUid': r.officerUid,
    'officerName': r.officerName,
    'officerContact': r.officerContact,
    'status': r.status.name,
    'additionalDetails': r.additionalDetails,
    'foundAt': r.foundAt.toIso8601String(),
    'createdAt': (r.createdAt ?? DateTime.now()).toIso8601String(),
    'updatedAt': DateTime.now().toIso8601String(),
  };

  Map<String, dynamic> _campPayload(Camp c) => {
    'name': c.name,
    'locationName': c.locationName,
    'address': c.address,
    'latitude': c.latitude,
    'longitude': c.longitude,
    'locationAccuracy': c.locationAccuracy,
    'contactNumber': c.contactNumber,
    'officerName': c.officerName,
    'officerUid': c.officerUid,
    'active': c.active,
    'createdAt': (c.createdAt ?? DateTime.now()).toIso8601String(),
    'updatedAt': DateTime.now().toIso8601String(),
  };

  Map<String, dynamic> _criticalPayload(CriticalRecord r) => {
    'name': r.name,
    'age': r.age,
    'photoUrl': r.photoUrl,
    'clothingPhotoUrl': r.clothingPhotoUrl,
    'photoLocalPath': r.photoUrl == null ? r.photoLocalPath : null,
    'clothingPhotoLocalPath': r.clothingPhotoUrl == null
        ? r.clothingPhotoLocalPath
        : null,
    'lastKnownClothing': r.lastKnownClothing,
    'campId': r.campId,
    'campName': r.campName,
    'officerUid': r.officerUid,
    'officerName': r.officerName,
    'officerContact': r.officerContact,
    'foundLocation': r.foundLocation,
    'foundLatitude': r.foundLatitude,
    'foundLongitude': r.foundLongitude,
    'locationAccuracy': r.locationAccuracy,
    'additionalDetails': r.additionalDetails,
    'status': r.status.name,
    'foundAt': r.foundAt.toIso8601String(),
    'createdAt': (r.createdAt ?? DateTime.now()).toIso8601String(),
    'updatedAt': DateTime.now().toIso8601String(),
  };

  NormalRecord _withNormalId(NormalRecord r) => NormalRecord(
    id: _newId('normal'),
    name: r.name,
    age: r.age,
    photoUrl: r.photoUrl,
    photoLocalPath: r.photoLocalPath,
    campId: r.campId,
    campName: r.campName,
    officerUid: r.officerUid,
    officerName: r.officerName,
    officerContact: r.officerContact,
    status: r.status,
    additionalDetails: r.additionalDetails,
    foundAt: r.foundAt,
    createdAt: r.createdAt,
    updatedAt: DateTime.now(),
  );

  Camp _withCampId(Camp c) => Camp(
    id: _newId('camp'),
    name: c.name,
    locationName: c.locationName,
    address: c.address,
    latitude: c.latitude,
    longitude: c.longitude,
    contactNumber: c.contactNumber,
    officerName: c.officerName,
    officerUid: c.officerUid,
    active: c.active,
    locationAccuracy: c.locationAccuracy,
    createdAt: c.createdAt,
  );

  CriticalRecord _withCriticalId(CriticalRecord r) => CriticalRecord(
    id: _newId('critical'),
    name: r.name,
    age: r.age,
    photoUrl: r.photoUrl,
    clothingPhotoUrl: r.clothingPhotoUrl,
    photoLocalPath: r.photoLocalPath,
    clothingPhotoLocalPath: r.clothingPhotoLocalPath,
    lastKnownClothing: r.lastKnownClothing,
    campId: r.campId,
    campName: r.campName,
    officerUid: r.officerUid,
    officerName: r.officerName,
    officerContact: r.officerContact,
    foundLocation: r.foundLocation,
    foundLatitude: r.foundLatitude,
    foundLongitude: r.foundLongitude,
    locationAccuracy: r.locationAccuracy,
    additionalDetails: r.additionalDetails,
    status: r.status,
    foundAt: r.foundAt,
    createdAt: r.createdAt,
    updatedAt: DateTime.now(),
  );

  String _newId(String type) =>
      'local_${type}_${ownerUid ?? 'official'}_${DateTime.now().microsecondsSinceEpoch}';

  Future<void> _enforceRetention() async {
    await _evictNormal();
    await _evictCritical();
  }

  Future<void> _claimLegacyRows(String uid) async {
    // Step 9A rows predate owner scoping. Claiming them once keeps the existing
    // device cache available while all new rows remain account-scoped.
    await (_database.update(_database.camps)..where((t) => t.ownerUid.isNull()))
        .write(CampsCompanion(ownerUid: Value(uid)));
    await (_database.update(_database.normalRecords)
          ..where((t) => t.ownerUid.isNull()))
        .write(NormalRecordsCompanion(ownerUid: Value(uid)));
    await (_database.update(_database.criticalRecords)
          ..where((t) => t.ownerUid.isNull()))
        .write(CriticalRecordsCompanion(ownerUid: Value(uid)));
    await (_database.update(_database.syncQueue)
          ..where((t) => t.ownerUid.isNull()))
        .write(SyncQueueCompanion(ownerUid: Value(uid)));
  }

  Future<void> _evictNormal() async {
    final rows =
        await (_database.select(_database.normalRecords)
              ..where((t) => t.ownerUid.equals(ownerUid!))
              ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]))
            .get();
    for (final row in rows.skip(100)) {
      if (!await queue.hasUnsynced(
        'normal_record',
        row.id,
        ownerUid: ownerUid,
      )) {
        await (_database.delete(
          _database.normalRecords,
        )..where((t) => t.id.equals(row.id))).go();
      }
    }
  }

  Future<void> _evictCritical() async {
    final rows =
        await (_database.select(_database.criticalRecords)
              ..where((t) => t.ownerUid.equals(ownerUid!))
              ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]))
            .get();
    for (final row in rows.skip(100)) {
      if (!await queue.hasUnsynced(
        'critical_record',
        row.id,
        ownerUid: ownerUid,
      )) {
        await (_database.delete(
          _database.criticalRecords,
        )..where((t) => t.id.equals(row.id))).go();
      }
    }
  }
}
