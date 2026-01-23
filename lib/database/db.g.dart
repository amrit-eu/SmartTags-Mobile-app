// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'db.dart';

// ignore_for_file: type=lint
class $PlatformsTable extends Platforms
    with TableInfo<$PlatformsTable, Platform> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlatformsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _refMeta = const VerificationMeta('ref');
  @override
  late final GeneratedColumn<String> ref = GeneratedColumn<String>(
    'ref',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 255,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _modelMeta = const VerificationMeta('model');
  @override
  late final GeneratedColumn<String> model = GeneratedColumn<String>(
    'model',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _networkMeta = const VerificationMeta(
    'network',
  );
  @override
  late final GeneratedColumn<String> network = GeneratedColumn<String>(
    'network',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _latMeta = const VerificationMeta('lat');
  @override
  late final GeneratedColumn<double> lat = GeneratedColumn<double>(
    'lat',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lonMeta = const VerificationMeta('lon');
  @override
  late final GeneratedColumn<double> lon = GeneratedColumn<double>(
    'lon',
    aliasedName,
    false,
    type: DriftSqlType.double,
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
  static const VerificationMeta _operationalStatusMeta = const VerificationMeta(
    'operationalStatus',
  );
  @override
  late final GeneratedColumn<String> operationalStatus =
      GeneratedColumn<String>(
        'operational_status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _lastUpdatedMeta = const VerificationMeta(
    'lastUpdated',
  );
  @override
  late final GeneratedColumn<DateTime> lastUpdated = GeneratedColumn<DateTime>(
    'last_updated',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _operationLatMeta = const VerificationMeta(
    'operationLat',
  );
  @override
  late final GeneratedColumn<double> operationLat = GeneratedColumn<double>(
    'operation_lat',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _operationLonMeta = const VerificationMeta(
    'operationLon',
  );
  @override
  late final GeneratedColumn<double> operationLon = GeneratedColumn<double>(
    'operation_lon',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _wigosIdMeta = const VerificationMeta(
    'wigosId',
  );
  @override
  late final GeneratedColumn<String> wigosId = GeneratedColumn<String>(
    'wigos_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _gtsIdMeta = const VerificationMeta('gtsId');
  @override
  late final GeneratedColumn<String> gtsId = GeneratedColumn<String>(
    'gts_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _batchRefMeta = const VerificationMeta(
    'batchRef',
  );
  @override
  late final GeneratedColumn<String> batchRef = GeneratedColumn<String>(
    'batch_ref',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    ref,
    model,
    network,
    lat,
    lon,
    status,
    operationalStatus,
    lastUpdated,
    operationLat,
    operationLon,
    wigosId,
    gtsId,
    batchRef,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'platforms';
  @override
  VerificationContext validateIntegrity(
    Insertable<Platform> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('ref')) {
      context.handle(
        _refMeta,
        ref.isAcceptableOrUnknown(data['ref']!, _refMeta),
      );
    } else if (isInserting) {
      context.missing(_refMeta);
    }
    if (data.containsKey('model')) {
      context.handle(
        _modelMeta,
        model.isAcceptableOrUnknown(data['model']!, _modelMeta),
      );
    } else if (isInserting) {
      context.missing(_modelMeta);
    }
    if (data.containsKey('network')) {
      context.handle(
        _networkMeta,
        network.isAcceptableOrUnknown(data['network']!, _networkMeta),
      );
    } else if (isInserting) {
      context.missing(_networkMeta);
    }
    if (data.containsKey('lat')) {
      context.handle(
        _latMeta,
        lat.isAcceptableOrUnknown(data['lat']!, _latMeta),
      );
    } else if (isInserting) {
      context.missing(_latMeta);
    }
    if (data.containsKey('lon')) {
      context.handle(
        _lonMeta,
        lon.isAcceptableOrUnknown(data['lon']!, _lonMeta),
      );
    } else if (isInserting) {
      context.missing(_lonMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('operational_status')) {
      context.handle(
        _operationalStatusMeta,
        operationalStatus.isAcceptableOrUnknown(
          data['operational_status']!,
          _operationalStatusMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_operationalStatusMeta);
    }
    if (data.containsKey('last_updated')) {
      context.handle(
        _lastUpdatedMeta,
        lastUpdated.isAcceptableOrUnknown(
          data['last_updated']!,
          _lastUpdatedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastUpdatedMeta);
    }
    if (data.containsKey('operation_lat')) {
      context.handle(
        _operationLatMeta,
        operationLat.isAcceptableOrUnknown(
          data['operation_lat']!,
          _operationLatMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_operationLatMeta);
    }
    if (data.containsKey('operation_lon')) {
      context.handle(
        _operationLonMeta,
        operationLon.isAcceptableOrUnknown(
          data['operation_lon']!,
          _operationLonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_operationLonMeta);
    }
    if (data.containsKey('wigos_id')) {
      context.handle(
        _wigosIdMeta,
        wigosId.isAcceptableOrUnknown(data['wigos_id']!, _wigosIdMeta),
      );
    }
    if (data.containsKey('gts_id')) {
      context.handle(
        _gtsIdMeta,
        gtsId.isAcceptableOrUnknown(data['gts_id']!, _gtsIdMeta),
      );
    }
    if (data.containsKey('batch_ref')) {
      context.handle(
        _batchRefMeta,
        batchRef.isAcceptableOrUnknown(data['batch_ref']!, _batchRefMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Platform map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Platform(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      ref: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ref'],
      )!,
      model: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}model'],
      )!,
      network: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}network'],
      )!,
      lat: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}lat'],
      )!,
      lon: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}lon'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      operationalStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}operational_status'],
      )!,
      lastUpdated: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_updated'],
      )!,
      operationLat: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}operation_lat'],
      )!,
      operationLon: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}operation_lon'],
      )!,
      wigosId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}wigos_id'],
      ),
      gtsId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}gts_id'],
      ),
      batchRef: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}batch_ref'],
      ),
    );
  }

  @override
  $PlatformsTable createAlias(String alias) {
    return $PlatformsTable(attachedDatabase, alias);
  }
}

class Platform extends DataClass implements Insertable<Platform> {
  /// Primary key identifying the record.
  final int id;

  /// External reference (ID) e.g., PLT-12345.
  final String ref;

  /// Model name of the platform.
  final String model;

  /// Network name (e.g., Argo, DBCP).
  final String network;

  /// Latest reported latitude.
  final double lat;

  /// Latest reported longitude.
  final double lon;

  /// Status string (Active/Inactive).
  final String status;

  /// Operational status (Deployed/Recovered).
  final String operationalStatus;

  /// Last update timestamp.
  final DateTime lastUpdated;

  /// Latitude of the last operation.
  final double operationLat;

  /// Longitude of the last operation.
  final double operationLon;

  /// WIGOS identifier (optional).
  final String? wigosId;

  /// GTS identifier (optional).
  final String? gtsId;

  /// Batch reference (optional).
  final String? batchRef;
  const Platform({
    required this.id,
    required this.ref,
    required this.model,
    required this.network,
    required this.lat,
    required this.lon,
    required this.status,
    required this.operationalStatus,
    required this.lastUpdated,
    required this.operationLat,
    required this.operationLon,
    this.wigosId,
    this.gtsId,
    this.batchRef,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['ref'] = Variable<String>(ref);
    map['model'] = Variable<String>(model);
    map['network'] = Variable<String>(network);
    map['lat'] = Variable<double>(lat);
    map['lon'] = Variable<double>(lon);
    map['status'] = Variable<String>(status);
    map['operational_status'] = Variable<String>(operationalStatus);
    map['last_updated'] = Variable<DateTime>(lastUpdated);
    map['operation_lat'] = Variable<double>(operationLat);
    map['operation_lon'] = Variable<double>(operationLon);
    if (!nullToAbsent || wigosId != null) {
      map['wigos_id'] = Variable<String>(wigosId);
    }
    if (!nullToAbsent || gtsId != null) {
      map['gts_id'] = Variable<String>(gtsId);
    }
    if (!nullToAbsent || batchRef != null) {
      map['batch_ref'] = Variable<String>(batchRef);
    }
    return map;
  }

  PlatformsCompanion toCompanion(bool nullToAbsent) {
    return PlatformsCompanion(
      id: Value(id),
      ref: Value(ref),
      model: Value(model),
      network: Value(network),
      lat: Value(lat),
      lon: Value(lon),
      status: Value(status),
      operationalStatus: Value(operationalStatus),
      lastUpdated: Value(lastUpdated),
      operationLat: Value(operationLat),
      operationLon: Value(operationLon),
      wigosId: wigosId == null && nullToAbsent
          ? const Value.absent()
          : Value(wigosId),
      gtsId: gtsId == null && nullToAbsent
          ? const Value.absent()
          : Value(gtsId),
      batchRef: batchRef == null && nullToAbsent
          ? const Value.absent()
          : Value(batchRef),
    );
  }

  factory Platform.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Platform(
      id: serializer.fromJson<int>(json['id']),
      ref: serializer.fromJson<String>(json['ref']),
      model: serializer.fromJson<String>(json['model']),
      network: serializer.fromJson<String>(json['network']),
      lat: serializer.fromJson<double>(json['lat']),
      lon: serializer.fromJson<double>(json['lon']),
      status: serializer.fromJson<String>(json['status']),
      operationalStatus: serializer.fromJson<String>(json['operationalStatus']),
      lastUpdated: serializer.fromJson<DateTime>(json['lastUpdated']),
      operationLat: serializer.fromJson<double>(json['operationLat']),
      operationLon: serializer.fromJson<double>(json['operationLon']),
      wigosId: serializer.fromJson<String?>(json['wigosId']),
      gtsId: serializer.fromJson<String?>(json['gtsId']),
      batchRef: serializer.fromJson<String?>(json['batchRef']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'ref': serializer.toJson<String>(ref),
      'model': serializer.toJson<String>(model),
      'network': serializer.toJson<String>(network),
      'lat': serializer.toJson<double>(lat),
      'lon': serializer.toJson<double>(lon),
      'status': serializer.toJson<String>(status),
      'operationalStatus': serializer.toJson<String>(operationalStatus),
      'lastUpdated': serializer.toJson<DateTime>(lastUpdated),
      'operationLat': serializer.toJson<double>(operationLat),
      'operationLon': serializer.toJson<double>(operationLon),
      'wigosId': serializer.toJson<String?>(wigosId),
      'gtsId': serializer.toJson<String?>(gtsId),
      'batchRef': serializer.toJson<String?>(batchRef),
    };
  }

  Platform copyWith({
    int? id,
    String? ref,
    String? model,
    String? network,
    double? lat,
    double? lon,
    String? status,
    String? operationalStatus,
    DateTime? lastUpdated,
    double? operationLat,
    double? operationLon,
    Value<String?> wigosId = const Value.absent(),
    Value<String?> gtsId = const Value.absent(),
    Value<String?> batchRef = const Value.absent(),
  }) => Platform(
    id: id ?? this.id,
    ref: ref ?? this.ref,
    model: model ?? this.model,
    network: network ?? this.network,
    lat: lat ?? this.lat,
    lon: lon ?? this.lon,
    status: status ?? this.status,
    operationalStatus: operationalStatus ?? this.operationalStatus,
    lastUpdated: lastUpdated ?? this.lastUpdated,
    operationLat: operationLat ?? this.operationLat,
    operationLon: operationLon ?? this.operationLon,
    wigosId: wigosId.present ? wigosId.value : this.wigosId,
    gtsId: gtsId.present ? gtsId.value : this.gtsId,
    batchRef: batchRef.present ? batchRef.value : this.batchRef,
  );
  Platform copyWithCompanion(PlatformsCompanion data) {
    return Platform(
      id: data.id.present ? data.id.value : this.id,
      ref: data.ref.present ? data.ref.value : this.ref,
      model: data.model.present ? data.model.value : this.model,
      network: data.network.present ? data.network.value : this.network,
      lat: data.lat.present ? data.lat.value : this.lat,
      lon: data.lon.present ? data.lon.value : this.lon,
      status: data.status.present ? data.status.value : this.status,
      operationalStatus: data.operationalStatus.present
          ? data.operationalStatus.value
          : this.operationalStatus,
      lastUpdated: data.lastUpdated.present
          ? data.lastUpdated.value
          : this.lastUpdated,
      operationLat: data.operationLat.present
          ? data.operationLat.value
          : this.operationLat,
      operationLon: data.operationLon.present
          ? data.operationLon.value
          : this.operationLon,
      wigosId: data.wigosId.present ? data.wigosId.value : this.wigosId,
      gtsId: data.gtsId.present ? data.gtsId.value : this.gtsId,
      batchRef: data.batchRef.present ? data.batchRef.value : this.batchRef,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Platform(')
          ..write('id: $id, ')
          ..write('ref: $ref, ')
          ..write('model: $model, ')
          ..write('network: $network, ')
          ..write('lat: $lat, ')
          ..write('lon: $lon, ')
          ..write('status: $status, ')
          ..write('operationalStatus: $operationalStatus, ')
          ..write('lastUpdated: $lastUpdated, ')
          ..write('operationLat: $operationLat, ')
          ..write('operationLon: $operationLon, ')
          ..write('wigosId: $wigosId, ')
          ..write('gtsId: $gtsId, ')
          ..write('batchRef: $batchRef')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    ref,
    model,
    network,
    lat,
    lon,
    status,
    operationalStatus,
    lastUpdated,
    operationLat,
    operationLon,
    wigosId,
    gtsId,
    batchRef,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Platform &&
          other.id == this.id &&
          other.ref == this.ref &&
          other.model == this.model &&
          other.network == this.network &&
          other.lat == this.lat &&
          other.lon == this.lon &&
          other.status == this.status &&
          other.operationalStatus == this.operationalStatus &&
          other.lastUpdated == this.lastUpdated &&
          other.operationLat == this.operationLat &&
          other.operationLon == this.operationLon &&
          other.wigosId == this.wigosId &&
          other.gtsId == this.gtsId &&
          other.batchRef == this.batchRef);
}

class PlatformsCompanion extends UpdateCompanion<Platform> {
  final Value<int> id;
  final Value<String> ref;
  final Value<String> model;
  final Value<String> network;
  final Value<double> lat;
  final Value<double> lon;
  final Value<String> status;
  final Value<String> operationalStatus;
  final Value<DateTime> lastUpdated;
  final Value<double> operationLat;
  final Value<double> operationLon;
  final Value<String?> wigosId;
  final Value<String?> gtsId;
  final Value<String?> batchRef;
  const PlatformsCompanion({
    this.id = const Value.absent(),
    this.ref = const Value.absent(),
    this.model = const Value.absent(),
    this.network = const Value.absent(),
    this.lat = const Value.absent(),
    this.lon = const Value.absent(),
    this.status = const Value.absent(),
    this.operationalStatus = const Value.absent(),
    this.lastUpdated = const Value.absent(),
    this.operationLat = const Value.absent(),
    this.operationLon = const Value.absent(),
    this.wigosId = const Value.absent(),
    this.gtsId = const Value.absent(),
    this.batchRef = const Value.absent(),
  });
  PlatformsCompanion.insert({
    this.id = const Value.absent(),
    required String ref,
    required String model,
    required String network,
    required double lat,
    required double lon,
    required String status,
    required String operationalStatus,
    required DateTime lastUpdated,
    required double operationLat,
    required double operationLon,
    this.wigosId = const Value.absent(),
    this.gtsId = const Value.absent(),
    this.batchRef = const Value.absent(),
  }) : ref = Value(ref),
       model = Value(model),
       network = Value(network),
       lat = Value(lat),
       lon = Value(lon),
       status = Value(status),
       operationalStatus = Value(operationalStatus),
       lastUpdated = Value(lastUpdated),
       operationLat = Value(operationLat),
       operationLon = Value(operationLon);
  static Insertable<Platform> custom({
    Expression<int>? id,
    Expression<String>? ref,
    Expression<String>? model,
    Expression<String>? network,
    Expression<double>? lat,
    Expression<double>? lon,
    Expression<String>? status,
    Expression<String>? operationalStatus,
    Expression<DateTime>? lastUpdated,
    Expression<double>? operationLat,
    Expression<double>? operationLon,
    Expression<String>? wigosId,
    Expression<String>? gtsId,
    Expression<String>? batchRef,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ref != null) 'ref': ref,
      if (model != null) 'model': model,
      if (network != null) 'network': network,
      if (lat != null) 'lat': lat,
      if (lon != null) 'lon': lon,
      if (status != null) 'status': status,
      if (operationalStatus != null) 'operational_status': operationalStatus,
      if (lastUpdated != null) 'last_updated': lastUpdated,
      if (operationLat != null) 'operation_lat': operationLat,
      if (operationLon != null) 'operation_lon': operationLon,
      if (wigosId != null) 'wigos_id': wigosId,
      if (gtsId != null) 'gts_id': gtsId,
      if (batchRef != null) 'batch_ref': batchRef,
    });
  }

  PlatformsCompanion copyWith({
    Value<int>? id,
    Value<String>? ref,
    Value<String>? model,
    Value<String>? network,
    Value<double>? lat,
    Value<double>? lon,
    Value<String>? status,
    Value<String>? operationalStatus,
    Value<DateTime>? lastUpdated,
    Value<double>? operationLat,
    Value<double>? operationLon,
    Value<String?>? wigosId,
    Value<String?>? gtsId,
    Value<String?>? batchRef,
  }) {
    return PlatformsCompanion(
      id: id ?? this.id,
      ref: ref ?? this.ref,
      model: model ?? this.model,
      network: network ?? this.network,
      lat: lat ?? this.lat,
      lon: lon ?? this.lon,
      status: status ?? this.status,
      operationalStatus: operationalStatus ?? this.operationalStatus,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      operationLat: operationLat ?? this.operationLat,
      operationLon: operationLon ?? this.operationLon,
      wigosId: wigosId ?? this.wigosId,
      gtsId: gtsId ?? this.gtsId,
      batchRef: batchRef ?? this.batchRef,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (ref.present) {
      map['ref'] = Variable<String>(ref.value);
    }
    if (model.present) {
      map['model'] = Variable<String>(model.value);
    }
    if (network.present) {
      map['network'] = Variable<String>(network.value);
    }
    if (lat.present) {
      map['lat'] = Variable<double>(lat.value);
    }
    if (lon.present) {
      map['lon'] = Variable<double>(lon.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (operationalStatus.present) {
      map['operational_status'] = Variable<String>(operationalStatus.value);
    }
    if (lastUpdated.present) {
      map['last_updated'] = Variable<DateTime>(lastUpdated.value);
    }
    if (operationLat.present) {
      map['operation_lat'] = Variable<double>(operationLat.value);
    }
    if (operationLon.present) {
      map['operation_lon'] = Variable<double>(operationLon.value);
    }
    if (wigosId.present) {
      map['wigos_id'] = Variable<String>(wigosId.value);
    }
    if (gtsId.present) {
      map['gts_id'] = Variable<String>(gtsId.value);
    }
    if (batchRef.present) {
      map['batch_ref'] = Variable<String>(batchRef.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlatformsCompanion(')
          ..write('id: $id, ')
          ..write('ref: $ref, ')
          ..write('model: $model, ')
          ..write('network: $network, ')
          ..write('lat: $lat, ')
          ..write('lon: $lon, ')
          ..write('status: $status, ')
          ..write('operationalStatus: $operationalStatus, ')
          ..write('lastUpdated: $lastUpdated, ')
          ..write('operationLat: $operationLat, ')
          ..write('operationLon: $operationLon, ')
          ..write('wigosId: $wigosId, ')
          ..write('gtsId: $gtsId, ')
          ..write('batchRef: $batchRef')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $PlatformsTable platforms = $PlatformsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [platforms];
}

typedef $$PlatformsTableCreateCompanionBuilder =
    PlatformsCompanion Function({
      Value<int> id,
      required String ref,
      required String model,
      required String network,
      required double lat,
      required double lon,
      required String status,
      required String operationalStatus,
      required DateTime lastUpdated,
      required double operationLat,
      required double operationLon,
      Value<String?> wigosId,
      Value<String?> gtsId,
      Value<String?> batchRef,
    });
typedef $$PlatformsTableUpdateCompanionBuilder =
    PlatformsCompanion Function({
      Value<int> id,
      Value<String> ref,
      Value<String> model,
      Value<String> network,
      Value<double> lat,
      Value<double> lon,
      Value<String> status,
      Value<String> operationalStatus,
      Value<DateTime> lastUpdated,
      Value<double> operationLat,
      Value<double> operationLon,
      Value<String?> wigosId,
      Value<String?> gtsId,
      Value<String?> batchRef,
    });

class $$PlatformsTableFilterComposer
    extends Composer<_$AppDatabase, $PlatformsTable> {
  $$PlatformsTableFilterComposer({
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

  ColumnFilters<String> get ref => $composableBuilder(
    column: $table.ref,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get model => $composableBuilder(
    column: $table.model,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get network => $composableBuilder(
    column: $table.network,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lat => $composableBuilder(
    column: $table.lat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lon => $composableBuilder(
    column: $table.lon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get operationalStatus => $composableBuilder(
    column: $table.operationalStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastUpdated => $composableBuilder(
    column: $table.lastUpdated,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get operationLat => $composableBuilder(
    column: $table.operationLat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get operationLon => $composableBuilder(
    column: $table.operationLon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get wigosId => $composableBuilder(
    column: $table.wigosId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get gtsId => $composableBuilder(
    column: $table.gtsId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get batchRef => $composableBuilder(
    column: $table.batchRef,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PlatformsTableOrderingComposer
    extends Composer<_$AppDatabase, $PlatformsTable> {
  $$PlatformsTableOrderingComposer({
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

  ColumnOrderings<String> get ref => $composableBuilder(
    column: $table.ref,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get model => $composableBuilder(
    column: $table.model,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get network => $composableBuilder(
    column: $table.network,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lat => $composableBuilder(
    column: $table.lat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lon => $composableBuilder(
    column: $table.lon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get operationalStatus => $composableBuilder(
    column: $table.operationalStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastUpdated => $composableBuilder(
    column: $table.lastUpdated,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get operationLat => $composableBuilder(
    column: $table.operationLat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get operationLon => $composableBuilder(
    column: $table.operationLon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get wigosId => $composableBuilder(
    column: $table.wigosId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get gtsId => $composableBuilder(
    column: $table.gtsId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get batchRef => $composableBuilder(
    column: $table.batchRef,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PlatformsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlatformsTable> {
  $$PlatformsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get ref =>
      $composableBuilder(column: $table.ref, builder: (column) => column);

  GeneratedColumn<String> get model =>
      $composableBuilder(column: $table.model, builder: (column) => column);

  GeneratedColumn<String> get network =>
      $composableBuilder(column: $table.network, builder: (column) => column);

  GeneratedColumn<double> get lat =>
      $composableBuilder(column: $table.lat, builder: (column) => column);

  GeneratedColumn<double> get lon =>
      $composableBuilder(column: $table.lon, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get operationalStatus => $composableBuilder(
    column: $table.operationalStatus,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastUpdated => $composableBuilder(
    column: $table.lastUpdated,
    builder: (column) => column,
  );

  GeneratedColumn<double> get operationLat => $composableBuilder(
    column: $table.operationLat,
    builder: (column) => column,
  );

  GeneratedColumn<double> get operationLon => $composableBuilder(
    column: $table.operationLon,
    builder: (column) => column,
  );

  GeneratedColumn<String> get wigosId =>
      $composableBuilder(column: $table.wigosId, builder: (column) => column);

  GeneratedColumn<String> get gtsId =>
      $composableBuilder(column: $table.gtsId, builder: (column) => column);

  GeneratedColumn<String> get batchRef =>
      $composableBuilder(column: $table.batchRef, builder: (column) => column);
}

class $$PlatformsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlatformsTable,
          Platform,
          $$PlatformsTableFilterComposer,
          $$PlatformsTableOrderingComposer,
          $$PlatformsTableAnnotationComposer,
          $$PlatformsTableCreateCompanionBuilder,
          $$PlatformsTableUpdateCompanionBuilder,
          (Platform, BaseReferences<_$AppDatabase, $PlatformsTable, Platform>),
          Platform,
          PrefetchHooks Function()
        > {
  $$PlatformsTableTableManager(_$AppDatabase db, $PlatformsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlatformsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlatformsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlatformsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> ref = const Value.absent(),
                Value<String> model = const Value.absent(),
                Value<String> network = const Value.absent(),
                Value<double> lat = const Value.absent(),
                Value<double> lon = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> operationalStatus = const Value.absent(),
                Value<DateTime> lastUpdated = const Value.absent(),
                Value<double> operationLat = const Value.absent(),
                Value<double> operationLon = const Value.absent(),
                Value<String?> wigosId = const Value.absent(),
                Value<String?> gtsId = const Value.absent(),
                Value<String?> batchRef = const Value.absent(),
              }) => PlatformsCompanion(
                id: id,
                ref: ref,
                model: model,
                network: network,
                lat: lat,
                lon: lon,
                status: status,
                operationalStatus: operationalStatus,
                lastUpdated: lastUpdated,
                operationLat: operationLat,
                operationLon: operationLon,
                wigosId: wigosId,
                gtsId: gtsId,
                batchRef: batchRef,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String ref,
                required String model,
                required String network,
                required double lat,
                required double lon,
                required String status,
                required String operationalStatus,
                required DateTime lastUpdated,
                required double operationLat,
                required double operationLon,
                Value<String?> wigosId = const Value.absent(),
                Value<String?> gtsId = const Value.absent(),
                Value<String?> batchRef = const Value.absent(),
              }) => PlatformsCompanion.insert(
                id: id,
                ref: ref,
                model: model,
                network: network,
                lat: lat,
                lon: lon,
                status: status,
                operationalStatus: operationalStatus,
                lastUpdated: lastUpdated,
                operationLat: operationLat,
                operationLon: operationLon,
                wigosId: wigosId,
                gtsId: gtsId,
                batchRef: batchRef,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PlatformsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlatformsTable,
      Platform,
      $$PlatformsTableFilterComposer,
      $$PlatformsTableOrderingComposer,
      $$PlatformsTableAnnotationComposer,
      $$PlatformsTableCreateCompanionBuilder,
      $$PlatformsTableUpdateCompanionBuilder,
      (Platform, BaseReferences<_$AppDatabase, $PlatformsTable, Platform>),
      Platform,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$PlatformsTableTableManager get platforms =>
      $$PlatformsTableTableManager(_db, _db.platforms);
}
