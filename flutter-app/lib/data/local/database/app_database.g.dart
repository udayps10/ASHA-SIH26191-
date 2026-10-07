// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $CampsTable extends Camps with TableInfo<$CampsTable, Camp> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CampsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ownerUidMeta = const VerificationMeta(
    'ownerUid',
  );
  @override
  late final GeneratedColumn<String> ownerUid = GeneratedColumn<String>(
    'owner_uid',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _locationNameMeta = const VerificationMeta(
    'locationName',
  );
  @override
  late final GeneratedColumn<String> locationName = GeneratedColumn<String>(
    'location_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _addressMeta = const VerificationMeta(
    'address',
  );
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
    'address',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _latitudeMeta = const VerificationMeta(
    'latitude',
  );
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
    'latitude',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _longitudeMeta = const VerificationMeta(
    'longitude',
  );
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
    'longitude',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _locationAccuracyMeta = const VerificationMeta(
    'locationAccuracy',
  );
  @override
  late final GeneratedColumn<double> locationAccuracy = GeneratedColumn<double>(
    'location_accuracy',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _contactNumberMeta = const VerificationMeta(
    'contactNumber',
  );
  @override
  late final GeneratedColumn<String> contactNumber = GeneratedColumn<String>(
    'contact_number',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _officerNameMeta = const VerificationMeta(
    'officerName',
  );
  @override
  late final GeneratedColumn<String> officerName = GeneratedColumn<String>(
    'officer_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _officerUidMeta = const VerificationMeta(
    'officerUid',
  );
  @override
  late final GeneratedColumn<String> officerUid = GeneratedColumn<String>(
    'officer_uid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _activeMeta = const VerificationMeta('active');
  @override
  late final GeneratedColumn<bool> active = GeneratedColumn<bool>(
    'active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    ownerUid,
    name,
    locationName,
    address,
    latitude,
    longitude,
    locationAccuracy,
    contactNumber,
    officerName,
    officerUid,
    active,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'camps';
  @override
  VerificationContext validateIntegrity(
    Insertable<Camp> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('owner_uid')) {
      context.handle(
        _ownerUidMeta,
        ownerUid.isAcceptableOrUnknown(data['owner_uid']!, _ownerUidMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('location_name')) {
      context.handle(
        _locationNameMeta,
        locationName.isAcceptableOrUnknown(
          data['location_name']!,
          _locationNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_locationNameMeta);
    }
    if (data.containsKey('address')) {
      context.handle(
        _addressMeta,
        address.isAcceptableOrUnknown(data['address']!, _addressMeta),
      );
    } else if (isInserting) {
      context.missing(_addressMeta);
    }
    if (data.containsKey('latitude')) {
      context.handle(
        _latitudeMeta,
        latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta),
      );
    }
    if (data.containsKey('longitude')) {
      context.handle(
        _longitudeMeta,
        longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta),
      );
    }
    if (data.containsKey('location_accuracy')) {
      context.handle(
        _locationAccuracyMeta,
        locationAccuracy.isAcceptableOrUnknown(
          data['location_accuracy']!,
          _locationAccuracyMeta,
        ),
      );
    }
    if (data.containsKey('contact_number')) {
      context.handle(
        _contactNumberMeta,
        contactNumber.isAcceptableOrUnknown(
          data['contact_number']!,
          _contactNumberMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_contactNumberMeta);
    }
    if (data.containsKey('officer_name')) {
      context.handle(
        _officerNameMeta,
        officerName.isAcceptableOrUnknown(
          data['officer_name']!,
          _officerNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_officerNameMeta);
    }
    if (data.containsKey('officer_uid')) {
      context.handle(
        _officerUidMeta,
        officerUid.isAcceptableOrUnknown(data['officer_uid']!, _officerUidMeta),
      );
    } else if (isInserting) {
      context.missing(_officerUidMeta);
    }
    if (data.containsKey('active')) {
      context.handle(
        _activeMeta,
        active.isAcceptableOrUnknown(data['active']!, _activeMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Camp map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Camp(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      ownerUid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_uid'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      locationName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}location_name'],
      )!,
      address: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}address'],
      )!,
      latitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}latitude'],
      ),
      longitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}longitude'],
      ),
      locationAccuracy: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}location_accuracy'],
      ),
      contactNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}contact_number'],
      )!,
      officerName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}officer_name'],
      )!,
      officerUid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}officer_uid'],
      )!,
      active: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}active'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      ),
    );
  }

  @override
  $CampsTable createAlias(String alias) {
    return $CampsTable(attachedDatabase, alias);
  }
}

class Camp extends DataClass implements Insertable<Camp> {
  final String id;
  final String? ownerUid;
  final String name;
  final String locationName;
  final String address;
  final double? latitude;
  final double? longitude;
  final double? locationAccuracy;
  final String contactNumber;
  final String officerName;
  final String officerUid;
  final bool active;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  const Camp({
    required this.id,
    this.ownerUid,
    required this.name,
    required this.locationName,
    required this.address,
    this.latitude,
    this.longitude,
    this.locationAccuracy,
    required this.contactNumber,
    required this.officerName,
    required this.officerUid,
    required this.active,
    this.createdAt,
    this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || ownerUid != null) {
      map['owner_uid'] = Variable<String>(ownerUid);
    }
    map['name'] = Variable<String>(name);
    map['location_name'] = Variable<String>(locationName);
    map['address'] = Variable<String>(address);
    if (!nullToAbsent || latitude != null) {
      map['latitude'] = Variable<double>(latitude);
    }
    if (!nullToAbsent || longitude != null) {
      map['longitude'] = Variable<double>(longitude);
    }
    if (!nullToAbsent || locationAccuracy != null) {
      map['location_accuracy'] = Variable<double>(locationAccuracy);
    }
    map['contact_number'] = Variable<String>(contactNumber);
    map['officer_name'] = Variable<String>(officerName);
    map['officer_uid'] = Variable<String>(officerUid);
    map['active'] = Variable<bool>(active);
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<DateTime>(createdAt);
    }
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    return map;
  }

  CampsCompanion toCompanion(bool nullToAbsent) {
    return CampsCompanion(
      id: Value(id),
      ownerUid: ownerUid == null && nullToAbsent
          ? const Value.absent()
          : Value(ownerUid),
      name: Value(name),
      locationName: Value(locationName),
      address: Value(address),
      latitude: latitude == null && nullToAbsent
          ? const Value.absent()
          : Value(latitude),
      longitude: longitude == null && nullToAbsent
          ? const Value.absent()
          : Value(longitude),
      locationAccuracy: locationAccuracy == null && nullToAbsent
          ? const Value.absent()
          : Value(locationAccuracy),
      contactNumber: Value(contactNumber),
      officerName: Value(officerName),
      officerUid: Value(officerUid),
      active: Value(active),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory Camp.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Camp(
      id: serializer.fromJson<String>(json['id']),
      ownerUid: serializer.fromJson<String?>(json['ownerUid']),
      name: serializer.fromJson<String>(json['name']),
      locationName: serializer.fromJson<String>(json['locationName']),
      address: serializer.fromJson<String>(json['address']),
      latitude: serializer.fromJson<double?>(json['latitude']),
      longitude: serializer.fromJson<double?>(json['longitude']),
      locationAccuracy: serializer.fromJson<double?>(json['locationAccuracy']),
      contactNumber: serializer.fromJson<String>(json['contactNumber']),
      officerName: serializer.fromJson<String>(json['officerName']),
      officerUid: serializer.fromJson<String>(json['officerUid']),
      active: serializer.fromJson<bool>(json['active']),
      createdAt: serializer.fromJson<DateTime?>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'ownerUid': serializer.toJson<String?>(ownerUid),
      'name': serializer.toJson<String>(name),
      'locationName': serializer.toJson<String>(locationName),
      'address': serializer.toJson<String>(address),
      'latitude': serializer.toJson<double?>(latitude),
      'longitude': serializer.toJson<double?>(longitude),
      'locationAccuracy': serializer.toJson<double?>(locationAccuracy),
      'contactNumber': serializer.toJson<String>(contactNumber),
      'officerName': serializer.toJson<String>(officerName),
      'officerUid': serializer.toJson<String>(officerUid),
      'active': serializer.toJson<bool>(active),
      'createdAt': serializer.toJson<DateTime?>(createdAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
    };
  }

  Camp copyWith({
    String? id,
    Value<String?> ownerUid = const Value.absent(),
    String? name,
    String? locationName,
    String? address,
    Value<double?> latitude = const Value.absent(),
    Value<double?> longitude = const Value.absent(),
    Value<double?> locationAccuracy = const Value.absent(),
    String? contactNumber,
    String? officerName,
    String? officerUid,
    bool? active,
    Value<DateTime?> createdAt = const Value.absent(),
    Value<DateTime?> updatedAt = const Value.absent(),
  }) => Camp(
    id: id ?? this.id,
    ownerUid: ownerUid.present ? ownerUid.value : this.ownerUid,
    name: name ?? this.name,
    locationName: locationName ?? this.locationName,
    address: address ?? this.address,
    latitude: latitude.present ? latitude.value : this.latitude,
    longitude: longitude.present ? longitude.value : this.longitude,
    locationAccuracy: locationAccuracy.present
        ? locationAccuracy.value
        : this.locationAccuracy,
    contactNumber: contactNumber ?? this.contactNumber,
    officerName: officerName ?? this.officerName,
    officerUid: officerUid ?? this.officerUid,
    active: active ?? this.active,
    createdAt: createdAt.present ? createdAt.value : this.createdAt,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
  );
  Camp copyWithCompanion(CampsCompanion data) {
    return Camp(
      id: data.id.present ? data.id.value : this.id,
      ownerUid: data.ownerUid.present ? data.ownerUid.value : this.ownerUid,
      name: data.name.present ? data.name.value : this.name,
      locationName: data.locationName.present
          ? data.locationName.value
          : this.locationName,
      address: data.address.present ? data.address.value : this.address,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      locationAccuracy: data.locationAccuracy.present
          ? data.locationAccuracy.value
          : this.locationAccuracy,
      contactNumber: data.contactNumber.present
          ? data.contactNumber.value
          : this.contactNumber,
      officerName: data.officerName.present
          ? data.officerName.value
          : this.officerName,
      officerUid: data.officerUid.present
          ? data.officerUid.value
          : this.officerUid,
      active: data.active.present ? data.active.value : this.active,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Camp(')
          ..write('id: $id, ')
          ..write('ownerUid: $ownerUid, ')
          ..write('name: $name, ')
          ..write('locationName: $locationName, ')
          ..write('address: $address, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('locationAccuracy: $locationAccuracy, ')
          ..write('contactNumber: $contactNumber, ')
          ..write('officerName: $officerName, ')
          ..write('officerUid: $officerUid, ')
          ..write('active: $active, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    ownerUid,
    name,
    locationName,
    address,
    latitude,
    longitude,
    locationAccuracy,
    contactNumber,
    officerName,
    officerUid,
    active,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Camp &&
          other.id == this.id &&
          other.ownerUid == this.ownerUid &&
          other.name == this.name &&
          other.locationName == this.locationName &&
          other.address == this.address &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.locationAccuracy == this.locationAccuracy &&
          other.contactNumber == this.contactNumber &&
          other.officerName == this.officerName &&
          other.officerUid == this.officerUid &&
          other.active == this.active &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class CampsCompanion extends UpdateCompanion<Camp> {
  final Value<String> id;
  final Value<String?> ownerUid;
  final Value<String> name;
  final Value<String> locationName;
  final Value<String> address;
  final Value<double?> latitude;
  final Value<double?> longitude;
  final Value<double?> locationAccuracy;
  final Value<String> contactNumber;
  final Value<String> officerName;
  final Value<String> officerUid;
  final Value<bool> active;
  final Value<DateTime?> createdAt;
  final Value<DateTime?> updatedAt;
  final Value<int> rowid;
  const CampsCompanion({
    this.id = const Value.absent(),
    this.ownerUid = const Value.absent(),
    this.name = const Value.absent(),
    this.locationName = const Value.absent(),
    this.address = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.locationAccuracy = const Value.absent(),
    this.contactNumber = const Value.absent(),
    this.officerName = const Value.absent(),
    this.officerUid = const Value.absent(),
    this.active = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CampsCompanion.insert({
    required String id,
    this.ownerUid = const Value.absent(),
    required String name,
    required String locationName,
    required String address,
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.locationAccuracy = const Value.absent(),
    required String contactNumber,
    required String officerName,
    required String officerUid,
    this.active = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       locationName = Value(locationName),
       address = Value(address),
       contactNumber = Value(contactNumber),
       officerName = Value(officerName),
       officerUid = Value(officerUid);
  static Insertable<Camp> custom({
    Expression<String>? id,
    Expression<String>? ownerUid,
    Expression<String>? name,
    Expression<String>? locationName,
    Expression<String>? address,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<double>? locationAccuracy,
    Expression<String>? contactNumber,
    Expression<String>? officerName,
    Expression<String>? officerUid,
    Expression<bool>? active,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ownerUid != null) 'owner_uid': ownerUid,
      if (name != null) 'name': name,
      if (locationName != null) 'location_name': locationName,
      if (address != null) 'address': address,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (locationAccuracy != null) 'location_accuracy': locationAccuracy,
      if (contactNumber != null) 'contact_number': contactNumber,
      if (officerName != null) 'officer_name': officerName,
      if (officerUid != null) 'officer_uid': officerUid,
      if (active != null) 'active': active,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CampsCompanion copyWith({
    Value<String>? id,
    Value<String?>? ownerUid,
    Value<String>? name,
    Value<String>? locationName,
    Value<String>? address,
    Value<double?>? latitude,
    Value<double?>? longitude,
    Value<double?>? locationAccuracy,
    Value<String>? contactNumber,
    Value<String>? officerName,
    Value<String>? officerUid,
    Value<bool>? active,
    Value<DateTime?>? createdAt,
    Value<DateTime?>? updatedAt,
    Value<int>? rowid,
  }) {
    return CampsCompanion(
      id: id ?? this.id,
      ownerUid: ownerUid ?? this.ownerUid,
      name: name ?? this.name,
      locationName: locationName ?? this.locationName,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      locationAccuracy: locationAccuracy ?? this.locationAccuracy,
      contactNumber: contactNumber ?? this.contactNumber,
      officerName: officerName ?? this.officerName,
      officerUid: officerUid ?? this.officerUid,
      active: active ?? this.active,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (ownerUid.present) {
      map['owner_uid'] = Variable<String>(ownerUid.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (locationName.present) {
      map['location_name'] = Variable<String>(locationName.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (locationAccuracy.present) {
      map['location_accuracy'] = Variable<double>(locationAccuracy.value);
    }
    if (contactNumber.present) {
      map['contact_number'] = Variable<String>(contactNumber.value);
    }
    if (officerName.present) {
      map['officer_name'] = Variable<String>(officerName.value);
    }
    if (officerUid.present) {
      map['officer_uid'] = Variable<String>(officerUid.value);
    }
    if (active.present) {
      map['active'] = Variable<bool>(active.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CampsCompanion(')
          ..write('id: $id, ')
          ..write('ownerUid: $ownerUid, ')
          ..write('name: $name, ')
          ..write('locationName: $locationName, ')
          ..write('address: $address, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('locationAccuracy: $locationAccuracy, ')
          ..write('contactNumber: $contactNumber, ')
          ..write('officerName: $officerName, ')
          ..write('officerUid: $officerUid, ')
          ..write('active: $active, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $NormalRecordsTable extends NormalRecords
    with TableInfo<$NormalRecordsTable, NormalRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NormalRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ownerUidMeta = const VerificationMeta(
    'ownerUid',
  );
  @override
  late final GeneratedColumn<String> ownerUid = GeneratedColumn<String>(
    'owner_uid',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ageMeta = const VerificationMeta('age');
  @override
  late final GeneratedColumn<int> age = GeneratedColumn<int>(
    'age',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _photoUrlMeta = const VerificationMeta(
    'photoUrl',
  );
  @override
  late final GeneratedColumn<String> photoUrl = GeneratedColumn<String>(
    'photo_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _photoLocalPathMeta = const VerificationMeta(
    'photoLocalPath',
  );
  @override
  late final GeneratedColumn<String> photoLocalPath = GeneratedColumn<String>(
    'photo_local_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _campIdMeta = const VerificationMeta('campId');
  @override
  late final GeneratedColumn<String> campId = GeneratedColumn<String>(
    'camp_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _campNameMeta = const VerificationMeta(
    'campName',
  );
  @override
  late final GeneratedColumn<String> campName = GeneratedColumn<String>(
    'camp_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _officerUidMeta = const VerificationMeta(
    'officerUid',
  );
  @override
  late final GeneratedColumn<String> officerUid = GeneratedColumn<String>(
    'officer_uid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _officerNameMeta = const VerificationMeta(
    'officerName',
  );
  @override
  late final GeneratedColumn<String> officerName = GeneratedColumn<String>(
    'officer_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _officerContactMeta = const VerificationMeta(
    'officerContact',
  );
  @override
  late final GeneratedColumn<String> officerContact = GeneratedColumn<String>(
    'officer_contact',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _additionalDetailsMeta = const VerificationMeta(
    'additionalDetails',
  );
  @override
  late final GeneratedColumn<String> additionalDetails =
      GeneratedColumn<String>(
        'additional_details',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _foundAtMeta = const VerificationMeta(
    'foundAt',
  );
  @override
  late final GeneratedColumn<DateTime> foundAt = GeneratedColumn<DateTime>(
    'found_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    ownerUid,
    name,
    age,
    photoUrl,
    photoLocalPath,
    campId,
    campName,
    officerUid,
    officerName,
    officerContact,
    status,
    additionalDetails,
    foundAt,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'normal_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<NormalRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('owner_uid')) {
      context.handle(
        _ownerUidMeta,
        ownerUid.isAcceptableOrUnknown(data['owner_uid']!, _ownerUidMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('age')) {
      context.handle(
        _ageMeta,
        age.isAcceptableOrUnknown(data['age']!, _ageMeta),
      );
    } else if (isInserting) {
      context.missing(_ageMeta);
    }
    if (data.containsKey('photo_url')) {
      context.handle(
        _photoUrlMeta,
        photoUrl.isAcceptableOrUnknown(data['photo_url']!, _photoUrlMeta),
      );
    }
    if (data.containsKey('photo_local_path')) {
      context.handle(
        _photoLocalPathMeta,
        photoLocalPath.isAcceptableOrUnknown(
          data['photo_local_path']!,
          _photoLocalPathMeta,
        ),
      );
    }
    if (data.containsKey('camp_id')) {
      context.handle(
        _campIdMeta,
        campId.isAcceptableOrUnknown(data['camp_id']!, _campIdMeta),
      );
    } else if (isInserting) {
      context.missing(_campIdMeta);
    }
    if (data.containsKey('camp_name')) {
      context.handle(
        _campNameMeta,
        campName.isAcceptableOrUnknown(data['camp_name']!, _campNameMeta),
      );
    } else if (isInserting) {
      context.missing(_campNameMeta);
    }
    if (data.containsKey('officer_uid')) {
      context.handle(
        _officerUidMeta,
        officerUid.isAcceptableOrUnknown(data['officer_uid']!, _officerUidMeta),
      );
    } else if (isInserting) {
      context.missing(_officerUidMeta);
    }
    if (data.containsKey('officer_name')) {
      context.handle(
        _officerNameMeta,
        officerName.isAcceptableOrUnknown(
          data['officer_name']!,
          _officerNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_officerNameMeta);
    }
    if (data.containsKey('officer_contact')) {
      context.handle(
        _officerContactMeta,
        officerContact.isAcceptableOrUnknown(
          data['officer_contact']!,
          _officerContactMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_officerContactMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('additional_details')) {
      context.handle(
        _additionalDetailsMeta,
        additionalDetails.isAcceptableOrUnknown(
          data['additional_details']!,
          _additionalDetailsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_additionalDetailsMeta);
    }
    if (data.containsKey('found_at')) {
      context.handle(
        _foundAtMeta,
        foundAt.isAcceptableOrUnknown(data['found_at']!, _foundAtMeta),
      );
    } else if (isInserting) {
      context.missing(_foundAtMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  NormalRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NormalRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      ownerUid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_uid'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      age: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}age'],
      )!,
      photoUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}photo_url'],
      ),
      photoLocalPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}photo_local_path'],
      ),
      campId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}camp_id'],
      )!,
      campName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}camp_name'],
      )!,
      officerUid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}officer_uid'],
      )!,
      officerName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}officer_name'],
      )!,
      officerContact: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}officer_contact'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      additionalDetails: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}additional_details'],
      )!,
      foundAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}found_at'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      ),
    );
  }

  @override
  $NormalRecordsTable createAlias(String alias) {
    return $NormalRecordsTable(attachedDatabase, alias);
  }
}

class NormalRecord extends DataClass implements Insertable<NormalRecord> {
  final String id;
  final String? ownerUid;
  final String name;
  final int age;
  final String? photoUrl;
  final String? photoLocalPath;
  final String campId;
  final String campName;
  final String officerUid;
  final String officerName;
  final String officerContact;
  final String status;
  final String additionalDetails;
  final DateTime foundAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  const NormalRecord({
    required this.id,
    this.ownerUid,
    required this.name,
    required this.age,
    this.photoUrl,
    this.photoLocalPath,
    required this.campId,
    required this.campName,
    required this.officerUid,
    required this.officerName,
    required this.officerContact,
    required this.status,
    required this.additionalDetails,
    required this.foundAt,
    this.createdAt,
    this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || ownerUid != null) {
      map['owner_uid'] = Variable<String>(ownerUid);
    }
    map['name'] = Variable<String>(name);
    map['age'] = Variable<int>(age);
    if (!nullToAbsent || photoUrl != null) {
      map['photo_url'] = Variable<String>(photoUrl);
    }
    if (!nullToAbsent || photoLocalPath != null) {
      map['photo_local_path'] = Variable<String>(photoLocalPath);
    }
    map['camp_id'] = Variable<String>(campId);
    map['camp_name'] = Variable<String>(campName);
    map['officer_uid'] = Variable<String>(officerUid);
    map['officer_name'] = Variable<String>(officerName);
    map['officer_contact'] = Variable<String>(officerContact);
    map['status'] = Variable<String>(status);
    map['additional_details'] = Variable<String>(additionalDetails);
    map['found_at'] = Variable<DateTime>(foundAt);
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<DateTime>(createdAt);
    }
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    return map;
  }

  NormalRecordsCompanion toCompanion(bool nullToAbsent) {
    return NormalRecordsCompanion(
      id: Value(id),
      ownerUid: ownerUid == null && nullToAbsent
          ? const Value.absent()
          : Value(ownerUid),
      name: Value(name),
      age: Value(age),
      photoUrl: photoUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(photoUrl),
      photoLocalPath: photoLocalPath == null && nullToAbsent
          ? const Value.absent()
          : Value(photoLocalPath),
      campId: Value(campId),
      campName: Value(campName),
      officerUid: Value(officerUid),
      officerName: Value(officerName),
      officerContact: Value(officerContact),
      status: Value(status),
      additionalDetails: Value(additionalDetails),
      foundAt: Value(foundAt),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory NormalRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NormalRecord(
      id: serializer.fromJson<String>(json['id']),
      ownerUid: serializer.fromJson<String?>(json['ownerUid']),
      name: serializer.fromJson<String>(json['name']),
      age: serializer.fromJson<int>(json['age']),
      photoUrl: serializer.fromJson<String?>(json['photoUrl']),
      photoLocalPath: serializer.fromJson<String?>(json['photoLocalPath']),
      campId: serializer.fromJson<String>(json['campId']),
      campName: serializer.fromJson<String>(json['campName']),
      officerUid: serializer.fromJson<String>(json['officerUid']),
      officerName: serializer.fromJson<String>(json['officerName']),
      officerContact: serializer.fromJson<String>(json['officerContact']),
      status: serializer.fromJson<String>(json['status']),
      additionalDetails: serializer.fromJson<String>(json['additionalDetails']),
      foundAt: serializer.fromJson<DateTime>(json['foundAt']),
      createdAt: serializer.fromJson<DateTime?>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'ownerUid': serializer.toJson<String?>(ownerUid),
      'name': serializer.toJson<String>(name),
      'age': serializer.toJson<int>(age),
      'photoUrl': serializer.toJson<String?>(photoUrl),
      'photoLocalPath': serializer.toJson<String?>(photoLocalPath),
      'campId': serializer.toJson<String>(campId),
      'campName': serializer.toJson<String>(campName),
      'officerUid': serializer.toJson<String>(officerUid),
      'officerName': serializer.toJson<String>(officerName),
      'officerContact': serializer.toJson<String>(officerContact),
      'status': serializer.toJson<String>(status),
      'additionalDetails': serializer.toJson<String>(additionalDetails),
      'foundAt': serializer.toJson<DateTime>(foundAt),
      'createdAt': serializer.toJson<DateTime?>(createdAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
    };
  }

  NormalRecord copyWith({
    String? id,
    Value<String?> ownerUid = const Value.absent(),
    String? name,
    int? age,
    Value<String?> photoUrl = const Value.absent(),
    Value<String?> photoLocalPath = const Value.absent(),
    String? campId,
    String? campName,
    String? officerUid,
    String? officerName,
    String? officerContact,
    String? status,
    String? additionalDetails,
    DateTime? foundAt,
    Value<DateTime?> createdAt = const Value.absent(),
    Value<DateTime?> updatedAt = const Value.absent(),
  }) => NormalRecord(
    id: id ?? this.id,
    ownerUid: ownerUid.present ? ownerUid.value : this.ownerUid,
    name: name ?? this.name,
    age: age ?? this.age,
    photoUrl: photoUrl.present ? photoUrl.value : this.photoUrl,
    photoLocalPath: photoLocalPath.present
        ? photoLocalPath.value
        : this.photoLocalPath,
    campId: campId ?? this.campId,
    campName: campName ?? this.campName,
    officerUid: officerUid ?? this.officerUid,
    officerName: officerName ?? this.officerName,
    officerContact: officerContact ?? this.officerContact,
    status: status ?? this.status,
    additionalDetails: additionalDetails ?? this.additionalDetails,
    foundAt: foundAt ?? this.foundAt,
    createdAt: createdAt.present ? createdAt.value : this.createdAt,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
  );
  NormalRecord copyWithCompanion(NormalRecordsCompanion data) {
    return NormalRecord(
      id: data.id.present ? data.id.value : this.id,
      ownerUid: data.ownerUid.present ? data.ownerUid.value : this.ownerUid,
      name: data.name.present ? data.name.value : this.name,
      age: data.age.present ? data.age.value : this.age,
      photoUrl: data.photoUrl.present ? data.photoUrl.value : this.photoUrl,
      photoLocalPath: data.photoLocalPath.present
          ? data.photoLocalPath.value
          : this.photoLocalPath,
      campId: data.campId.present ? data.campId.value : this.campId,
      campName: data.campName.present ? data.campName.value : this.campName,
      officerUid: data.officerUid.present
          ? data.officerUid.value
          : this.officerUid,
      officerName: data.officerName.present
          ? data.officerName.value
          : this.officerName,
      officerContact: data.officerContact.present
          ? data.officerContact.value
          : this.officerContact,
      status: data.status.present ? data.status.value : this.status,
      additionalDetails: data.additionalDetails.present
          ? data.additionalDetails.value
          : this.additionalDetails,
      foundAt: data.foundAt.present ? data.foundAt.value : this.foundAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NormalRecord(')
          ..write('id: $id, ')
          ..write('ownerUid: $ownerUid, ')
          ..write('name: $name, ')
          ..write('age: $age, ')
          ..write('photoUrl: $photoUrl, ')
          ..write('photoLocalPath: $photoLocalPath, ')
          ..write('campId: $campId, ')
          ..write('campName: $campName, ')
          ..write('officerUid: $officerUid, ')
          ..write('officerName: $officerName, ')
          ..write('officerContact: $officerContact, ')
          ..write('status: $status, ')
          ..write('additionalDetails: $additionalDetails, ')
          ..write('foundAt: $foundAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    ownerUid,
    name,
    age,
    photoUrl,
    photoLocalPath,
    campId,
    campName,
    officerUid,
    officerName,
    officerContact,
    status,
    additionalDetails,
    foundAt,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NormalRecord &&
          other.id == this.id &&
          other.ownerUid == this.ownerUid &&
          other.name == this.name &&
          other.age == this.age &&
          other.photoUrl == this.photoUrl &&
          other.photoLocalPath == this.photoLocalPath &&
          other.campId == this.campId &&
          other.campName == this.campName &&
          other.officerUid == this.officerUid &&
          other.officerName == this.officerName &&
          other.officerContact == this.officerContact &&
          other.status == this.status &&
          other.additionalDetails == this.additionalDetails &&
          other.foundAt == this.foundAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class NormalRecordsCompanion extends UpdateCompanion<NormalRecord> {
  final Value<String> id;
  final Value<String?> ownerUid;
  final Value<String> name;
  final Value<int> age;
  final Value<String?> photoUrl;
  final Value<String?> photoLocalPath;
  final Value<String> campId;
  final Value<String> campName;
  final Value<String> officerUid;
  final Value<String> officerName;
  final Value<String> officerContact;
  final Value<String> status;
  final Value<String> additionalDetails;
  final Value<DateTime> foundAt;
  final Value<DateTime?> createdAt;
  final Value<DateTime?> updatedAt;
  final Value<int> rowid;
  const NormalRecordsCompanion({
    this.id = const Value.absent(),
    this.ownerUid = const Value.absent(),
    this.name = const Value.absent(),
    this.age = const Value.absent(),
    this.photoUrl = const Value.absent(),
    this.photoLocalPath = const Value.absent(),
    this.campId = const Value.absent(),
    this.campName = const Value.absent(),
    this.officerUid = const Value.absent(),
    this.officerName = const Value.absent(),
    this.officerContact = const Value.absent(),
    this.status = const Value.absent(),
    this.additionalDetails = const Value.absent(),
    this.foundAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  NormalRecordsCompanion.insert({
    required String id,
    this.ownerUid = const Value.absent(),
    required String name,
    required int age,
    this.photoUrl = const Value.absent(),
    this.photoLocalPath = const Value.absent(),
    required String campId,
    required String campName,
    required String officerUid,
    required String officerName,
    required String officerContact,
    required String status,
    required String additionalDetails,
    required DateTime foundAt,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       age = Value(age),
       campId = Value(campId),
       campName = Value(campName),
       officerUid = Value(officerUid),
       officerName = Value(officerName),
       officerContact = Value(officerContact),
       status = Value(status),
       additionalDetails = Value(additionalDetails),
       foundAt = Value(foundAt);
  static Insertable<NormalRecord> custom({
    Expression<String>? id,
    Expression<String>? ownerUid,
    Expression<String>? name,
    Expression<int>? age,
    Expression<String>? photoUrl,
    Expression<String>? photoLocalPath,
    Expression<String>? campId,
    Expression<String>? campName,
    Expression<String>? officerUid,
    Expression<String>? officerName,
    Expression<String>? officerContact,
    Expression<String>? status,
    Expression<String>? additionalDetails,
    Expression<DateTime>? foundAt,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ownerUid != null) 'owner_uid': ownerUid,
      if (name != null) 'name': name,
      if (age != null) 'age': age,
      if (photoUrl != null) 'photo_url': photoUrl,
      if (photoLocalPath != null) 'photo_local_path': photoLocalPath,
      if (campId != null) 'camp_id': campId,
      if (campName != null) 'camp_name': campName,
      if (officerUid != null) 'officer_uid': officerUid,
      if (officerName != null) 'officer_name': officerName,
      if (officerContact != null) 'officer_contact': officerContact,
      if (status != null) 'status': status,
      if (additionalDetails != null) 'additional_details': additionalDetails,
      if (foundAt != null) 'found_at': foundAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  NormalRecordsCompanion copyWith({
    Value<String>? id,
    Value<String?>? ownerUid,
    Value<String>? name,
    Value<int>? age,
    Value<String?>? photoUrl,
    Value<String?>? photoLocalPath,
    Value<String>? campId,
    Value<String>? campName,
    Value<String>? officerUid,
    Value<String>? officerName,
    Value<String>? officerContact,
    Value<String>? status,
    Value<String>? additionalDetails,
    Value<DateTime>? foundAt,
    Value<DateTime?>? createdAt,
    Value<DateTime?>? updatedAt,
    Value<int>? rowid,
  }) {
    return NormalRecordsCompanion(
      id: id ?? this.id,
      ownerUid: ownerUid ?? this.ownerUid,
      name: name ?? this.name,
      age: age ?? this.age,
      photoUrl: photoUrl ?? this.photoUrl,
      photoLocalPath: photoLocalPath ?? this.photoLocalPath,
      campId: campId ?? this.campId,
      campName: campName ?? this.campName,
      officerUid: officerUid ?? this.officerUid,
      officerName: officerName ?? this.officerName,
      officerContact: officerContact ?? this.officerContact,
      status: status ?? this.status,
      additionalDetails: additionalDetails ?? this.additionalDetails,
      foundAt: foundAt ?? this.foundAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (ownerUid.present) {
      map['owner_uid'] = Variable<String>(ownerUid.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (age.present) {
      map['age'] = Variable<int>(age.value);
    }
    if (photoUrl.present) {
      map['photo_url'] = Variable<String>(photoUrl.value);
    }
    if (photoLocalPath.present) {
      map['photo_local_path'] = Variable<String>(photoLocalPath.value);
    }
    if (campId.present) {
      map['camp_id'] = Variable<String>(campId.value);
    }
    if (campName.present) {
      map['camp_name'] = Variable<String>(campName.value);
    }
    if (officerUid.present) {
      map['officer_uid'] = Variable<String>(officerUid.value);
    }
    if (officerName.present) {
      map['officer_name'] = Variable<String>(officerName.value);
    }
    if (officerContact.present) {
      map['officer_contact'] = Variable<String>(officerContact.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (additionalDetails.present) {
      map['additional_details'] = Variable<String>(additionalDetails.value);
    }
    if (foundAt.present) {
      map['found_at'] = Variable<DateTime>(foundAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NormalRecordsCompanion(')
          ..write('id: $id, ')
          ..write('ownerUid: $ownerUid, ')
          ..write('name: $name, ')
          ..write('age: $age, ')
          ..write('photoUrl: $photoUrl, ')
          ..write('photoLocalPath: $photoLocalPath, ')
          ..write('campId: $campId, ')
          ..write('campName: $campName, ')
          ..write('officerUid: $officerUid, ')
          ..write('officerName: $officerName, ')
          ..write('officerContact: $officerContact, ')
          ..write('status: $status, ')
          ..write('additionalDetails: $additionalDetails, ')
          ..write('foundAt: $foundAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CriticalRecordsTable extends CriticalRecords
    with TableInfo<$CriticalRecordsTable, CriticalRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CriticalRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ownerUidMeta = const VerificationMeta(
    'ownerUid',
  );
  @override
  late final GeneratedColumn<String> ownerUid = GeneratedColumn<String>(
    'owner_uid',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ageMeta = const VerificationMeta('age');
  @override
  late final GeneratedColumn<int> age = GeneratedColumn<int>(
    'age',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _photoUrlMeta = const VerificationMeta(
    'photoUrl',
  );
  @override
  late final GeneratedColumn<String> photoUrl = GeneratedColumn<String>(
    'photo_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _clothingPhotoUrlMeta = const VerificationMeta(
    'clothingPhotoUrl',
  );
  @override
  late final GeneratedColumn<String> clothingPhotoUrl = GeneratedColumn<String>(
    'clothing_photo_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _photoLocalPathMeta = const VerificationMeta(
    'photoLocalPath',
  );
  @override
  late final GeneratedColumn<String> photoLocalPath = GeneratedColumn<String>(
    'photo_local_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _clothingPhotoLocalPathMeta =
      const VerificationMeta('clothingPhotoLocalPath');
  @override
  late final GeneratedColumn<String> clothingPhotoLocalPath =
      GeneratedColumn<String>(
        'clothing_photo_local_path',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _lastKnownClothingMeta = const VerificationMeta(
    'lastKnownClothing',
  );
  @override
  late final GeneratedColumn<String> lastKnownClothing =
      GeneratedColumn<String>(
        'last_known_clothing',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _campIdMeta = const VerificationMeta('campId');
  @override
  late final GeneratedColumn<String> campId = GeneratedColumn<String>(
    'camp_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _campNameMeta = const VerificationMeta(
    'campName',
  );
  @override
  late final GeneratedColumn<String> campName = GeneratedColumn<String>(
    'camp_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _officerUidMeta = const VerificationMeta(
    'officerUid',
  );
  @override
  late final GeneratedColumn<String> officerUid = GeneratedColumn<String>(
    'officer_uid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _officerNameMeta = const VerificationMeta(
    'officerName',
  );
  @override
  late final GeneratedColumn<String> officerName = GeneratedColumn<String>(
    'officer_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _officerContactMeta = const VerificationMeta(
    'officerContact',
  );
  @override
  late final GeneratedColumn<String> officerContact = GeneratedColumn<String>(
    'officer_contact',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _foundLocationMeta = const VerificationMeta(
    'foundLocation',
  );
  @override
  late final GeneratedColumn<String> foundLocation = GeneratedColumn<String>(
    'found_location',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _foundLatitudeMeta = const VerificationMeta(
    'foundLatitude',
  );
  @override
  late final GeneratedColumn<double> foundLatitude = GeneratedColumn<double>(
    'found_latitude',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _foundLongitudeMeta = const VerificationMeta(
    'foundLongitude',
  );
  @override
  late final GeneratedColumn<double> foundLongitude = GeneratedColumn<double>(
    'found_longitude',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _locationAccuracyMeta = const VerificationMeta(
    'locationAccuracy',
  );
  @override
  late final GeneratedColumn<double> locationAccuracy = GeneratedColumn<double>(
    'location_accuracy',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _additionalDetailsMeta = const VerificationMeta(
    'additionalDetails',
  );
  @override
  late final GeneratedColumn<String> additionalDetails =
      GeneratedColumn<String>(
        'additional_details',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _foundAtMeta = const VerificationMeta(
    'foundAt',
  );
  @override
  late final GeneratedColumn<DateTime> foundAt = GeneratedColumn<DateTime>(
    'found_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    ownerUid,
    name,
    age,
    photoUrl,
    clothingPhotoUrl,
    photoLocalPath,
    clothingPhotoLocalPath,
    lastKnownClothing,
    campId,
    campName,
    officerUid,
    officerName,
    officerContact,
    foundLocation,
    foundLatitude,
    foundLongitude,
    locationAccuracy,
    additionalDetails,
    status,
    foundAt,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'critical_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<CriticalRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('owner_uid')) {
      context.handle(
        _ownerUidMeta,
        ownerUid.isAcceptableOrUnknown(data['owner_uid']!, _ownerUidMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('age')) {
      context.handle(
        _ageMeta,
        age.isAcceptableOrUnknown(data['age']!, _ageMeta),
      );
    } else if (isInserting) {
      context.missing(_ageMeta);
    }
    if (data.containsKey('photo_url')) {
      context.handle(
        _photoUrlMeta,
        photoUrl.isAcceptableOrUnknown(data['photo_url']!, _photoUrlMeta),
      );
    }
    if (data.containsKey('clothing_photo_url')) {
      context.handle(
        _clothingPhotoUrlMeta,
        clothingPhotoUrl.isAcceptableOrUnknown(
          data['clothing_photo_url']!,
          _clothingPhotoUrlMeta,
        ),
      );
    }
    if (data.containsKey('photo_local_path')) {
      context.handle(
        _photoLocalPathMeta,
        photoLocalPath.isAcceptableOrUnknown(
          data['photo_local_path']!,
          _photoLocalPathMeta,
        ),
      );
    }
    if (data.containsKey('clothing_photo_local_path')) {
      context.handle(
        _clothingPhotoLocalPathMeta,
        clothingPhotoLocalPath.isAcceptableOrUnknown(
          data['clothing_photo_local_path']!,
          _clothingPhotoLocalPathMeta,
        ),
      );
    }
    if (data.containsKey('last_known_clothing')) {
      context.handle(
        _lastKnownClothingMeta,
        lastKnownClothing.isAcceptableOrUnknown(
          data['last_known_clothing']!,
          _lastKnownClothingMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastKnownClothingMeta);
    }
    if (data.containsKey('camp_id')) {
      context.handle(
        _campIdMeta,
        campId.isAcceptableOrUnknown(data['camp_id']!, _campIdMeta),
      );
    } else if (isInserting) {
      context.missing(_campIdMeta);
    }
    if (data.containsKey('camp_name')) {
      context.handle(
        _campNameMeta,
        campName.isAcceptableOrUnknown(data['camp_name']!, _campNameMeta),
      );
    } else if (isInserting) {
      context.missing(_campNameMeta);
    }
    if (data.containsKey('officer_uid')) {
      context.handle(
        _officerUidMeta,
        officerUid.isAcceptableOrUnknown(data['officer_uid']!, _officerUidMeta),
      );
    } else if (isInserting) {
      context.missing(_officerUidMeta);
    }
    if (data.containsKey('officer_name')) {
      context.handle(
        _officerNameMeta,
        officerName.isAcceptableOrUnknown(
          data['officer_name']!,
          _officerNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_officerNameMeta);
    }
    if (data.containsKey('officer_contact')) {
      context.handle(
        _officerContactMeta,
        officerContact.isAcceptableOrUnknown(
          data['officer_contact']!,
          _officerContactMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_officerContactMeta);
    }
    if (data.containsKey('found_location')) {
      context.handle(
        _foundLocationMeta,
        foundLocation.isAcceptableOrUnknown(
          data['found_location']!,
          _foundLocationMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_foundLocationMeta);
    }
    if (data.containsKey('found_latitude')) {
      context.handle(
        _foundLatitudeMeta,
        foundLatitude.isAcceptableOrUnknown(
          data['found_latitude']!,
          _foundLatitudeMeta,
        ),
      );
    }
    if (data.containsKey('found_longitude')) {
      context.handle(
        _foundLongitudeMeta,
        foundLongitude.isAcceptableOrUnknown(
          data['found_longitude']!,
          _foundLongitudeMeta,
        ),
      );
    }
    if (data.containsKey('location_accuracy')) {
      context.handle(
        _locationAccuracyMeta,
        locationAccuracy.isAcceptableOrUnknown(
          data['location_accuracy']!,
          _locationAccuracyMeta,
        ),
      );
    }
    if (data.containsKey('additional_details')) {
      context.handle(
        _additionalDetailsMeta,
        additionalDetails.isAcceptableOrUnknown(
          data['additional_details']!,
          _additionalDetailsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_additionalDetailsMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('found_at')) {
      context.handle(
        _foundAtMeta,
        foundAt.isAcceptableOrUnknown(data['found_at']!, _foundAtMeta),
      );
    } else if (isInserting) {
      context.missing(_foundAtMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CriticalRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CriticalRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      ownerUid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_uid'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      age: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}age'],
      )!,
      photoUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}photo_url'],
      ),
      clothingPhotoUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}clothing_photo_url'],
      ),
      photoLocalPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}photo_local_path'],
      ),
      clothingPhotoLocalPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}clothing_photo_local_path'],
      ),
      lastKnownClothing: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_known_clothing'],
      )!,
      campId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}camp_id'],
      )!,
      campName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}camp_name'],
      )!,
      officerUid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}officer_uid'],
      )!,
      officerName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}officer_name'],
      )!,
      officerContact: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}officer_contact'],
      )!,
      foundLocation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}found_location'],
      )!,
      foundLatitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}found_latitude'],
      ),
      foundLongitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}found_longitude'],
      ),
      locationAccuracy: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}location_accuracy'],
      ),
      additionalDetails: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}additional_details'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      foundAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}found_at'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      ),
    );
  }

  @override
  $CriticalRecordsTable createAlias(String alias) {
    return $CriticalRecordsTable(attachedDatabase, alias);
  }
}

class CriticalRecord extends DataClass implements Insertable<CriticalRecord> {
  final String id;
  final String? ownerUid;
  final String name;
  final int age;
  final String? photoUrl;
  final String? clothingPhotoUrl;
  final String? photoLocalPath;
  final String? clothingPhotoLocalPath;
  final String lastKnownClothing;
  final String campId;
  final String campName;
  final String officerUid;
  final String officerName;
  final String officerContact;
  final String foundLocation;
  final double? foundLatitude;
  final double? foundLongitude;
  final double? locationAccuracy;
  final String additionalDetails;
  final String status;
  final DateTime foundAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  const CriticalRecord({
    required this.id,
    this.ownerUid,
    required this.name,
    required this.age,
    this.photoUrl,
    this.clothingPhotoUrl,
    this.photoLocalPath,
    this.clothingPhotoLocalPath,
    required this.lastKnownClothing,
    required this.campId,
    required this.campName,
    required this.officerUid,
    required this.officerName,
    required this.officerContact,
    required this.foundLocation,
    this.foundLatitude,
    this.foundLongitude,
    this.locationAccuracy,
    required this.additionalDetails,
    required this.status,
    required this.foundAt,
    this.createdAt,
    this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || ownerUid != null) {
      map['owner_uid'] = Variable<String>(ownerUid);
    }
    map['name'] = Variable<String>(name);
    map['age'] = Variable<int>(age);
    if (!nullToAbsent || photoUrl != null) {
      map['photo_url'] = Variable<String>(photoUrl);
    }
    if (!nullToAbsent || clothingPhotoUrl != null) {
      map['clothing_photo_url'] = Variable<String>(clothingPhotoUrl);
    }
    if (!nullToAbsent || photoLocalPath != null) {
      map['photo_local_path'] = Variable<String>(photoLocalPath);
    }
    if (!nullToAbsent || clothingPhotoLocalPath != null) {
      map['clothing_photo_local_path'] = Variable<String>(
        clothingPhotoLocalPath,
      );
    }
    map['last_known_clothing'] = Variable<String>(lastKnownClothing);
    map['camp_id'] = Variable<String>(campId);
    map['camp_name'] = Variable<String>(campName);
    map['officer_uid'] = Variable<String>(officerUid);
    map['officer_name'] = Variable<String>(officerName);
    map['officer_contact'] = Variable<String>(officerContact);
    map['found_location'] = Variable<String>(foundLocation);
    if (!nullToAbsent || foundLatitude != null) {
      map['found_latitude'] = Variable<double>(foundLatitude);
    }
    if (!nullToAbsent || foundLongitude != null) {
      map['found_longitude'] = Variable<double>(foundLongitude);
    }
    if (!nullToAbsent || locationAccuracy != null) {
      map['location_accuracy'] = Variable<double>(locationAccuracy);
    }
    map['additional_details'] = Variable<String>(additionalDetails);
    map['status'] = Variable<String>(status);
    map['found_at'] = Variable<DateTime>(foundAt);
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<DateTime>(createdAt);
    }
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    return map;
  }

  CriticalRecordsCompanion toCompanion(bool nullToAbsent) {
    return CriticalRecordsCompanion(
      id: Value(id),
      ownerUid: ownerUid == null && nullToAbsent
          ? const Value.absent()
          : Value(ownerUid),
      name: Value(name),
      age: Value(age),
      photoUrl: photoUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(photoUrl),
      clothingPhotoUrl: clothingPhotoUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(clothingPhotoUrl),
      photoLocalPath: photoLocalPath == null && nullToAbsent
          ? const Value.absent()
          : Value(photoLocalPath),
      clothingPhotoLocalPath: clothingPhotoLocalPath == null && nullToAbsent
          ? const Value.absent()
          : Value(clothingPhotoLocalPath),
      lastKnownClothing: Value(lastKnownClothing),
      campId: Value(campId),
      campName: Value(campName),
      officerUid: Value(officerUid),
      officerName: Value(officerName),
      officerContact: Value(officerContact),
      foundLocation: Value(foundLocation),
      foundLatitude: foundLatitude == null && nullToAbsent
          ? const Value.absent()
          : Value(foundLatitude),
      foundLongitude: foundLongitude == null && nullToAbsent
          ? const Value.absent()
          : Value(foundLongitude),
      locationAccuracy: locationAccuracy == null && nullToAbsent
          ? const Value.absent()
          : Value(locationAccuracy),
      additionalDetails: Value(additionalDetails),
      status: Value(status),
      foundAt: Value(foundAt),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory CriticalRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CriticalRecord(
      id: serializer.fromJson<String>(json['id']),
      ownerUid: serializer.fromJson<String?>(json['ownerUid']),
      name: serializer.fromJson<String>(json['name']),
      age: serializer.fromJson<int>(json['age']),
      photoUrl: serializer.fromJson<String?>(json['photoUrl']),
      clothingPhotoUrl: serializer.fromJson<String?>(json['clothingPhotoUrl']),
      photoLocalPath: serializer.fromJson<String?>(json['photoLocalPath']),
      clothingPhotoLocalPath: serializer.fromJson<String?>(
        json['clothingPhotoLocalPath'],
      ),
      lastKnownClothing: serializer.fromJson<String>(json['lastKnownClothing']),
      campId: serializer.fromJson<String>(json['campId']),
      campName: serializer.fromJson<String>(json['campName']),
      officerUid: serializer.fromJson<String>(json['officerUid']),
      officerName: serializer.fromJson<String>(json['officerName']),
      officerContact: serializer.fromJson<String>(json['officerContact']),
      foundLocation: serializer.fromJson<String>(json['foundLocation']),
      foundLatitude: serializer.fromJson<double?>(json['foundLatitude']),
      foundLongitude: serializer.fromJson<double?>(json['foundLongitude']),
      locationAccuracy: serializer.fromJson<double?>(json['locationAccuracy']),
      additionalDetails: serializer.fromJson<String>(json['additionalDetails']),
      status: serializer.fromJson<String>(json['status']),
      foundAt: serializer.fromJson<DateTime>(json['foundAt']),
      createdAt: serializer.fromJson<DateTime?>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'ownerUid': serializer.toJson<String?>(ownerUid),
      'name': serializer.toJson<String>(name),
      'age': serializer.toJson<int>(age),
      'photoUrl': serializer.toJson<String?>(photoUrl),
      'clothingPhotoUrl': serializer.toJson<String?>(clothingPhotoUrl),
      'photoLocalPath': serializer.toJson<String?>(photoLocalPath),
      'clothingPhotoLocalPath': serializer.toJson<String?>(
        clothingPhotoLocalPath,
      ),
      'lastKnownClothing': serializer.toJson<String>(lastKnownClothing),
      'campId': serializer.toJson<String>(campId),
      'campName': serializer.toJson<String>(campName),
      'officerUid': serializer.toJson<String>(officerUid),
      'officerName': serializer.toJson<String>(officerName),
      'officerContact': serializer.toJson<String>(officerContact),
      'foundLocation': serializer.toJson<String>(foundLocation),
      'foundLatitude': serializer.toJson<double?>(foundLatitude),
      'foundLongitude': serializer.toJson<double?>(foundLongitude),
      'locationAccuracy': serializer.toJson<double?>(locationAccuracy),
      'additionalDetails': serializer.toJson<String>(additionalDetails),
      'status': serializer.toJson<String>(status),
      'foundAt': serializer.toJson<DateTime>(foundAt),
      'createdAt': serializer.toJson<DateTime?>(createdAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
    };
  }

  CriticalRecord copyWith({
    String? id,
    Value<String?> ownerUid = const Value.absent(),
    String? name,
    int? age,
    Value<String?> photoUrl = const Value.absent(),
    Value<String?> clothingPhotoUrl = const Value.absent(),
    Value<String?> photoLocalPath = const Value.absent(),
    Value<String?> clothingPhotoLocalPath = const Value.absent(),
    String? lastKnownClothing,
    String? campId,
    String? campName,
    String? officerUid,
    String? officerName,
    String? officerContact,
    String? foundLocation,
    Value<double?> foundLatitude = const Value.absent(),
    Value<double?> foundLongitude = const Value.absent(),
    Value<double?> locationAccuracy = const Value.absent(),
    String? additionalDetails,
    String? status,
    DateTime? foundAt,
    Value<DateTime?> createdAt = const Value.absent(),
    Value<DateTime?> updatedAt = const Value.absent(),
  }) => CriticalRecord(
    id: id ?? this.id,
    ownerUid: ownerUid.present ? ownerUid.value : this.ownerUid,
    name: name ?? this.name,
    age: age ?? this.age,
    photoUrl: photoUrl.present ? photoUrl.value : this.photoUrl,
    clothingPhotoUrl: clothingPhotoUrl.present
        ? clothingPhotoUrl.value
        : this.clothingPhotoUrl,
    photoLocalPath: photoLocalPath.present
        ? photoLocalPath.value
        : this.photoLocalPath,
    clothingPhotoLocalPath: clothingPhotoLocalPath.present
        ? clothingPhotoLocalPath.value
        : this.clothingPhotoLocalPath,
    lastKnownClothing: lastKnownClothing ?? this.lastKnownClothing,
    campId: campId ?? this.campId,
    campName: campName ?? this.campName,
    officerUid: officerUid ?? this.officerUid,
    officerName: officerName ?? this.officerName,
    officerContact: officerContact ?? this.officerContact,
    foundLocation: foundLocation ?? this.foundLocation,
    foundLatitude: foundLatitude.present
        ? foundLatitude.value
        : this.foundLatitude,
    foundLongitude: foundLongitude.present
        ? foundLongitude.value
        : this.foundLongitude,
    locationAccuracy: locationAccuracy.present
        ? locationAccuracy.value
        : this.locationAccuracy,
    additionalDetails: additionalDetails ?? this.additionalDetails,
    status: status ?? this.status,
    foundAt: foundAt ?? this.foundAt,
    createdAt: createdAt.present ? createdAt.value : this.createdAt,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
  );
  CriticalRecord copyWithCompanion(CriticalRecordsCompanion data) {
    return CriticalRecord(
      id: data.id.present ? data.id.value : this.id,
      ownerUid: data.ownerUid.present ? data.ownerUid.value : this.ownerUid,
      name: data.name.present ? data.name.value : this.name,
      age: data.age.present ? data.age.value : this.age,
      photoUrl: data.photoUrl.present ? data.photoUrl.value : this.photoUrl,
      clothingPhotoUrl: data.clothingPhotoUrl.present
          ? data.clothingPhotoUrl.value
          : this.clothingPhotoUrl,
      photoLocalPath: data.photoLocalPath.present
          ? data.photoLocalPath.value
          : this.photoLocalPath,
      clothingPhotoLocalPath: data.clothingPhotoLocalPath.present
          ? data.clothingPhotoLocalPath.value
          : this.clothingPhotoLocalPath,
      lastKnownClothing: data.lastKnownClothing.present
          ? data.lastKnownClothing.value
          : this.lastKnownClothing,
      campId: data.campId.present ? data.campId.value : this.campId,
      campName: data.campName.present ? data.campName.value : this.campName,
      officerUid: data.officerUid.present
          ? data.officerUid.value
          : this.officerUid,
      officerName: data.officerName.present
          ? data.officerName.value
          : this.officerName,
      officerContact: data.officerContact.present
          ? data.officerContact.value
          : this.officerContact,
      foundLocation: data.foundLocation.present
          ? data.foundLocation.value
          : this.foundLocation,
      foundLatitude: data.foundLatitude.present
          ? data.foundLatitude.value
          : this.foundLatitude,
      foundLongitude: data.foundLongitude.present
          ? data.foundLongitude.value
          : this.foundLongitude,
      locationAccuracy: data.locationAccuracy.present
          ? data.locationAccuracy.value
          : this.locationAccuracy,
      additionalDetails: data.additionalDetails.present
          ? data.additionalDetails.value
          : this.additionalDetails,
      status: data.status.present ? data.status.value : this.status,
      foundAt: data.foundAt.present ? data.foundAt.value : this.foundAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CriticalRecord(')
          ..write('id: $id, ')
          ..write('ownerUid: $ownerUid, ')
          ..write('name: $name, ')
          ..write('age: $age, ')
          ..write('photoUrl: $photoUrl, ')
          ..write('clothingPhotoUrl: $clothingPhotoUrl, ')
          ..write('photoLocalPath: $photoLocalPath, ')
          ..write('clothingPhotoLocalPath: $clothingPhotoLocalPath, ')
          ..write('lastKnownClothing: $lastKnownClothing, ')
          ..write('campId: $campId, ')
          ..write('campName: $campName, ')
          ..write('officerUid: $officerUid, ')
          ..write('officerName: $officerName, ')
          ..write('officerContact: $officerContact, ')
          ..write('foundLocation: $foundLocation, ')
          ..write('foundLatitude: $foundLatitude, ')
          ..write('foundLongitude: $foundLongitude, ')
          ..write('locationAccuracy: $locationAccuracy, ')
          ..write('additionalDetails: $additionalDetails, ')
          ..write('status: $status, ')
          ..write('foundAt: $foundAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    ownerUid,
    name,
    age,
    photoUrl,
    clothingPhotoUrl,
    photoLocalPath,
    clothingPhotoLocalPath,
    lastKnownClothing,
    campId,
    campName,
    officerUid,
    officerName,
    officerContact,
    foundLocation,
    foundLatitude,
    foundLongitude,
    locationAccuracy,
    additionalDetails,
    status,
    foundAt,
    createdAt,
    updatedAt,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CriticalRecord &&
          other.id == this.id &&
          other.ownerUid == this.ownerUid &&
          other.name == this.name &&
          other.age == this.age &&
          other.photoUrl == this.photoUrl &&
          other.clothingPhotoUrl == this.clothingPhotoUrl &&
          other.photoLocalPath == this.photoLocalPath &&
          other.clothingPhotoLocalPath == this.clothingPhotoLocalPath &&
          other.lastKnownClothing == this.lastKnownClothing &&
          other.campId == this.campId &&
          other.campName == this.campName &&
          other.officerUid == this.officerUid &&
          other.officerName == this.officerName &&
          other.officerContact == this.officerContact &&
          other.foundLocation == this.foundLocation &&
          other.foundLatitude == this.foundLatitude &&
          other.foundLongitude == this.foundLongitude &&
          other.locationAccuracy == this.locationAccuracy &&
          other.additionalDetails == this.additionalDetails &&
          other.status == this.status &&
          other.foundAt == this.foundAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class CriticalRecordsCompanion extends UpdateCompanion<CriticalRecord> {
  final Value<String> id;
  final Value<String?> ownerUid;
  final Value<String> name;
  final Value<int> age;
  final Value<String?> photoUrl;
  final Value<String?> clothingPhotoUrl;
  final Value<String?> photoLocalPath;
  final Value<String?> clothingPhotoLocalPath;
  final Value<String> lastKnownClothing;
  final Value<String> campId;
  final Value<String> campName;
  final Value<String> officerUid;
  final Value<String> officerName;
  final Value<String> officerContact;
  final Value<String> foundLocation;
  final Value<double?> foundLatitude;
  final Value<double?> foundLongitude;
  final Value<double?> locationAccuracy;
  final Value<String> additionalDetails;
  final Value<String> status;
  final Value<DateTime> foundAt;
  final Value<DateTime?> createdAt;
  final Value<DateTime?> updatedAt;
  final Value<int> rowid;
  const CriticalRecordsCompanion({
    this.id = const Value.absent(),
    this.ownerUid = const Value.absent(),
    this.name = const Value.absent(),
    this.age = const Value.absent(),
    this.photoUrl = const Value.absent(),
    this.clothingPhotoUrl = const Value.absent(),
    this.photoLocalPath = const Value.absent(),
    this.clothingPhotoLocalPath = const Value.absent(),
    this.lastKnownClothing = const Value.absent(),
    this.campId = const Value.absent(),
    this.campName = const Value.absent(),
    this.officerUid = const Value.absent(),
    this.officerName = const Value.absent(),
    this.officerContact = const Value.absent(),
    this.foundLocation = const Value.absent(),
    this.foundLatitude = const Value.absent(),
    this.foundLongitude = const Value.absent(),
    this.locationAccuracy = const Value.absent(),
    this.additionalDetails = const Value.absent(),
    this.status = const Value.absent(),
    this.foundAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CriticalRecordsCompanion.insert({
    required String id,
    this.ownerUid = const Value.absent(),
    required String name,
    required int age,
    this.photoUrl = const Value.absent(),
    this.clothingPhotoUrl = const Value.absent(),
    this.photoLocalPath = const Value.absent(),
    this.clothingPhotoLocalPath = const Value.absent(),
    required String lastKnownClothing,
    required String campId,
    required String campName,
    required String officerUid,
    required String officerName,
    required String officerContact,
    required String foundLocation,
    this.foundLatitude = const Value.absent(),
    this.foundLongitude = const Value.absent(),
    this.locationAccuracy = const Value.absent(),
    required String additionalDetails,
    required String status,
    required DateTime foundAt,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       age = Value(age),
       lastKnownClothing = Value(lastKnownClothing),
       campId = Value(campId),
       campName = Value(campName),
       officerUid = Value(officerUid),
       officerName = Value(officerName),
       officerContact = Value(officerContact),
       foundLocation = Value(foundLocation),
       additionalDetails = Value(additionalDetails),
       status = Value(status),
       foundAt = Value(foundAt);
  static Insertable<CriticalRecord> custom({
    Expression<String>? id,
    Expression<String>? ownerUid,
    Expression<String>? name,
    Expression<int>? age,
    Expression<String>? photoUrl,
    Expression<String>? clothingPhotoUrl,
    Expression<String>? photoLocalPath,
    Expression<String>? clothingPhotoLocalPath,
    Expression<String>? lastKnownClothing,
    Expression<String>? campId,
    Expression<String>? campName,
    Expression<String>? officerUid,
    Expression<String>? officerName,
    Expression<String>? officerContact,
    Expression<String>? foundLocation,
    Expression<double>? foundLatitude,
    Expression<double>? foundLongitude,
    Expression<double>? locationAccuracy,
    Expression<String>? additionalDetails,
    Expression<String>? status,
    Expression<DateTime>? foundAt,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ownerUid != null) 'owner_uid': ownerUid,
      if (name != null) 'name': name,
      if (age != null) 'age': age,
      if (photoUrl != null) 'photo_url': photoUrl,
      if (clothingPhotoUrl != null) 'clothing_photo_url': clothingPhotoUrl,
      if (photoLocalPath != null) 'photo_local_path': photoLocalPath,
      if (clothingPhotoLocalPath != null)
        'clothing_photo_local_path': clothingPhotoLocalPath,
      if (lastKnownClothing != null) 'last_known_clothing': lastKnownClothing,
      if (campId != null) 'camp_id': campId,
      if (campName != null) 'camp_name': campName,
      if (officerUid != null) 'officer_uid': officerUid,
      if (officerName != null) 'officer_name': officerName,
      if (officerContact != null) 'officer_contact': officerContact,
      if (foundLocation != null) 'found_location': foundLocation,
      if (foundLatitude != null) 'found_latitude': foundLatitude,
      if (foundLongitude != null) 'found_longitude': foundLongitude,
      if (locationAccuracy != null) 'location_accuracy': locationAccuracy,
      if (additionalDetails != null) 'additional_details': additionalDetails,
      if (status != null) 'status': status,
      if (foundAt != null) 'found_at': foundAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CriticalRecordsCompanion copyWith({
    Value<String>? id,
    Value<String?>? ownerUid,
    Value<String>? name,
    Value<int>? age,
    Value<String?>? photoUrl,
    Value<String?>? clothingPhotoUrl,
    Value<String?>? photoLocalPath,
    Value<String?>? clothingPhotoLocalPath,
    Value<String>? lastKnownClothing,
    Value<String>? campId,
    Value<String>? campName,
    Value<String>? officerUid,
    Value<String>? officerName,
    Value<String>? officerContact,
    Value<String>? foundLocation,
    Value<double?>? foundLatitude,
    Value<double?>? foundLongitude,
    Value<double?>? locationAccuracy,
    Value<String>? additionalDetails,
    Value<String>? status,
    Value<DateTime>? foundAt,
    Value<DateTime?>? createdAt,
    Value<DateTime?>? updatedAt,
    Value<int>? rowid,
  }) {
    return CriticalRecordsCompanion(
      id: id ?? this.id,
      ownerUid: ownerUid ?? this.ownerUid,
      name: name ?? this.name,
      age: age ?? this.age,
      photoUrl: photoUrl ?? this.photoUrl,
      clothingPhotoUrl: clothingPhotoUrl ?? this.clothingPhotoUrl,
      photoLocalPath: photoLocalPath ?? this.photoLocalPath,
      clothingPhotoLocalPath:
          clothingPhotoLocalPath ?? this.clothingPhotoLocalPath,
      lastKnownClothing: lastKnownClothing ?? this.lastKnownClothing,
      campId: campId ?? this.campId,
      campName: campName ?? this.campName,
      officerUid: officerUid ?? this.officerUid,
      officerName: officerName ?? this.officerName,
      officerContact: officerContact ?? this.officerContact,
      foundLocation: foundLocation ?? this.foundLocation,
      foundLatitude: foundLatitude ?? this.foundLatitude,
      foundLongitude: foundLongitude ?? this.foundLongitude,
      locationAccuracy: locationAccuracy ?? this.locationAccuracy,
      additionalDetails: additionalDetails ?? this.additionalDetails,
      status: status ?? this.status,
      foundAt: foundAt ?? this.foundAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (ownerUid.present) {
      map['owner_uid'] = Variable<String>(ownerUid.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (age.present) {
      map['age'] = Variable<int>(age.value);
    }
    if (photoUrl.present) {
      map['photo_url'] = Variable<String>(photoUrl.value);
    }
    if (clothingPhotoUrl.present) {
      map['clothing_photo_url'] = Variable<String>(clothingPhotoUrl.value);
    }
    if (photoLocalPath.present) {
      map['photo_local_path'] = Variable<String>(photoLocalPath.value);
    }
    if (clothingPhotoLocalPath.present) {
      map['clothing_photo_local_path'] = Variable<String>(
        clothingPhotoLocalPath.value,
      );
    }
    if (lastKnownClothing.present) {
      map['last_known_clothing'] = Variable<String>(lastKnownClothing.value);
    }
    if (campId.present) {
      map['camp_id'] = Variable<String>(campId.value);
    }
    if (campName.present) {
      map['camp_name'] = Variable<String>(campName.value);
    }
    if (officerUid.present) {
      map['officer_uid'] = Variable<String>(officerUid.value);
    }
    if (officerName.present) {
      map['officer_name'] = Variable<String>(officerName.value);
    }
    if (officerContact.present) {
      map['officer_contact'] = Variable<String>(officerContact.value);
    }
    if (foundLocation.present) {
      map['found_location'] = Variable<String>(foundLocation.value);
    }
    if (foundLatitude.present) {
      map['found_latitude'] = Variable<double>(foundLatitude.value);
    }
    if (foundLongitude.present) {
      map['found_longitude'] = Variable<double>(foundLongitude.value);
    }
    if (locationAccuracy.present) {
      map['location_accuracy'] = Variable<double>(locationAccuracy.value);
    }
    if (additionalDetails.present) {
      map['additional_details'] = Variable<String>(additionalDetails.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (foundAt.present) {
      map['found_at'] = Variable<DateTime>(foundAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CriticalRecordsCompanion(')
          ..write('id: $id, ')
          ..write('ownerUid: $ownerUid, ')
          ..write('name: $name, ')
          ..write('age: $age, ')
          ..write('photoUrl: $photoUrl, ')
          ..write('clothingPhotoUrl: $clothingPhotoUrl, ')
          ..write('photoLocalPath: $photoLocalPath, ')
          ..write('clothingPhotoLocalPath: $clothingPhotoLocalPath, ')
          ..write('lastKnownClothing: $lastKnownClothing, ')
          ..write('campId: $campId, ')
          ..write('campName: $campName, ')
          ..write('officerUid: $officerUid, ')
          ..write('officerName: $officerName, ')
          ..write('officerContact: $officerContact, ')
          ..write('foundLocation: $foundLocation, ')
          ..write('foundLatitude: $foundLatitude, ')
          ..write('foundLongitude: $foundLongitude, ')
          ..write('locationAccuracy: $locationAccuracy, ')
          ..write('additionalDetails: $additionalDetails, ')
          ..write('status: $status, ')
          ..write('foundAt: $foundAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EmergencyAlertsTable extends EmergencyAlerts
    with TableInfo<$EmergencyAlertsTable, EmergencyAlert> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EmergencyAlertsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _messageMeta = const VerificationMeta(
    'message',
  );
  @override
  late final GeneratedColumn<String> message = GeneratedColumn<String>(
    'message',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _severityMeta = const VerificationMeta(
    'severity',
  );
  @override
  late final GeneratedColumn<String> severity = GeneratedColumn<String>(
    'severity',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _districtMeta = const VerificationMeta(
    'district',
  );
  @override
  late final GeneratedColumn<String> district = GeneratedColumn<String>(
    'district',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _stateMeta = const VerificationMeta('state');
  @override
  late final GeneratedColumn<String> state = GeneratedColumn<String>(
    'state',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _latitudeMeta = const VerificationMeta(
    'latitude',
  );
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
    'latitude',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _longitudeMeta = const VerificationMeta(
    'longitude',
  );
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
    'longitude',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _radiusKmMeta = const VerificationMeta(
    'radiusKm',
  );
  @override
  late final GeneratedColumn<double> radiusKm = GeneratedColumn<double>(
    'radius_km',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _activeMeta = const VerificationMeta('active');
  @override
  late final GeneratedColumn<bool> active = GeneratedColumn<bool>(
    'active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cachedAtMeta = const VerificationMeta(
    'cachedAt',
  );
  @override
  late final GeneratedColumn<DateTime> cachedAt = GeneratedColumn<DateTime>(
    'cached_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    message,
    type,
    severity,
    district,
    state,
    latitude,
    longitude,
    radiusKm,
    active,
    createdAt,
    cachedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'emergency_alerts';
  @override
  VerificationContext validateIntegrity(
    Insertable<EmergencyAlert> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('message')) {
      context.handle(
        _messageMeta,
        message.isAcceptableOrUnknown(data['message']!, _messageMeta),
      );
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('severity')) {
      context.handle(
        _severityMeta,
        severity.isAcceptableOrUnknown(data['severity']!, _severityMeta),
      );
    } else if (isInserting) {
      context.missing(_severityMeta);
    }
    if (data.containsKey('district')) {
      context.handle(
        _districtMeta,
        district.isAcceptableOrUnknown(data['district']!, _districtMeta),
      );
    }
    if (data.containsKey('state')) {
      context.handle(
        _stateMeta,
        state.isAcceptableOrUnknown(data['state']!, _stateMeta),
      );
    }
    if (data.containsKey('latitude')) {
      context.handle(
        _latitudeMeta,
        latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta),
      );
    }
    if (data.containsKey('longitude')) {
      context.handle(
        _longitudeMeta,
        longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta),
      );
    }
    if (data.containsKey('radius_km')) {
      context.handle(
        _radiusKmMeta,
        radiusKm.isAcceptableOrUnknown(data['radius_km']!, _radiusKmMeta),
      );
    }
    if (data.containsKey('active')) {
      context.handle(
        _activeMeta,
        active.isAcceptableOrUnknown(data['active']!, _activeMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('cached_at')) {
      context.handle(
        _cachedAtMeta,
        cachedAt.isAcceptableOrUnknown(data['cached_at']!, _cachedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_cachedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  EmergencyAlert map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EmergencyAlert(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      message: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}message'],
      ),
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      severity: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}severity'],
      )!,
      district: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}district'],
      ),
      state: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}state'],
      ),
      latitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}latitude'],
      ),
      longitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}longitude'],
      ),
      radiusKm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}radius_km'],
      ),
      active: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}active'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      cachedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}cached_at'],
      )!,
    );
  }

  @override
  $EmergencyAlertsTable createAlias(String alias) {
    return $EmergencyAlertsTable(attachedDatabase, alias);
  }
}

class EmergencyAlert extends DataClass implements Insertable<EmergencyAlert> {
  final String id;
  final String title;
  final String? message;
  final String type;
  final String severity;
  final String? district;
  final String? state;
  final double? latitude;
  final double? longitude;
  final double? radiusKm;
  final bool active;
  final DateTime createdAt;
  final DateTime cachedAt;
  const EmergencyAlert({
    required this.id,
    required this.title,
    this.message,
    required this.type,
    required this.severity,
    this.district,
    this.state,
    this.latitude,
    this.longitude,
    this.radiusKm,
    required this.active,
    required this.createdAt,
    required this.cachedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || message != null) {
      map['message'] = Variable<String>(message);
    }
    map['type'] = Variable<String>(type);
    map['severity'] = Variable<String>(severity);
    if (!nullToAbsent || district != null) {
      map['district'] = Variable<String>(district);
    }
    if (!nullToAbsent || state != null) {
      map['state'] = Variable<String>(state);
    }
    if (!nullToAbsent || latitude != null) {
      map['latitude'] = Variable<double>(latitude);
    }
    if (!nullToAbsent || longitude != null) {
      map['longitude'] = Variable<double>(longitude);
    }
    if (!nullToAbsent || radiusKm != null) {
      map['radius_km'] = Variable<double>(radiusKm);
    }
    map['active'] = Variable<bool>(active);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['cached_at'] = Variable<DateTime>(cachedAt);
    return map;
  }

  EmergencyAlertsCompanion toCompanion(bool nullToAbsent) {
    return EmergencyAlertsCompanion(
      id: Value(id),
      title: Value(title),
      message: message == null && nullToAbsent
          ? const Value.absent()
          : Value(message),
      type: Value(type),
      severity: Value(severity),
      district: district == null && nullToAbsent
          ? const Value.absent()
          : Value(district),
      state: state == null && nullToAbsent
          ? const Value.absent()
          : Value(state),
      latitude: latitude == null && nullToAbsent
          ? const Value.absent()
          : Value(latitude),
      longitude: longitude == null && nullToAbsent
          ? const Value.absent()
          : Value(longitude),
      radiusKm: radiusKm == null && nullToAbsent
          ? const Value.absent()
          : Value(radiusKm),
      active: Value(active),
      createdAt: Value(createdAt),
      cachedAt: Value(cachedAt),
    );
  }

  factory EmergencyAlert.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EmergencyAlert(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      message: serializer.fromJson<String?>(json['message']),
      type: serializer.fromJson<String>(json['type']),
      severity: serializer.fromJson<String>(json['severity']),
      district: serializer.fromJson<String?>(json['district']),
      state: serializer.fromJson<String?>(json['state']),
      latitude: serializer.fromJson<double?>(json['latitude']),
      longitude: serializer.fromJson<double?>(json['longitude']),
      radiusKm: serializer.fromJson<double?>(json['radiusKm']),
      active: serializer.fromJson<bool>(json['active']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      cachedAt: serializer.fromJson<DateTime>(json['cachedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'message': serializer.toJson<String?>(message),
      'type': serializer.toJson<String>(type),
      'severity': serializer.toJson<String>(severity),
      'district': serializer.toJson<String?>(district),
      'state': serializer.toJson<String?>(state),
      'latitude': serializer.toJson<double?>(latitude),
      'longitude': serializer.toJson<double?>(longitude),
      'radiusKm': serializer.toJson<double?>(radiusKm),
      'active': serializer.toJson<bool>(active),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'cachedAt': serializer.toJson<DateTime>(cachedAt),
    };
  }

  EmergencyAlert copyWith({
    String? id,
    String? title,
    Value<String?> message = const Value.absent(),
    String? type,
    String? severity,
    Value<String?> district = const Value.absent(),
    Value<String?> state = const Value.absent(),
    Value<double?> latitude = const Value.absent(),
    Value<double?> longitude = const Value.absent(),
    Value<double?> radiusKm = const Value.absent(),
    bool? active,
    DateTime? createdAt,
    DateTime? cachedAt,
  }) => EmergencyAlert(
    id: id ?? this.id,
    title: title ?? this.title,
    message: message.present ? message.value : this.message,
    type: type ?? this.type,
    severity: severity ?? this.severity,
    district: district.present ? district.value : this.district,
    state: state.present ? state.value : this.state,
    latitude: latitude.present ? latitude.value : this.latitude,
    longitude: longitude.present ? longitude.value : this.longitude,
    radiusKm: radiusKm.present ? radiusKm.value : this.radiusKm,
    active: active ?? this.active,
    createdAt: createdAt ?? this.createdAt,
    cachedAt: cachedAt ?? this.cachedAt,
  );
  EmergencyAlert copyWithCompanion(EmergencyAlertsCompanion data) {
    return EmergencyAlert(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      message: data.message.present ? data.message.value : this.message,
      type: data.type.present ? data.type.value : this.type,
      severity: data.severity.present ? data.severity.value : this.severity,
      district: data.district.present ? data.district.value : this.district,
      state: data.state.present ? data.state.value : this.state,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      radiusKm: data.radiusKm.present ? data.radiusKm.value : this.radiusKm,
      active: data.active.present ? data.active.value : this.active,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      cachedAt: data.cachedAt.present ? data.cachedAt.value : this.cachedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EmergencyAlert(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('message: $message, ')
          ..write('type: $type, ')
          ..write('severity: $severity, ')
          ..write('district: $district, ')
          ..write('state: $state, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('radiusKm: $radiusKm, ')
          ..write('active: $active, ')
          ..write('createdAt: $createdAt, ')
          ..write('cachedAt: $cachedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    message,
    type,
    severity,
    district,
    state,
    latitude,
    longitude,
    radiusKm,
    active,
    createdAt,
    cachedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EmergencyAlert &&
          other.id == this.id &&
          other.title == this.title &&
          other.message == this.message &&
          other.type == this.type &&
          other.severity == this.severity &&
          other.district == this.district &&
          other.state == this.state &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.radiusKm == this.radiusKm &&
          other.active == this.active &&
          other.createdAt == this.createdAt &&
          other.cachedAt == this.cachedAt);
}

class EmergencyAlertsCompanion extends UpdateCompanion<EmergencyAlert> {
  final Value<String> id;
  final Value<String> title;
  final Value<String?> message;
  final Value<String> type;
  final Value<String> severity;
  final Value<String?> district;
  final Value<String?> state;
  final Value<double?> latitude;
  final Value<double?> longitude;
  final Value<double?> radiusKm;
  final Value<bool> active;
  final Value<DateTime> createdAt;
  final Value<DateTime> cachedAt;
  final Value<int> rowid;
  const EmergencyAlertsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.message = const Value.absent(),
    this.type = const Value.absent(),
    this.severity = const Value.absent(),
    this.district = const Value.absent(),
    this.state = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.radiusKm = const Value.absent(),
    this.active = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.cachedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EmergencyAlertsCompanion.insert({
    required String id,
    required String title,
    this.message = const Value.absent(),
    required String type,
    required String severity,
    this.district = const Value.absent(),
    this.state = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.radiusKm = const Value.absent(),
    this.active = const Value.absent(),
    required DateTime createdAt,
    required DateTime cachedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       type = Value(type),
       severity = Value(severity),
       createdAt = Value(createdAt),
       cachedAt = Value(cachedAt);
  static Insertable<EmergencyAlert> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? message,
    Expression<String>? type,
    Expression<String>? severity,
    Expression<String>? district,
    Expression<String>? state,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<double>? radiusKm,
    Expression<bool>? active,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? cachedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (message != null) 'message': message,
      if (type != null) 'type': type,
      if (severity != null) 'severity': severity,
      if (district != null) 'district': district,
      if (state != null) 'state': state,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (radiusKm != null) 'radius_km': radiusKm,
      if (active != null) 'active': active,
      if (createdAt != null) 'created_at': createdAt,
      if (cachedAt != null) 'cached_at': cachedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EmergencyAlertsCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<String?>? message,
    Value<String>? type,
    Value<String>? severity,
    Value<String?>? district,
    Value<String?>? state,
    Value<double?>? latitude,
    Value<double?>? longitude,
    Value<double?>? radiusKm,
    Value<bool>? active,
    Value<DateTime>? createdAt,
    Value<DateTime>? cachedAt,
    Value<int>? rowid,
  }) {
    return EmergencyAlertsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      severity: severity ?? this.severity,
      district: district ?? this.district,
      state: state ?? this.state,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      radiusKm: radiusKm ?? this.radiusKm,
      active: active ?? this.active,
      createdAt: createdAt ?? this.createdAt,
      cachedAt: cachedAt ?? this.cachedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (message.present) {
      map['message'] = Variable<String>(message.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (severity.present) {
      map['severity'] = Variable<String>(severity.value);
    }
    if (district.present) {
      map['district'] = Variable<String>(district.value);
    }
    if (state.present) {
      map['state'] = Variable<String>(state.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (radiusKm.present) {
      map['radius_km'] = Variable<double>(radiusKm.value);
    }
    if (active.present) {
      map['active'] = Variable<bool>(active.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (cachedAt.present) {
      map['cached_at'] = Variable<DateTime>(cachedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EmergencyAlertsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('message: $message, ')
          ..write('type: $type, ')
          ..write('severity: $severity, ')
          ..write('district: $district, ')
          ..write('state: $state, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('radiusKm: $radiusKm, ')
          ..write('active: $active, ')
          ..write('createdAt: $createdAt, ')
          ..write('cachedAt: $cachedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncQueueTable extends SyncQueue
    with TableInfo<$SyncQueueTable, SyncQueueData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncQueueTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _ownerUidMeta = const VerificationMeta(
    'ownerUid',
  );
  @override
  late final GeneratedColumn<String> ownerUid = GeneratedColumn<String>(
    'owner_uid',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _entityTypeMeta = const VerificationMeta(
    'entityType',
  );
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
    'entity_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _operationTypeMeta = const VerificationMeta(
    'operationType',
  );
  @override
  late final GeneratedColumn<String> operationType = GeneratedColumn<String>(
    'operation_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _retryCountMeta = const VerificationMeta(
    'retryCount',
  );
  @override
  late final GeneratedColumn<int> retryCount = GeneratedColumn<int>(
    'retry_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastAttemptAtMeta = const VerificationMeta(
    'lastAttemptAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastAttemptAt =
      GeneratedColumn<DateTime>(
        'last_attempt_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    ownerUid,
    entityType,
    entityId,
    operationType,
    payload,
    createdAt,
    retryCount,
    lastAttemptAt,
    syncStatus,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_queue';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncQueueData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('owner_uid')) {
      context.handle(
        _ownerUidMeta,
        ownerUid.isAcceptableOrUnknown(data['owner_uid']!, _ownerUidMeta),
      );
    }
    if (data.containsKey('entity_type')) {
      context.handle(
        _entityTypeMeta,
        entityType.isAcceptableOrUnknown(data['entity_type']!, _entityTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('operation_type')) {
      context.handle(
        _operationTypeMeta,
        operationType.isAcceptableOrUnknown(
          data['operation_type']!,
          _operationTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_operationTypeMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('retry_count')) {
      context.handle(
        _retryCountMeta,
        retryCount.isAcceptableOrUnknown(data['retry_count']!, _retryCountMeta),
      );
    }
    if (data.containsKey('last_attempt_at')) {
      context.handle(
        _lastAttemptAtMeta,
        lastAttemptAt.isAcceptableOrUnknown(
          data['last_attempt_at']!,
          _lastAttemptAtMeta,
        ),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    } else if (isInserting) {
      context.missing(_syncStatusMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncQueueData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncQueueData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      ownerUid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_uid'],
      ),
      entityType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_type'],
      )!,
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      )!,
      operationType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}operation_type'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      retryCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}retry_count'],
      )!,
      lastAttemptAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_attempt_at'],
      ),
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
    );
  }

  @override
  $SyncQueueTable createAlias(String alias) {
    return $SyncQueueTable(attachedDatabase, alias);
  }
}

class SyncQueueData extends DataClass implements Insertable<SyncQueueData> {
  final int id;
  final String? ownerUid;
  final String entityType;
  final String entityId;
  final String operationType;
  final String payload;
  final DateTime createdAt;
  final int retryCount;
  final DateTime? lastAttemptAt;
  final String syncStatus;
  const SyncQueueData({
    required this.id,
    this.ownerUid,
    required this.entityType,
    required this.entityId,
    required this.operationType,
    required this.payload,
    required this.createdAt,
    required this.retryCount,
    this.lastAttemptAt,
    required this.syncStatus,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || ownerUid != null) {
      map['owner_uid'] = Variable<String>(ownerUid);
    }
    map['entity_type'] = Variable<String>(entityType);
    map['entity_id'] = Variable<String>(entityId);
    map['operation_type'] = Variable<String>(operationType);
    map['payload'] = Variable<String>(payload);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['retry_count'] = Variable<int>(retryCount);
    if (!nullToAbsent || lastAttemptAt != null) {
      map['last_attempt_at'] = Variable<DateTime>(lastAttemptAt);
    }
    map['sync_status'] = Variable<String>(syncStatus);
    return map;
  }

  SyncQueueCompanion toCompanion(bool nullToAbsent) {
    return SyncQueueCompanion(
      id: Value(id),
      ownerUid: ownerUid == null && nullToAbsent
          ? const Value.absent()
          : Value(ownerUid),
      entityType: Value(entityType),
      entityId: Value(entityId),
      operationType: Value(operationType),
      payload: Value(payload),
      createdAt: Value(createdAt),
      retryCount: Value(retryCount),
      lastAttemptAt: lastAttemptAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastAttemptAt),
      syncStatus: Value(syncStatus),
    );
  }

  factory SyncQueueData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncQueueData(
      id: serializer.fromJson<int>(json['id']),
      ownerUid: serializer.fromJson<String?>(json['ownerUid']),
      entityType: serializer.fromJson<String>(json['entityType']),
      entityId: serializer.fromJson<String>(json['entityId']),
      operationType: serializer.fromJson<String>(json['operationType']),
      payload: serializer.fromJson<String>(json['payload']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      retryCount: serializer.fromJson<int>(json['retryCount']),
      lastAttemptAt: serializer.fromJson<DateTime?>(json['lastAttemptAt']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'ownerUid': serializer.toJson<String?>(ownerUid),
      'entityType': serializer.toJson<String>(entityType),
      'entityId': serializer.toJson<String>(entityId),
      'operationType': serializer.toJson<String>(operationType),
      'payload': serializer.toJson<String>(payload),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'retryCount': serializer.toJson<int>(retryCount),
      'lastAttemptAt': serializer.toJson<DateTime?>(lastAttemptAt),
      'syncStatus': serializer.toJson<String>(syncStatus),
    };
  }

  SyncQueueData copyWith({
    int? id,
    Value<String?> ownerUid = const Value.absent(),
    String? entityType,
    String? entityId,
    String? operationType,
    String? payload,
    DateTime? createdAt,
    int? retryCount,
    Value<DateTime?> lastAttemptAt = const Value.absent(),
    String? syncStatus,
  }) => SyncQueueData(
    id: id ?? this.id,
    ownerUid: ownerUid.present ? ownerUid.value : this.ownerUid,
    entityType: entityType ?? this.entityType,
    entityId: entityId ?? this.entityId,
    operationType: operationType ?? this.operationType,
    payload: payload ?? this.payload,
    createdAt: createdAt ?? this.createdAt,
    retryCount: retryCount ?? this.retryCount,
    lastAttemptAt: lastAttemptAt.present
        ? lastAttemptAt.value
        : this.lastAttemptAt,
    syncStatus: syncStatus ?? this.syncStatus,
  );
  SyncQueueData copyWithCompanion(SyncQueueCompanion data) {
    return SyncQueueData(
      id: data.id.present ? data.id.value : this.id,
      ownerUid: data.ownerUid.present ? data.ownerUid.value : this.ownerUid,
      entityType: data.entityType.present
          ? data.entityType.value
          : this.entityType,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      operationType: data.operationType.present
          ? data.operationType.value
          : this.operationType,
      payload: data.payload.present ? data.payload.value : this.payload,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      retryCount: data.retryCount.present
          ? data.retryCount.value
          : this.retryCount,
      lastAttemptAt: data.lastAttemptAt.present
          ? data.lastAttemptAt.value
          : this.lastAttemptAt,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueData(')
          ..write('id: $id, ')
          ..write('ownerUid: $ownerUid, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('operationType: $operationType, ')
          ..write('payload: $payload, ')
          ..write('createdAt: $createdAt, ')
          ..write('retryCount: $retryCount, ')
          ..write('lastAttemptAt: $lastAttemptAt, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    ownerUid,
    entityType,
    entityId,
    operationType,
    payload,
    createdAt,
    retryCount,
    lastAttemptAt,
    syncStatus,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncQueueData &&
          other.id == this.id &&
          other.ownerUid == this.ownerUid &&
          other.entityType == this.entityType &&
          other.entityId == this.entityId &&
          other.operationType == this.operationType &&
          other.payload == this.payload &&
          other.createdAt == this.createdAt &&
          other.retryCount == this.retryCount &&
          other.lastAttemptAt == this.lastAttemptAt &&
          other.syncStatus == this.syncStatus);
}

class SyncQueueCompanion extends UpdateCompanion<SyncQueueData> {
  final Value<int> id;
  final Value<String?> ownerUid;
  final Value<String> entityType;
  final Value<String> entityId;
  final Value<String> operationType;
  final Value<String> payload;
  final Value<DateTime> createdAt;
  final Value<int> retryCount;
  final Value<DateTime?> lastAttemptAt;
  final Value<String> syncStatus;
  const SyncQueueCompanion({
    this.id = const Value.absent(),
    this.ownerUid = const Value.absent(),
    this.entityType = const Value.absent(),
    this.entityId = const Value.absent(),
    this.operationType = const Value.absent(),
    this.payload = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.lastAttemptAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
  });
  SyncQueueCompanion.insert({
    this.id = const Value.absent(),
    this.ownerUid = const Value.absent(),
    required String entityType,
    required String entityId,
    required String operationType,
    required String payload,
    required DateTime createdAt,
    this.retryCount = const Value.absent(),
    this.lastAttemptAt = const Value.absent(),
    required String syncStatus,
  }) : entityType = Value(entityType),
       entityId = Value(entityId),
       operationType = Value(operationType),
       payload = Value(payload),
       createdAt = Value(createdAt),
       syncStatus = Value(syncStatus);
  static Insertable<SyncQueueData> custom({
    Expression<int>? id,
    Expression<String>? ownerUid,
    Expression<String>? entityType,
    Expression<String>? entityId,
    Expression<String>? operationType,
    Expression<String>? payload,
    Expression<DateTime>? createdAt,
    Expression<int>? retryCount,
    Expression<DateTime>? lastAttemptAt,
    Expression<String>? syncStatus,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ownerUid != null) 'owner_uid': ownerUid,
      if (entityType != null) 'entity_type': entityType,
      if (entityId != null) 'entity_id': entityId,
      if (operationType != null) 'operation_type': operationType,
      if (payload != null) 'payload': payload,
      if (createdAt != null) 'created_at': createdAt,
      if (retryCount != null) 'retry_count': retryCount,
      if (lastAttemptAt != null) 'last_attempt_at': lastAttemptAt,
      if (syncStatus != null) 'sync_status': syncStatus,
    });
  }

  SyncQueueCompanion copyWith({
    Value<int>? id,
    Value<String?>? ownerUid,
    Value<String>? entityType,
    Value<String>? entityId,
    Value<String>? operationType,
    Value<String>? payload,
    Value<DateTime>? createdAt,
    Value<int>? retryCount,
    Value<DateTime?>? lastAttemptAt,
    Value<String>? syncStatus,
  }) {
    return SyncQueueCompanion(
      id: id ?? this.id,
      ownerUid: ownerUid ?? this.ownerUid,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      operationType: operationType ?? this.operationType,
      payload: payload ?? this.payload,
      createdAt: createdAt ?? this.createdAt,
      retryCount: retryCount ?? this.retryCount,
      lastAttemptAt: lastAttemptAt ?? this.lastAttemptAt,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (ownerUid.present) {
      map['owner_uid'] = Variable<String>(ownerUid.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (operationType.present) {
      map['operation_type'] = Variable<String>(operationType.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (retryCount.present) {
      map['retry_count'] = Variable<int>(retryCount.value);
    }
    if (lastAttemptAt.present) {
      map['last_attempt_at'] = Variable<DateTime>(lastAttemptAt.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueCompanion(')
          ..write('id: $id, ')
          ..write('ownerUid: $ownerUid, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('operationType: $operationType, ')
          ..write('payload: $payload, ')
          ..write('createdAt: $createdAt, ')
          ..write('retryCount: $retryCount, ')
          ..write('lastAttemptAt: $lastAttemptAt, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CampsTable camps = $CampsTable(this);
  late final $NormalRecordsTable normalRecords = $NormalRecordsTable(this);
  late final $CriticalRecordsTable criticalRecords = $CriticalRecordsTable(
    this,
  );
  late final $EmergencyAlertsTable emergencyAlerts = $EmergencyAlertsTable(
    this,
  );
  late final $SyncQueueTable syncQueue = $SyncQueueTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    camps,
    normalRecords,
    criticalRecords,
    emergencyAlerts,
    syncQueue,
  ];
}

typedef $$CampsTableCreateCompanionBuilder =
    CampsCompanion Function({
      required String id,
      Value<String?> ownerUid,
      required String name,
      required String locationName,
      required String address,
      Value<double?> latitude,
      Value<double?> longitude,
      Value<double?> locationAccuracy,
      required String contactNumber,
      required String officerName,
      required String officerUid,
      Value<bool> active,
      Value<DateTime?> createdAt,
      Value<DateTime?> updatedAt,
      Value<int> rowid,
    });
typedef $$CampsTableUpdateCompanionBuilder =
    CampsCompanion Function({
      Value<String> id,
      Value<String?> ownerUid,
      Value<String> name,
      Value<String> locationName,
      Value<String> address,
      Value<double?> latitude,
      Value<double?> longitude,
      Value<double?> locationAccuracy,
      Value<String> contactNumber,
      Value<String> officerName,
      Value<String> officerUid,
      Value<bool> active,
      Value<DateTime?> createdAt,
      Value<DateTime?> updatedAt,
      Value<int> rowid,
    });

class $$CampsTableFilterComposer extends Composer<_$AppDatabase, $CampsTable> {
  $$CampsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerUid => $composableBuilder(
    column: $table.ownerUid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get locationName => $composableBuilder(
    column: $table.locationName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get locationAccuracy => $composableBuilder(
    column: $table.locationAccuracy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contactNumber => $composableBuilder(
    column: $table.contactNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get officerName => $composableBuilder(
    column: $table.officerName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get officerUid => $composableBuilder(
    column: $table.officerUid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get active => $composableBuilder(
    column: $table.active,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CampsTableOrderingComposer
    extends Composer<_$AppDatabase, $CampsTable> {
  $$CampsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerUid => $composableBuilder(
    column: $table.ownerUid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get locationName => $composableBuilder(
    column: $table.locationName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get locationAccuracy => $composableBuilder(
    column: $table.locationAccuracy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contactNumber => $composableBuilder(
    column: $table.contactNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get officerName => $composableBuilder(
    column: $table.officerName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get officerUid => $composableBuilder(
    column: $table.officerUid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get active => $composableBuilder(
    column: $table.active,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CampsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CampsTable> {
  $$CampsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get ownerUid =>
      $composableBuilder(column: $table.ownerUid, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get locationName => $composableBuilder(
    column: $table.locationName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<double> get locationAccuracy => $composableBuilder(
    column: $table.locationAccuracy,
    builder: (column) => column,
  );

  GeneratedColumn<String> get contactNumber => $composableBuilder(
    column: $table.contactNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get officerName => $composableBuilder(
    column: $table.officerName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get officerUid => $composableBuilder(
    column: $table.officerUid,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get active =>
      $composableBuilder(column: $table.active, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$CampsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CampsTable,
          Camp,
          $$CampsTableFilterComposer,
          $$CampsTableOrderingComposer,
          $$CampsTableAnnotationComposer,
          $$CampsTableCreateCompanionBuilder,
          $$CampsTableUpdateCompanionBuilder,
          (Camp, BaseReferences<_$AppDatabase, $CampsTable, Camp>),
          Camp,
          PrefetchHooks Function()
        > {
  $$CampsTableTableManager(_$AppDatabase db, $CampsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CampsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CampsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CampsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> ownerUid = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> locationName = const Value.absent(),
                Value<String> address = const Value.absent(),
                Value<double?> latitude = const Value.absent(),
                Value<double?> longitude = const Value.absent(),
                Value<double?> locationAccuracy = const Value.absent(),
                Value<String> contactNumber = const Value.absent(),
                Value<String> officerName = const Value.absent(),
                Value<String> officerUid = const Value.absent(),
                Value<bool> active = const Value.absent(),
                Value<DateTime?> createdAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CampsCompanion(
                id: id,
                ownerUid: ownerUid,
                name: name,
                locationName: locationName,
                address: address,
                latitude: latitude,
                longitude: longitude,
                locationAccuracy: locationAccuracy,
                contactNumber: contactNumber,
                officerName: officerName,
                officerUid: officerUid,
                active: active,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> ownerUid = const Value.absent(),
                required String name,
                required String locationName,
                required String address,
                Value<double?> latitude = const Value.absent(),
                Value<double?> longitude = const Value.absent(),
                Value<double?> locationAccuracy = const Value.absent(),
                required String contactNumber,
                required String officerName,
                required String officerUid,
                Value<bool> active = const Value.absent(),
                Value<DateTime?> createdAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CampsCompanion.insert(
                id: id,
                ownerUid: ownerUid,
                name: name,
                locationName: locationName,
                address: address,
                latitude: latitude,
                longitude: longitude,
                locationAccuracy: locationAccuracy,
                contactNumber: contactNumber,
                officerName: officerName,
                officerUid: officerUid,
                active: active,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CampsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CampsTable,
      Camp,
      $$CampsTableFilterComposer,
      $$CampsTableOrderingComposer,
      $$CampsTableAnnotationComposer,
      $$CampsTableCreateCompanionBuilder,
      $$CampsTableUpdateCompanionBuilder,
      (Camp, BaseReferences<_$AppDatabase, $CampsTable, Camp>),
      Camp,
      PrefetchHooks Function()
    >;
typedef $$NormalRecordsTableCreateCompanionBuilder =
    NormalRecordsCompanion Function({
      required String id,
      Value<String?> ownerUid,
      required String name,
      required int age,
      Value<String?> photoUrl,
      Value<String?> photoLocalPath,
      required String campId,
      required String campName,
      required String officerUid,
      required String officerName,
      required String officerContact,
      required String status,
      required String additionalDetails,
      required DateTime foundAt,
      Value<DateTime?> createdAt,
      Value<DateTime?> updatedAt,
      Value<int> rowid,
    });
typedef $$NormalRecordsTableUpdateCompanionBuilder =
    NormalRecordsCompanion Function({
      Value<String> id,
      Value<String?> ownerUid,
      Value<String> name,
      Value<int> age,
      Value<String?> photoUrl,
      Value<String?> photoLocalPath,
      Value<String> campId,
      Value<String> campName,
      Value<String> officerUid,
      Value<String> officerName,
      Value<String> officerContact,
      Value<String> status,
      Value<String> additionalDetails,
      Value<DateTime> foundAt,
      Value<DateTime?> createdAt,
      Value<DateTime?> updatedAt,
      Value<int> rowid,
    });

class $$NormalRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $NormalRecordsTable> {
  $$NormalRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerUid => $composableBuilder(
    column: $table.ownerUid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get age => $composableBuilder(
    column: $table.age,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get photoUrl => $composableBuilder(
    column: $table.photoUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get photoLocalPath => $composableBuilder(
    column: $table.photoLocalPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get campId => $composableBuilder(
    column: $table.campId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get campName => $composableBuilder(
    column: $table.campName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get officerUid => $composableBuilder(
    column: $table.officerUid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get officerName => $composableBuilder(
    column: $table.officerName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get officerContact => $composableBuilder(
    column: $table.officerContact,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get additionalDetails => $composableBuilder(
    column: $table.additionalDetails,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get foundAt => $composableBuilder(
    column: $table.foundAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$NormalRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $NormalRecordsTable> {
  $$NormalRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerUid => $composableBuilder(
    column: $table.ownerUid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get age => $composableBuilder(
    column: $table.age,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get photoUrl => $composableBuilder(
    column: $table.photoUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get photoLocalPath => $composableBuilder(
    column: $table.photoLocalPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get campId => $composableBuilder(
    column: $table.campId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get campName => $composableBuilder(
    column: $table.campName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get officerUid => $composableBuilder(
    column: $table.officerUid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get officerName => $composableBuilder(
    column: $table.officerName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get officerContact => $composableBuilder(
    column: $table.officerContact,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get additionalDetails => $composableBuilder(
    column: $table.additionalDetails,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get foundAt => $composableBuilder(
    column: $table.foundAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$NormalRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $NormalRecordsTable> {
  $$NormalRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get ownerUid =>
      $composableBuilder(column: $table.ownerUid, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get age =>
      $composableBuilder(column: $table.age, builder: (column) => column);

  GeneratedColumn<String> get photoUrl =>
      $composableBuilder(column: $table.photoUrl, builder: (column) => column);

  GeneratedColumn<String> get photoLocalPath => $composableBuilder(
    column: $table.photoLocalPath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get campId =>
      $composableBuilder(column: $table.campId, builder: (column) => column);

  GeneratedColumn<String> get campName =>
      $composableBuilder(column: $table.campName, builder: (column) => column);

  GeneratedColumn<String> get officerUid => $composableBuilder(
    column: $table.officerUid,
    builder: (column) => column,
  );

  GeneratedColumn<String> get officerName => $composableBuilder(
    column: $table.officerName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get officerContact => $composableBuilder(
    column: $table.officerContact,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get additionalDetails => $composableBuilder(
    column: $table.additionalDetails,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get foundAt =>
      $composableBuilder(column: $table.foundAt, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$NormalRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $NormalRecordsTable,
          NormalRecord,
          $$NormalRecordsTableFilterComposer,
          $$NormalRecordsTableOrderingComposer,
          $$NormalRecordsTableAnnotationComposer,
          $$NormalRecordsTableCreateCompanionBuilder,
          $$NormalRecordsTableUpdateCompanionBuilder,
          (
            NormalRecord,
            BaseReferences<_$AppDatabase, $NormalRecordsTable, NormalRecord>,
          ),
          NormalRecord,
          PrefetchHooks Function()
        > {
  $$NormalRecordsTableTableManager(_$AppDatabase db, $NormalRecordsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NormalRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NormalRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$NormalRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> ownerUid = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> age = const Value.absent(),
                Value<String?> photoUrl = const Value.absent(),
                Value<String?> photoLocalPath = const Value.absent(),
                Value<String> campId = const Value.absent(),
                Value<String> campName = const Value.absent(),
                Value<String> officerUid = const Value.absent(),
                Value<String> officerName = const Value.absent(),
                Value<String> officerContact = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> additionalDetails = const Value.absent(),
                Value<DateTime> foundAt = const Value.absent(),
                Value<DateTime?> createdAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => NormalRecordsCompanion(
                id: id,
                ownerUid: ownerUid,
                name: name,
                age: age,
                photoUrl: photoUrl,
                photoLocalPath: photoLocalPath,
                campId: campId,
                campName: campName,
                officerUid: officerUid,
                officerName: officerName,
                officerContact: officerContact,
                status: status,
                additionalDetails: additionalDetails,
                foundAt: foundAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> ownerUid = const Value.absent(),
                required String name,
                required int age,
                Value<String?> photoUrl = const Value.absent(),
                Value<String?> photoLocalPath = const Value.absent(),
                required String campId,
                required String campName,
                required String officerUid,
                required String officerName,
                required String officerContact,
                required String status,
                required String additionalDetails,
                required DateTime foundAt,
                Value<DateTime?> createdAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => NormalRecordsCompanion.insert(
                id: id,
                ownerUid: ownerUid,
                name: name,
                age: age,
                photoUrl: photoUrl,
                photoLocalPath: photoLocalPath,
                campId: campId,
                campName: campName,
                officerUid: officerUid,
                officerName: officerName,
                officerContact: officerContact,
                status: status,
                additionalDetails: additionalDetails,
                foundAt: foundAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$NormalRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $NormalRecordsTable,
      NormalRecord,
      $$NormalRecordsTableFilterComposer,
      $$NormalRecordsTableOrderingComposer,
      $$NormalRecordsTableAnnotationComposer,
      $$NormalRecordsTableCreateCompanionBuilder,
      $$NormalRecordsTableUpdateCompanionBuilder,
      (
        NormalRecord,
        BaseReferences<_$AppDatabase, $NormalRecordsTable, NormalRecord>,
      ),
      NormalRecord,
      PrefetchHooks Function()
    >;
typedef $$CriticalRecordsTableCreateCompanionBuilder =
    CriticalRecordsCompanion Function({
      required String id,
      Value<String?> ownerUid,
      required String name,
      required int age,
      Value<String?> photoUrl,
      Value<String?> clothingPhotoUrl,
      Value<String?> photoLocalPath,
      Value<String?> clothingPhotoLocalPath,
      required String lastKnownClothing,
      required String campId,
      required String campName,
      required String officerUid,
      required String officerName,
      required String officerContact,
      required String foundLocation,
      Value<double?> foundLatitude,
      Value<double?> foundLongitude,
      Value<double?> locationAccuracy,
      required String additionalDetails,
      required String status,
      required DateTime foundAt,
      Value<DateTime?> createdAt,
      Value<DateTime?> updatedAt,
      Value<int> rowid,
    });
typedef $$CriticalRecordsTableUpdateCompanionBuilder =
    CriticalRecordsCompanion Function({
      Value<String> id,
      Value<String?> ownerUid,
      Value<String> name,
      Value<int> age,
      Value<String?> photoUrl,
      Value<String?> clothingPhotoUrl,
      Value<String?> photoLocalPath,
      Value<String?> clothingPhotoLocalPath,
      Value<String> lastKnownClothing,
      Value<String> campId,
      Value<String> campName,
      Value<String> officerUid,
      Value<String> officerName,
      Value<String> officerContact,
      Value<String> foundLocation,
      Value<double?> foundLatitude,
      Value<double?> foundLongitude,
      Value<double?> locationAccuracy,
      Value<String> additionalDetails,
      Value<String> status,
      Value<DateTime> foundAt,
      Value<DateTime?> createdAt,
      Value<DateTime?> updatedAt,
      Value<int> rowid,
    });

class $$CriticalRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $CriticalRecordsTable> {
  $$CriticalRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerUid => $composableBuilder(
    column: $table.ownerUid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get age => $composableBuilder(
    column: $table.age,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get photoUrl => $composableBuilder(
    column: $table.photoUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get clothingPhotoUrl => $composableBuilder(
    column: $table.clothingPhotoUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get photoLocalPath => $composableBuilder(
    column: $table.photoLocalPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get clothingPhotoLocalPath => $composableBuilder(
    column: $table.clothingPhotoLocalPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastKnownClothing => $composableBuilder(
    column: $table.lastKnownClothing,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get campId => $composableBuilder(
    column: $table.campId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get campName => $composableBuilder(
    column: $table.campName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get officerUid => $composableBuilder(
    column: $table.officerUid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get officerName => $composableBuilder(
    column: $table.officerName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get officerContact => $composableBuilder(
    column: $table.officerContact,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get foundLocation => $composableBuilder(
    column: $table.foundLocation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get foundLatitude => $composableBuilder(
    column: $table.foundLatitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get foundLongitude => $composableBuilder(
    column: $table.foundLongitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get locationAccuracy => $composableBuilder(
    column: $table.locationAccuracy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get additionalDetails => $composableBuilder(
    column: $table.additionalDetails,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get foundAt => $composableBuilder(
    column: $table.foundAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CriticalRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $CriticalRecordsTable> {
  $$CriticalRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerUid => $composableBuilder(
    column: $table.ownerUid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get age => $composableBuilder(
    column: $table.age,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get photoUrl => $composableBuilder(
    column: $table.photoUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get clothingPhotoUrl => $composableBuilder(
    column: $table.clothingPhotoUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get photoLocalPath => $composableBuilder(
    column: $table.photoLocalPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get clothingPhotoLocalPath => $composableBuilder(
    column: $table.clothingPhotoLocalPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastKnownClothing => $composableBuilder(
    column: $table.lastKnownClothing,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get campId => $composableBuilder(
    column: $table.campId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get campName => $composableBuilder(
    column: $table.campName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get officerUid => $composableBuilder(
    column: $table.officerUid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get officerName => $composableBuilder(
    column: $table.officerName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get officerContact => $composableBuilder(
    column: $table.officerContact,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get foundLocation => $composableBuilder(
    column: $table.foundLocation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get foundLatitude => $composableBuilder(
    column: $table.foundLatitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get foundLongitude => $composableBuilder(
    column: $table.foundLongitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get locationAccuracy => $composableBuilder(
    column: $table.locationAccuracy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get additionalDetails => $composableBuilder(
    column: $table.additionalDetails,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get foundAt => $composableBuilder(
    column: $table.foundAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CriticalRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CriticalRecordsTable> {
  $$CriticalRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get ownerUid =>
      $composableBuilder(column: $table.ownerUid, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get age =>
      $composableBuilder(column: $table.age, builder: (column) => column);

  GeneratedColumn<String> get photoUrl =>
      $composableBuilder(column: $table.photoUrl, builder: (column) => column);

  GeneratedColumn<String> get clothingPhotoUrl => $composableBuilder(
    column: $table.clothingPhotoUrl,
    builder: (column) => column,
  );

  GeneratedColumn<String> get photoLocalPath => $composableBuilder(
    column: $table.photoLocalPath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get clothingPhotoLocalPath => $composableBuilder(
    column: $table.clothingPhotoLocalPath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastKnownClothing => $composableBuilder(
    column: $table.lastKnownClothing,
    builder: (column) => column,
  );

  GeneratedColumn<String> get campId =>
      $composableBuilder(column: $table.campId, builder: (column) => column);

  GeneratedColumn<String> get campName =>
      $composableBuilder(column: $table.campName, builder: (column) => column);

  GeneratedColumn<String> get officerUid => $composableBuilder(
    column: $table.officerUid,
    builder: (column) => column,
  );

  GeneratedColumn<String> get officerName => $composableBuilder(
    column: $table.officerName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get officerContact => $composableBuilder(
    column: $table.officerContact,
    builder: (column) => column,
  );

  GeneratedColumn<String> get foundLocation => $composableBuilder(
    column: $table.foundLocation,
    builder: (column) => column,
  );

  GeneratedColumn<double> get foundLatitude => $composableBuilder(
    column: $table.foundLatitude,
    builder: (column) => column,
  );

  GeneratedColumn<double> get foundLongitude => $composableBuilder(
    column: $table.foundLongitude,
    builder: (column) => column,
  );

  GeneratedColumn<double> get locationAccuracy => $composableBuilder(
    column: $table.locationAccuracy,
    builder: (column) => column,
  );

  GeneratedColumn<String> get additionalDetails => $composableBuilder(
    column: $table.additionalDetails,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get foundAt =>
      $composableBuilder(column: $table.foundAt, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$CriticalRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CriticalRecordsTable,
          CriticalRecord,
          $$CriticalRecordsTableFilterComposer,
          $$CriticalRecordsTableOrderingComposer,
          $$CriticalRecordsTableAnnotationComposer,
          $$CriticalRecordsTableCreateCompanionBuilder,
          $$CriticalRecordsTableUpdateCompanionBuilder,
          (
            CriticalRecord,
            BaseReferences<
              _$AppDatabase,
              $CriticalRecordsTable,
              CriticalRecord
            >,
          ),
          CriticalRecord,
          PrefetchHooks Function()
        > {
  $$CriticalRecordsTableTableManager(
    _$AppDatabase db,
    $CriticalRecordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CriticalRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CriticalRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CriticalRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> ownerUid = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> age = const Value.absent(),
                Value<String?> photoUrl = const Value.absent(),
                Value<String?> clothingPhotoUrl = const Value.absent(),
                Value<String?> photoLocalPath = const Value.absent(),
                Value<String?> clothingPhotoLocalPath = const Value.absent(),
                Value<String> lastKnownClothing = const Value.absent(),
                Value<String> campId = const Value.absent(),
                Value<String> campName = const Value.absent(),
                Value<String> officerUid = const Value.absent(),
                Value<String> officerName = const Value.absent(),
                Value<String> officerContact = const Value.absent(),
                Value<String> foundLocation = const Value.absent(),
                Value<double?> foundLatitude = const Value.absent(),
                Value<double?> foundLongitude = const Value.absent(),
                Value<double?> locationAccuracy = const Value.absent(),
                Value<String> additionalDetails = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime> foundAt = const Value.absent(),
                Value<DateTime?> createdAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CriticalRecordsCompanion(
                id: id,
                ownerUid: ownerUid,
                name: name,
                age: age,
                photoUrl: photoUrl,
                clothingPhotoUrl: clothingPhotoUrl,
                photoLocalPath: photoLocalPath,
                clothingPhotoLocalPath: clothingPhotoLocalPath,
                lastKnownClothing: lastKnownClothing,
                campId: campId,
                campName: campName,
                officerUid: officerUid,
                officerName: officerName,
                officerContact: officerContact,
                foundLocation: foundLocation,
                foundLatitude: foundLatitude,
                foundLongitude: foundLongitude,
                locationAccuracy: locationAccuracy,
                additionalDetails: additionalDetails,
                status: status,
                foundAt: foundAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> ownerUid = const Value.absent(),
                required String name,
                required int age,
                Value<String?> photoUrl = const Value.absent(),
                Value<String?> clothingPhotoUrl = const Value.absent(),
                Value<String?> photoLocalPath = const Value.absent(),
                Value<String?> clothingPhotoLocalPath = const Value.absent(),
                required String lastKnownClothing,
                required String campId,
                required String campName,
                required String officerUid,
                required String officerName,
                required String officerContact,
                required String foundLocation,
                Value<double?> foundLatitude = const Value.absent(),
                Value<double?> foundLongitude = const Value.absent(),
                Value<double?> locationAccuracy = const Value.absent(),
                required String additionalDetails,
                required String status,
                required DateTime foundAt,
                Value<DateTime?> createdAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CriticalRecordsCompanion.insert(
                id: id,
                ownerUid: ownerUid,
                name: name,
                age: age,
                photoUrl: photoUrl,
                clothingPhotoUrl: clothingPhotoUrl,
                photoLocalPath: photoLocalPath,
                clothingPhotoLocalPath: clothingPhotoLocalPath,
                lastKnownClothing: lastKnownClothing,
                campId: campId,
                campName: campName,
                officerUid: officerUid,
                officerName: officerName,
                officerContact: officerContact,
                foundLocation: foundLocation,
                foundLatitude: foundLatitude,
                foundLongitude: foundLongitude,
                locationAccuracy: locationAccuracy,
                additionalDetails: additionalDetails,
                status: status,
                foundAt: foundAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CriticalRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CriticalRecordsTable,
      CriticalRecord,
      $$CriticalRecordsTableFilterComposer,
      $$CriticalRecordsTableOrderingComposer,
      $$CriticalRecordsTableAnnotationComposer,
      $$CriticalRecordsTableCreateCompanionBuilder,
      $$CriticalRecordsTableUpdateCompanionBuilder,
      (
        CriticalRecord,
        BaseReferences<_$AppDatabase, $CriticalRecordsTable, CriticalRecord>,
      ),
      CriticalRecord,
      PrefetchHooks Function()
    >;
typedef $$EmergencyAlertsTableCreateCompanionBuilder =
    EmergencyAlertsCompanion Function({
      required String id,
      required String title,
      Value<String?> message,
      required String type,
      required String severity,
      Value<String?> district,
      Value<String?> state,
      Value<double?> latitude,
      Value<double?> longitude,
      Value<double?> radiusKm,
      Value<bool> active,
      required DateTime createdAt,
      required DateTime cachedAt,
      Value<int> rowid,
    });
typedef $$EmergencyAlertsTableUpdateCompanionBuilder =
    EmergencyAlertsCompanion Function({
      Value<String> id,
      Value<String> title,
      Value<String?> message,
      Value<String> type,
      Value<String> severity,
      Value<String?> district,
      Value<String?> state,
      Value<double?> latitude,
      Value<double?> longitude,
      Value<double?> radiusKm,
      Value<bool> active,
      Value<DateTime> createdAt,
      Value<DateTime> cachedAt,
      Value<int> rowid,
    });

class $$EmergencyAlertsTableFilterComposer
    extends Composer<_$AppDatabase, $EmergencyAlertsTable> {
  $$EmergencyAlertsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get message => $composableBuilder(
    column: $table.message,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get severity => $composableBuilder(
    column: $table.severity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get district => $composableBuilder(
    column: $table.district,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get radiusKm => $composableBuilder(
    column: $table.radiusKm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get active => $composableBuilder(
    column: $table.active,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get cachedAt => $composableBuilder(
    column: $table.cachedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$EmergencyAlertsTableOrderingComposer
    extends Composer<_$AppDatabase, $EmergencyAlertsTable> {
  $$EmergencyAlertsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get message => $composableBuilder(
    column: $table.message,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get severity => $composableBuilder(
    column: $table.severity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get district => $composableBuilder(
    column: $table.district,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get radiusKm => $composableBuilder(
    column: $table.radiusKm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get active => $composableBuilder(
    column: $table.active,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get cachedAt => $composableBuilder(
    column: $table.cachedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$EmergencyAlertsTableAnnotationComposer
    extends Composer<_$AppDatabase, $EmergencyAlertsTable> {
  $$EmergencyAlertsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get message =>
      $composableBuilder(column: $table.message, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get severity =>
      $composableBuilder(column: $table.severity, builder: (column) => column);

  GeneratedColumn<String> get district =>
      $composableBuilder(column: $table.district, builder: (column) => column);

  GeneratedColumn<String> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<double> get radiusKm =>
      $composableBuilder(column: $table.radiusKm, builder: (column) => column);

  GeneratedColumn<bool> get active =>
      $composableBuilder(column: $table.active, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get cachedAt =>
      $composableBuilder(column: $table.cachedAt, builder: (column) => column);
}

class $$EmergencyAlertsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EmergencyAlertsTable,
          EmergencyAlert,
          $$EmergencyAlertsTableFilterComposer,
          $$EmergencyAlertsTableOrderingComposer,
          $$EmergencyAlertsTableAnnotationComposer,
          $$EmergencyAlertsTableCreateCompanionBuilder,
          $$EmergencyAlertsTableUpdateCompanionBuilder,
          (
            EmergencyAlert,
            BaseReferences<
              _$AppDatabase,
              $EmergencyAlertsTable,
              EmergencyAlert
            >,
          ),
          EmergencyAlert,
          PrefetchHooks Function()
        > {
  $$EmergencyAlertsTableTableManager(
    _$AppDatabase db,
    $EmergencyAlertsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EmergencyAlertsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EmergencyAlertsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EmergencyAlertsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> message = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> severity = const Value.absent(),
                Value<String?> district = const Value.absent(),
                Value<String?> state = const Value.absent(),
                Value<double?> latitude = const Value.absent(),
                Value<double?> longitude = const Value.absent(),
                Value<double?> radiusKm = const Value.absent(),
                Value<bool> active = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> cachedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EmergencyAlertsCompanion(
                id: id,
                title: title,
                message: message,
                type: type,
                severity: severity,
                district: district,
                state: state,
                latitude: latitude,
                longitude: longitude,
                radiusKm: radiusKm,
                active: active,
                createdAt: createdAt,
                cachedAt: cachedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                Value<String?> message = const Value.absent(),
                required String type,
                required String severity,
                Value<String?> district = const Value.absent(),
                Value<String?> state = const Value.absent(),
                Value<double?> latitude = const Value.absent(),
                Value<double?> longitude = const Value.absent(),
                Value<double?> radiusKm = const Value.absent(),
                Value<bool> active = const Value.absent(),
                required DateTime createdAt,
                required DateTime cachedAt,
                Value<int> rowid = const Value.absent(),
              }) => EmergencyAlertsCompanion.insert(
                id: id,
                title: title,
                message: message,
                type: type,
                severity: severity,
                district: district,
                state: state,
                latitude: latitude,
                longitude: longitude,
                radiusKm: radiusKm,
                active: active,
                createdAt: createdAt,
                cachedAt: cachedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$EmergencyAlertsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EmergencyAlertsTable,
      EmergencyAlert,
      $$EmergencyAlertsTableFilterComposer,
      $$EmergencyAlertsTableOrderingComposer,
      $$EmergencyAlertsTableAnnotationComposer,
      $$EmergencyAlertsTableCreateCompanionBuilder,
      $$EmergencyAlertsTableUpdateCompanionBuilder,
      (
        EmergencyAlert,
        BaseReferences<_$AppDatabase, $EmergencyAlertsTable, EmergencyAlert>,
      ),
      EmergencyAlert,
      PrefetchHooks Function()
    >;
typedef $$SyncQueueTableCreateCompanionBuilder =
    SyncQueueCompanion Function({
      Value<int> id,
      Value<String?> ownerUid,
      required String entityType,
      required String entityId,
      required String operationType,
      required String payload,
      required DateTime createdAt,
      Value<int> retryCount,
      Value<DateTime?> lastAttemptAt,
      required String syncStatus,
    });
typedef $$SyncQueueTableUpdateCompanionBuilder =
    SyncQueueCompanion Function({
      Value<int> id,
      Value<String?> ownerUid,
      Value<String> entityType,
      Value<String> entityId,
      Value<String> operationType,
      Value<String> payload,
      Value<DateTime> createdAt,
      Value<int> retryCount,
      Value<DateTime?> lastAttemptAt,
      Value<String> syncStatus,
    });

class $$SyncQueueTableFilterComposer
    extends Composer<_$AppDatabase, $SyncQueueTable> {
  $$SyncQueueTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerUid => $composableBuilder(
    column: $table.ownerUid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get operationType => $composableBuilder(
    column: $table.operationType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastAttemptAt => $composableBuilder(
    column: $table.lastAttemptAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncQueueTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncQueueTable> {
  $$SyncQueueTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerUid => $composableBuilder(
    column: $table.ownerUid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get operationType => $composableBuilder(
    column: $table.operationType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastAttemptAt => $composableBuilder(
    column: $table.lastAttemptAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncQueueTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncQueueTable> {
  $$SyncQueueTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get ownerUid =>
      $composableBuilder(column: $table.ownerUid, builder: (column) => column);

  GeneratedColumn<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get operationType => $composableBuilder(
    column: $table.operationType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastAttemptAt => $composableBuilder(
    column: $table.lastAttemptAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );
}

class $$SyncQueueTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncQueueTable,
          SyncQueueData,
          $$SyncQueueTableFilterComposer,
          $$SyncQueueTableOrderingComposer,
          $$SyncQueueTableAnnotationComposer,
          $$SyncQueueTableCreateCompanionBuilder,
          $$SyncQueueTableUpdateCompanionBuilder,
          (
            SyncQueueData,
            BaseReferences<_$AppDatabase, $SyncQueueTable, SyncQueueData>,
          ),
          SyncQueueData,
          PrefetchHooks Function()
        > {
  $$SyncQueueTableTableManager(_$AppDatabase db, $SyncQueueTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncQueueTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncQueueTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncQueueTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> ownerUid = const Value.absent(),
                Value<String> entityType = const Value.absent(),
                Value<String> entityId = const Value.absent(),
                Value<String> operationType = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> retryCount = const Value.absent(),
                Value<DateTime?> lastAttemptAt = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
              }) => SyncQueueCompanion(
                id: id,
                ownerUid: ownerUid,
                entityType: entityType,
                entityId: entityId,
                operationType: operationType,
                payload: payload,
                createdAt: createdAt,
                retryCount: retryCount,
                lastAttemptAt: lastAttemptAt,
                syncStatus: syncStatus,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> ownerUid = const Value.absent(),
                required String entityType,
                required String entityId,
                required String operationType,
                required String payload,
                required DateTime createdAt,
                Value<int> retryCount = const Value.absent(),
                Value<DateTime?> lastAttemptAt = const Value.absent(),
                required String syncStatus,
              }) => SyncQueueCompanion.insert(
                id: id,
                ownerUid: ownerUid,
                entityType: entityType,
                entityId: entityId,
                operationType: operationType,
                payload: payload,
                createdAt: createdAt,
                retryCount: retryCount,
                lastAttemptAt: lastAttemptAt,
                syncStatus: syncStatus,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncQueueTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncQueueTable,
      SyncQueueData,
      $$SyncQueueTableFilterComposer,
      $$SyncQueueTableOrderingComposer,
      $$SyncQueueTableAnnotationComposer,
      $$SyncQueueTableCreateCompanionBuilder,
      $$SyncQueueTableUpdateCompanionBuilder,
      (
        SyncQueueData,
        BaseReferences<_$AppDatabase, $SyncQueueTable, SyncQueueData>,
      ),
      SyncQueueData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CampsTableTableManager get camps =>
      $$CampsTableTableManager(_db, _db.camps);
  $$NormalRecordsTableTableManager get normalRecords =>
      $$NormalRecordsTableTableManager(_db, _db.normalRecords);
  $$CriticalRecordsTableTableManager get criticalRecords =>
      $$CriticalRecordsTableTableManager(_db, _db.criticalRecords);
  $$EmergencyAlertsTableTableManager get emergencyAlerts =>
      $$EmergencyAlertsTableTableManager(_db, _db.emergencyAlerts);
  $$SyncQueueTableTableManager get syncQueue =>
      $$SyncQueueTableTableManager(_db, _db.syncQueue);
}
