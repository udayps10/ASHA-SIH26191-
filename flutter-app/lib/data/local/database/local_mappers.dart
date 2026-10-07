import 'package:drift/drift.dart';
import '../../models/camp.dart' as camp_model;
import '../../models/critical_record.dart' as critical_model;
import '../../models/normal_record.dart' as normal_model;
import '../../../features/emergency/data/models/emergency_alert.dart';
import 'app_database.dart' as local;

EmergencyAlert emergencyAlertFromLocal(local.EmergencyAlert row) =>
    EmergencyAlert(
      id: row.id,
      title: row.title,
      message: row.message ?? '',
      disasterType: row.type,
      severity: EmergencySeverity.values.firstWhere(
        (value) => value.name == row.severity,
        orElse: () => EmergencySeverity.moderate,
      ),
      district: row.district,
      state: row.state,
      latitude: row.latitude,
      longitude: row.longitude,
      radiusKm: row.radiusKm,
      createdAt: row.createdAt,
      active: row.active,
    );

local.EmergencyAlertsCompanion emergencyAlertToLocal(
  EmergencyAlert value, {
  DateTime? cachedAt,
}) => local.EmergencyAlertsCompanion.insert(
  id: value.id,
  title: value.title,
  message: Value(value.message),
  type: value.disasterType,
  severity: value.severity.name,
  district: Value(value.district),
  state: Value(value.state),
  latitude: Value(value.latitude),
  longitude: Value(value.longitude),
  radiusKm: Value(value.radiusKm),
  active: Value(value.active),
  createdAt: value.createdAt,
  cachedAt: cachedAt ?? DateTime.now(),
);

camp_model.Camp campFromLocal(local.Camp row) => camp_model.Camp(
  id: row.id,
  name: row.name,
  locationName: row.locationName,
  address: row.address,
  latitude: row.latitude,
  longitude: row.longitude,
  contactNumber: row.contactNumber,
  officerName: row.officerName,
  officerUid: row.officerUid,
  active: row.active,
  locationAccuracy: row.locationAccuracy,
  createdAt: row.createdAt,
);

local.CampsCompanion campToLocal(
  camp_model.Camp value, {
  DateTime? updatedAt,
}) => local.CampsCompanion.insert(
  id: value.id,
  name: value.name,
  locationName: value.locationName,
  address: value.address,
  latitude: Value(value.latitude),
  longitude: Value(value.longitude),
  locationAccuracy: Value(value.locationAccuracy),
  contactNumber: value.contactNumber,
  officerName: value.officerName,
  officerUid: value.officerUid,
  active: Value(value.active),
  createdAt: Value(value.createdAt),
  updatedAt: Value(updatedAt ?? DateTime.now()),
);

normal_model.NormalRecord normalFromLocal(local.NormalRecord row) =>
    normal_model.NormalRecord(
      id: row.id,
      name: row.name,
      age: row.age,
      photoUrl: row.photoUrl,
      photoLocalPath: row.photoLocalPath,
      campId: row.campId,
      campName: row.campName,
      officerUid: row.officerUid,
      officerName: row.officerName,
      officerContact: row.officerContact,
      status: normal_model.NormalRecordStatus.values.firstWhere(
        (value) => value.name == row.status,
        orElse: () => normal_model.NormalRecordStatus.AT_CAMP,
      ),
      additionalDetails: row.additionalDetails,
      foundAt: row.foundAt,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );

local.NormalRecordsCompanion normalToLocal(normal_model.NormalRecord value) =>
    local.NormalRecordsCompanion.insert(
      id: value.id,
      name: value.name,
      age: value.age,
      photoUrl: Value(value.photoUrl),
      photoLocalPath: Value(value.photoLocalPath),
      campId: value.campId,
      campName: value.campName,
      officerUid: value.officerUid,
      officerName: value.officerName,
      officerContact: value.officerContact,
      status: value.status.name,
      additionalDetails: value.additionalDetails,
      foundAt: value.foundAt,
      createdAt: Value(value.createdAt),
      updatedAt: Value(value.updatedAt ?? DateTime.now()),
    );

critical_model.CriticalRecord criticalFromLocal(local.CriticalRecord row) =>
    critical_model.CriticalRecord(
      id: row.id,
      name: row.name,
      age: row.age,
      photoUrl: row.photoUrl,
      clothingPhotoUrl: row.clothingPhotoUrl,
      photoLocalPath: row.photoLocalPath,
      clothingPhotoLocalPath: row.clothingPhotoLocalPath,
      lastKnownClothing: row.lastKnownClothing,
      campId: row.campId,
      campName: row.campName,
      officerUid: row.officerUid,
      officerName: row.officerName,
      officerContact: row.officerContact,
      foundLocation: row.foundLocation,
      foundLatitude: row.foundLatitude,
      foundLongitude: row.foundLongitude,
      locationAccuracy: row.locationAccuracy,
      additionalDetails: row.additionalDetails,
      status: critical_model.CriticalRecordStatus.values.firstWhere(
        (value) => value.name == row.status,
        orElse: () => critical_model.CriticalRecordStatus.CRITICAL,
      ),
      foundAt: row.foundAt,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );

local.CriticalRecordsCompanion criticalToLocal(
  critical_model.CriticalRecord value,
) => local.CriticalRecordsCompanion.insert(
  id: value.id,
  name: value.name,
  age: value.age,
  photoUrl: Value(value.photoUrl),
  clothingPhotoUrl: Value(value.clothingPhotoUrl),
  photoLocalPath: Value(value.photoLocalPath),
  clothingPhotoLocalPath: Value(value.clothingPhotoLocalPath),
  lastKnownClothing: value.lastKnownClothing,
  campId: value.campId,
  campName: value.campName,
  officerUid: value.officerUid,
  officerName: value.officerName,
  officerContact: value.officerContact,
  foundLocation: value.foundLocation,
  foundLatitude: Value(value.foundLatitude),
  foundLongitude: Value(value.foundLongitude),
  locationAccuracy: Value(value.locationAccuracy),
  additionalDetails: value.additionalDetails,
  status: value.status.name,
  foundAt: value.foundAt,
  createdAt: Value(value.createdAt),
  updatedAt: Value(value.updatedAt ?? DateTime.now()),
);
