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
  static const VerificationMeta _operationNotesMeta = const VerificationMeta(
    'operationNotes',
  );
  @override
  late final GeneratedColumn<String> operationNotes = GeneratedColumn<String>(
    'operation_notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _platformCategoryMeta = const VerificationMeta(
    'platformCategory',
  );
  @override
  late final GeneratedColumn<String> platformCategory = GeneratedColumn<String>(
    'platform_category',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _reportingStatusMeta = const VerificationMeta(
    'reportingStatus',
  );
  @override
  late final GeneratedColumn<String> reportingStatus = GeneratedColumn<String>(
    'reporting_status',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _observingNetworkMeta = const VerificationMeta(
    'observingNetwork',
  );
  @override
  late final GeneratedColumn<String> observingNetwork = GeneratedColumn<String>(
    'observing_network',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _latestOperationTypeMeta =
      const VerificationMeta('latestOperationType');
  @override
  late final GeneratedColumn<String> latestOperationType =
      GeneratedColumn<String>(
        'latest_operation_type',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _latestOperationDateMeta =
      const VerificationMeta('latestOperationDate');
  @override
  late final GeneratedColumn<DateTime> latestOperationDate =
      GeneratedColumn<DateTime>(
        'latest_operation_date',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
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
    operationNotes,
    platformCategory,
    reportingStatus,
    observingNetwork,
    latestOperationType,
    latestOperationDate,
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
    if (data.containsKey('operation_notes')) {
      context.handle(
        _operationNotesMeta,
        operationNotes.isAcceptableOrUnknown(
          data['operation_notes']!,
          _operationNotesMeta,
        ),
      );
    }
    if (data.containsKey('platform_category')) {
      context.handle(
        _platformCategoryMeta,
        platformCategory.isAcceptableOrUnknown(
          data['platform_category']!,
          _platformCategoryMeta,
        ),
      );
    }
    if (data.containsKey('reporting_status')) {
      context.handle(
        _reportingStatusMeta,
        reportingStatus.isAcceptableOrUnknown(
          data['reporting_status']!,
          _reportingStatusMeta,
        ),
      );
    }
    if (data.containsKey('observing_network')) {
      context.handle(
        _observingNetworkMeta,
        observingNetwork.isAcceptableOrUnknown(
          data['observing_network']!,
          _observingNetworkMeta,
        ),
      );
    }
    if (data.containsKey('latest_operation_type')) {
      context.handle(
        _latestOperationTypeMeta,
        latestOperationType.isAcceptableOrUnknown(
          data['latest_operation_type']!,
          _latestOperationTypeMeta,
        ),
      );
    }
    if (data.containsKey('latest_operation_date')) {
      context.handle(
        _latestOperationDateMeta,
        latestOperationDate.isAcceptableOrUnknown(
          data['latest_operation_date']!,
          _latestOperationDateMeta,
        ),
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
      operationNotes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}operation_notes'],
      ),
      platformCategory: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}platform_category'],
      ),
      reportingStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reporting_status'],
      ),
      observingNetwork: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}observing_network'],
      ),
      latestOperationType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}latest_operation_type'],
      ),
      latestOperationDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}latest_operation_date'],
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

  /// CT-RST platform status (e.g. OPERATIONAL, INACTIVE).
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

  /// Additional notes about the latest operation (optional).
  final String? operationNotes;

  /// Platform category from passport (e.g. Float, Drifting buoy).
  final String? platformCategory;

  /// Passport reporting status for display chips (#97).
  final String? reportingStatus;

  /// Observing network names from passport affiliation (#97).
  final String? observingNetwork;

  /// Latest operation type: Deployment or Recovery (#99).
  final String? latestOperationType;

  /// Latest operation date from passport (#99).
  final DateTime? latestOperationDate;
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
    this.operationNotes,
    this.platformCategory,
    this.reportingStatus,
    this.observingNetwork,
    this.latestOperationType,
    this.latestOperationDate,
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
    if (!nullToAbsent || operationNotes != null) {
      map['operation_notes'] = Variable<String>(operationNotes);
    }
    if (!nullToAbsent || platformCategory != null) {
      map['platform_category'] = Variable<String>(platformCategory);
    }
    if (!nullToAbsent || reportingStatus != null) {
      map['reporting_status'] = Variable<String>(reportingStatus);
    }
    if (!nullToAbsent || observingNetwork != null) {
      map['observing_network'] = Variable<String>(observingNetwork);
    }
    if (!nullToAbsent || latestOperationType != null) {
      map['latest_operation_type'] = Variable<String>(latestOperationType);
    }
    if (!nullToAbsent || latestOperationDate != null) {
      map['latest_operation_date'] = Variable<DateTime>(latestOperationDate);
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
      operationNotes: operationNotes == null && nullToAbsent
          ? const Value.absent()
          : Value(operationNotes),
      platformCategory: platformCategory == null && nullToAbsent
          ? const Value.absent()
          : Value(platformCategory),
      reportingStatus: reportingStatus == null && nullToAbsent
          ? const Value.absent()
          : Value(reportingStatus),
      observingNetwork: observingNetwork == null && nullToAbsent
          ? const Value.absent()
          : Value(observingNetwork),
      latestOperationType: latestOperationType == null && nullToAbsent
          ? const Value.absent()
          : Value(latestOperationType),
      latestOperationDate: latestOperationDate == null && nullToAbsent
          ? const Value.absent()
          : Value(latestOperationDate),
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
      operationNotes: serializer.fromJson<String?>(json['operationNotes']),
      platformCategory: serializer.fromJson<String?>(json['platformCategory']),
      reportingStatus: serializer.fromJson<String?>(json['reportingStatus']),
      observingNetwork: serializer.fromJson<String?>(json['observingNetwork']),
      latestOperationType: serializer.fromJson<String?>(
        json['latestOperationType'],
      ),
      latestOperationDate: serializer.fromJson<DateTime?>(
        json['latestOperationDate'],
      ),
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
      'operationNotes': serializer.toJson<String?>(operationNotes),
      'platformCategory': serializer.toJson<String?>(platformCategory),
      'reportingStatus': serializer.toJson<String?>(reportingStatus),
      'observingNetwork': serializer.toJson<String?>(observingNetwork),
      'latestOperationType': serializer.toJson<String?>(latestOperationType),
      'latestOperationDate': serializer.toJson<DateTime?>(latestOperationDate),
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
    Value<String?> operationNotes = const Value.absent(),
    Value<String?> platformCategory = const Value.absent(),
    Value<String?> reportingStatus = const Value.absent(),
    Value<String?> observingNetwork = const Value.absent(),
    Value<String?> latestOperationType = const Value.absent(),
    Value<DateTime?> latestOperationDate = const Value.absent(),
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
    operationNotes: operationNotes.present
        ? operationNotes.value
        : this.operationNotes,
    platformCategory: platformCategory.present
        ? platformCategory.value
        : this.platformCategory,
    reportingStatus: reportingStatus.present
        ? reportingStatus.value
        : this.reportingStatus,
    observingNetwork: observingNetwork.present
        ? observingNetwork.value
        : this.observingNetwork,
    latestOperationType: latestOperationType.present
        ? latestOperationType.value
        : this.latestOperationType,
    latestOperationDate: latestOperationDate.present
        ? latestOperationDate.value
        : this.latestOperationDate,
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
      operationNotes: data.operationNotes.present
          ? data.operationNotes.value
          : this.operationNotes,
      platformCategory: data.platformCategory.present
          ? data.platformCategory.value
          : this.platformCategory,
      reportingStatus: data.reportingStatus.present
          ? data.reportingStatus.value
          : this.reportingStatus,
      observingNetwork: data.observingNetwork.present
          ? data.observingNetwork.value
          : this.observingNetwork,
      latestOperationType: data.latestOperationType.present
          ? data.latestOperationType.value
          : this.latestOperationType,
      latestOperationDate: data.latestOperationDate.present
          ? data.latestOperationDate.value
          : this.latestOperationDate,
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
          ..write('batchRef: $batchRef, ')
          ..write('operationNotes: $operationNotes, ')
          ..write('platformCategory: $platformCategory, ')
          ..write('reportingStatus: $reportingStatus, ')
          ..write('observingNetwork: $observingNetwork, ')
          ..write('latestOperationType: $latestOperationType, ')
          ..write('latestOperationDate: $latestOperationDate')
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
    operationNotes,
    platformCategory,
    reportingStatus,
    observingNetwork,
    latestOperationType,
    latestOperationDate,
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
          other.batchRef == this.batchRef &&
          other.operationNotes == this.operationNotes &&
          other.platformCategory == this.platformCategory &&
          other.reportingStatus == this.reportingStatus &&
          other.observingNetwork == this.observingNetwork &&
          other.latestOperationType == this.latestOperationType &&
          other.latestOperationDate == this.latestOperationDate);
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
  final Value<String?> operationNotes;
  final Value<String?> platformCategory;
  final Value<String?> reportingStatus;
  final Value<String?> observingNetwork;
  final Value<String?> latestOperationType;
  final Value<DateTime?> latestOperationDate;
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
    this.operationNotes = const Value.absent(),
    this.platformCategory = const Value.absent(),
    this.reportingStatus = const Value.absent(),
    this.observingNetwork = const Value.absent(),
    this.latestOperationType = const Value.absent(),
    this.latestOperationDate = const Value.absent(),
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
    this.operationNotes = const Value.absent(),
    this.platformCategory = const Value.absent(),
    this.reportingStatus = const Value.absent(),
    this.observingNetwork = const Value.absent(),
    this.latestOperationType = const Value.absent(),
    this.latestOperationDate = const Value.absent(),
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
    Expression<String>? operationNotes,
    Expression<String>? platformCategory,
    Expression<String>? reportingStatus,
    Expression<String>? observingNetwork,
    Expression<String>? latestOperationType,
    Expression<DateTime>? latestOperationDate,
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
      if (operationNotes != null) 'operation_notes': operationNotes,
      if (platformCategory != null) 'platform_category': platformCategory,
      if (reportingStatus != null) 'reporting_status': reportingStatus,
      if (observingNetwork != null) 'observing_network': observingNetwork,
      if (latestOperationType != null)
        'latest_operation_type': latestOperationType,
      if (latestOperationDate != null)
        'latest_operation_date': latestOperationDate,
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
    Value<String?>? operationNotes,
    Value<String?>? platformCategory,
    Value<String?>? reportingStatus,
    Value<String?>? observingNetwork,
    Value<String?>? latestOperationType,
    Value<DateTime?>? latestOperationDate,
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
      operationNotes: operationNotes ?? this.operationNotes,
      platformCategory: platformCategory ?? this.platformCategory,
      reportingStatus: reportingStatus ?? this.reportingStatus,
      observingNetwork: observingNetwork ?? this.observingNetwork,
      latestOperationType: latestOperationType ?? this.latestOperationType,
      latestOperationDate: latestOperationDate ?? this.latestOperationDate,
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
    if (operationNotes.present) {
      map['operation_notes'] = Variable<String>(operationNotes.value);
    }
    if (platformCategory.present) {
      map['platform_category'] = Variable<String>(platformCategory.value);
    }
    if (reportingStatus.present) {
      map['reporting_status'] = Variable<String>(reportingStatus.value);
    }
    if (observingNetwork.present) {
      map['observing_network'] = Variable<String>(observingNetwork.value);
    }
    if (latestOperationType.present) {
      map['latest_operation_type'] = Variable<String>(
        latestOperationType.value,
      );
    }
    if (latestOperationDate.present) {
      map['latest_operation_date'] = Variable<DateTime>(
        latestOperationDate.value,
      );
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
          ..write('batchRef: $batchRef, ')
          ..write('operationNotes: $operationNotes, ')
          ..write('platformCategory: $platformCategory, ')
          ..write('reportingStatus: $reportingStatus, ')
          ..write('observingNetwork: $observingNetwork, ')
          ..write('latestOperationType: $latestOperationType, ')
          ..write('latestOperationDate: $latestOperationDate')
          ..write(')'))
        .toString();
  }
}

class $UserProfilesTable extends UserProfiles
    with TableInfo<$UserProfilesTable, UserEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _refMeta = const VerificationMeta('ref');
  @override
  late final GeneratedColumn<int> ref = GeneratedColumn<int>(
    'ref',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _email2Meta = const VerificationMeta('email2');
  @override
  late final GeneratedColumn<String> email2 = GeneratedColumn<String>(
    'email2',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fullNameMeta = const VerificationMeta(
    'fullName',
  );
  @override
  late final GeneratedColumn<String> fullName = GeneratedColumn<String>(
    'full_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _firstNameMeta = const VerificationMeta(
    'firstName',
  );
  @override
  late final GeneratedColumn<String> firstName = GeneratedColumn<String>(
    'first_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastNameMeta = const VerificationMeta(
    'lastName',
  );
  @override
  late final GeneratedColumn<String> lastName = GeneratedColumn<String>(
    'last_name',
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
  static const VerificationMeta _orcidMeta = const VerificationMeta('orcid');
  @override
  late final GeneratedColumn<String> orcid = GeneratedColumn<String>(
    'orcid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _telMeta = const VerificationMeta('tel');
  @override
  late final GeneratedColumn<String> tel = GeneratedColumn<String>(
    'tel',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tel2Meta = const VerificationMeta('tel2');
  @override
  late final GeneratedColumn<String> tel2 = GeneratedColumn<String>(
    'tel2',
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
  static const VerificationMeta _countryMeta = const VerificationMeta(
    'country',
  );
  @override
  late final GeneratedColumn<String> country = GeneratedColumn<String>(
    'country',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _hideContactInfoFromPublicMeta =
      const VerificationMeta('hideContactInfoFromPublic');
  @override
  late final GeneratedColumn<bool> hideContactInfoFromPublic =
      GeneratedColumn<bool>(
        'hide_contact_info_from_public',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: true,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("hide_contact_info_from_public" IN (0, 1))',
        ),
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    ref,
    email,
    email2,
    fullName,
    firstName,
    lastName,
    title,
    orcid,
    tel,
    tel2,
    address,
    country,
    hideContactInfoFromPublic,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_profiles';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserEntity> instance, {
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
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    } else if (isInserting) {
      context.missing(_emailMeta);
    }
    if (data.containsKey('email2')) {
      context.handle(
        _email2Meta,
        email2.isAcceptableOrUnknown(data['email2']!, _email2Meta),
      );
    }
    if (data.containsKey('full_name')) {
      context.handle(
        _fullNameMeta,
        fullName.isAcceptableOrUnknown(data['full_name']!, _fullNameMeta),
      );
    } else if (isInserting) {
      context.missing(_fullNameMeta);
    }
    if (data.containsKey('first_name')) {
      context.handle(
        _firstNameMeta,
        firstName.isAcceptableOrUnknown(data['first_name']!, _firstNameMeta),
      );
    } else if (isInserting) {
      context.missing(_firstNameMeta);
    }
    if (data.containsKey('last_name')) {
      context.handle(
        _lastNameMeta,
        lastName.isAcceptableOrUnknown(data['last_name']!, _lastNameMeta),
      );
    } else if (isInserting) {
      context.missing(_lastNameMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('orcid')) {
      context.handle(
        _orcidMeta,
        orcid.isAcceptableOrUnknown(data['orcid']!, _orcidMeta),
      );
    } else if (isInserting) {
      context.missing(_orcidMeta);
    }
    if (data.containsKey('tel')) {
      context.handle(
        _telMeta,
        tel.isAcceptableOrUnknown(data['tel']!, _telMeta),
      );
    } else if (isInserting) {
      context.missing(_telMeta);
    }
    if (data.containsKey('tel2')) {
      context.handle(
        _tel2Meta,
        tel2.isAcceptableOrUnknown(data['tel2']!, _tel2Meta),
      );
    } else if (isInserting) {
      context.missing(_tel2Meta);
    }
    if (data.containsKey('address')) {
      context.handle(
        _addressMeta,
        address.isAcceptableOrUnknown(data['address']!, _addressMeta),
      );
    } else if (isInserting) {
      context.missing(_addressMeta);
    }
    if (data.containsKey('country')) {
      context.handle(
        _countryMeta,
        country.isAcceptableOrUnknown(data['country']!, _countryMeta),
      );
    }
    if (data.containsKey('hide_contact_info_from_public')) {
      context.handle(
        _hideContactInfoFromPublicMeta,
        hideContactInfoFromPublic.isAcceptableOrUnknown(
          data['hide_contact_info_from_public']!,
          _hideContactInfoFromPublicMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_hideContactInfoFromPublicMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserEntity(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      ref: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ref'],
      )!,
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      )!,
      email2: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email2'],
      ),
      fullName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}full_name'],
      )!,
      firstName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}first_name'],
      )!,
      lastName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_name'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      orcid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}orcid'],
      )!,
      tel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tel'],
      )!,
      tel2: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tel2'],
      )!,
      address: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}address'],
      )!,
      country: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}country'],
      ),
      hideContactInfoFromPublic: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}hide_contact_info_from_public'],
      )!,
    );
  }

  @override
  $UserProfilesTable createAlias(String alias) {
    return $UserProfilesTable(attachedDatabase, alias);
  }
}

class UserEntity extends DataClass implements Insertable<UserEntity> {
  /// Primary key identifying the record.
  final int id;

  /// External reference (ID) from server.
  final int ref;

  /// User's primary email.
  final String email;

  /// User's secondary email.
  final String? email2;

  /// User's full name.
  final String fullName;

  /// User's first name.
  final String firstName;

  /// User's last name.
  final String lastName;

  /// User's title.
  final String title;

  /// User's ORCID.
  final String orcid;

  /// User's primary phone number.
  final String tel;

  /// User's secondary phone number.
  final String tel2;

  /// User's postal address
  final String address;

  /// User's country.
  final String? country;

  /// Whether user's contact information should be hidden.
  final bool hideContactInfoFromPublic;
  const UserEntity({
    required this.id,
    required this.ref,
    required this.email,
    this.email2,
    required this.fullName,
    required this.firstName,
    required this.lastName,
    required this.title,
    required this.orcid,
    required this.tel,
    required this.tel2,
    required this.address,
    this.country,
    required this.hideContactInfoFromPublic,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['ref'] = Variable<int>(ref);
    map['email'] = Variable<String>(email);
    if (!nullToAbsent || email2 != null) {
      map['email2'] = Variable<String>(email2);
    }
    map['full_name'] = Variable<String>(fullName);
    map['first_name'] = Variable<String>(firstName);
    map['last_name'] = Variable<String>(lastName);
    map['title'] = Variable<String>(title);
    map['orcid'] = Variable<String>(orcid);
    map['tel'] = Variable<String>(tel);
    map['tel2'] = Variable<String>(tel2);
    map['address'] = Variable<String>(address);
    if (!nullToAbsent || country != null) {
      map['country'] = Variable<String>(country);
    }
    map['hide_contact_info_from_public'] = Variable<bool>(
      hideContactInfoFromPublic,
    );
    return map;
  }

  UserProfilesCompanion toCompanion(bool nullToAbsent) {
    return UserProfilesCompanion(
      id: Value(id),
      ref: Value(ref),
      email: Value(email),
      email2: email2 == null && nullToAbsent
          ? const Value.absent()
          : Value(email2),
      fullName: Value(fullName),
      firstName: Value(firstName),
      lastName: Value(lastName),
      title: Value(title),
      orcid: Value(orcid),
      tel: Value(tel),
      tel2: Value(tel2),
      address: Value(address),
      country: country == null && nullToAbsent
          ? const Value.absent()
          : Value(country),
      hideContactInfoFromPublic: Value(hideContactInfoFromPublic),
    );
  }

  factory UserEntity.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserEntity(
      id: serializer.fromJson<int>(json['id']),
      ref: serializer.fromJson<int>(json['ref']),
      email: serializer.fromJson<String>(json['email']),
      email2: serializer.fromJson<String?>(json['email2']),
      fullName: serializer.fromJson<String>(json['fullName']),
      firstName: serializer.fromJson<String>(json['firstName']),
      lastName: serializer.fromJson<String>(json['lastName']),
      title: serializer.fromJson<String>(json['title']),
      orcid: serializer.fromJson<String>(json['orcid']),
      tel: serializer.fromJson<String>(json['tel']),
      tel2: serializer.fromJson<String>(json['tel2']),
      address: serializer.fromJson<String>(json['address']),
      country: serializer.fromJson<String?>(json['country']),
      hideContactInfoFromPublic: serializer.fromJson<bool>(
        json['hideContactInfoFromPublic'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'ref': serializer.toJson<int>(ref),
      'email': serializer.toJson<String>(email),
      'email2': serializer.toJson<String?>(email2),
      'fullName': serializer.toJson<String>(fullName),
      'firstName': serializer.toJson<String>(firstName),
      'lastName': serializer.toJson<String>(lastName),
      'title': serializer.toJson<String>(title),
      'orcid': serializer.toJson<String>(orcid),
      'tel': serializer.toJson<String>(tel),
      'tel2': serializer.toJson<String>(tel2),
      'address': serializer.toJson<String>(address),
      'country': serializer.toJson<String?>(country),
      'hideContactInfoFromPublic': serializer.toJson<bool>(
        hideContactInfoFromPublic,
      ),
    };
  }

  UserEntity copyWith({
    int? id,
    int? ref,
    String? email,
    Value<String?> email2 = const Value.absent(),
    String? fullName,
    String? firstName,
    String? lastName,
    String? title,
    String? orcid,
    String? tel,
    String? tel2,
    String? address,
    Value<String?> country = const Value.absent(),
    bool? hideContactInfoFromPublic,
  }) => UserEntity(
    id: id ?? this.id,
    ref: ref ?? this.ref,
    email: email ?? this.email,
    email2: email2.present ? email2.value : this.email2,
    fullName: fullName ?? this.fullName,
    firstName: firstName ?? this.firstName,
    lastName: lastName ?? this.lastName,
    title: title ?? this.title,
    orcid: orcid ?? this.orcid,
    tel: tel ?? this.tel,
    tel2: tel2 ?? this.tel2,
    address: address ?? this.address,
    country: country.present ? country.value : this.country,
    hideContactInfoFromPublic:
        hideContactInfoFromPublic ?? this.hideContactInfoFromPublic,
  );
  UserEntity copyWithCompanion(UserProfilesCompanion data) {
    return UserEntity(
      id: data.id.present ? data.id.value : this.id,
      ref: data.ref.present ? data.ref.value : this.ref,
      email: data.email.present ? data.email.value : this.email,
      email2: data.email2.present ? data.email2.value : this.email2,
      fullName: data.fullName.present ? data.fullName.value : this.fullName,
      firstName: data.firstName.present ? data.firstName.value : this.firstName,
      lastName: data.lastName.present ? data.lastName.value : this.lastName,
      title: data.title.present ? data.title.value : this.title,
      orcid: data.orcid.present ? data.orcid.value : this.orcid,
      tel: data.tel.present ? data.tel.value : this.tel,
      tel2: data.tel2.present ? data.tel2.value : this.tel2,
      address: data.address.present ? data.address.value : this.address,
      country: data.country.present ? data.country.value : this.country,
      hideContactInfoFromPublic: data.hideContactInfoFromPublic.present
          ? data.hideContactInfoFromPublic.value
          : this.hideContactInfoFromPublic,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserEntity(')
          ..write('id: $id, ')
          ..write('ref: $ref, ')
          ..write('email: $email, ')
          ..write('email2: $email2, ')
          ..write('fullName: $fullName, ')
          ..write('firstName: $firstName, ')
          ..write('lastName: $lastName, ')
          ..write('title: $title, ')
          ..write('orcid: $orcid, ')
          ..write('tel: $tel, ')
          ..write('tel2: $tel2, ')
          ..write('address: $address, ')
          ..write('country: $country, ')
          ..write('hideContactInfoFromPublic: $hideContactInfoFromPublic')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    ref,
    email,
    email2,
    fullName,
    firstName,
    lastName,
    title,
    orcid,
    tel,
    tel2,
    address,
    country,
    hideContactInfoFromPublic,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserEntity &&
          other.id == this.id &&
          other.ref == this.ref &&
          other.email == this.email &&
          other.email2 == this.email2 &&
          other.fullName == this.fullName &&
          other.firstName == this.firstName &&
          other.lastName == this.lastName &&
          other.title == this.title &&
          other.orcid == this.orcid &&
          other.tel == this.tel &&
          other.tel2 == this.tel2 &&
          other.address == this.address &&
          other.country == this.country &&
          other.hideContactInfoFromPublic == this.hideContactInfoFromPublic);
}

class UserProfilesCompanion extends UpdateCompanion<UserEntity> {
  final Value<int> id;
  final Value<int> ref;
  final Value<String> email;
  final Value<String?> email2;
  final Value<String> fullName;
  final Value<String> firstName;
  final Value<String> lastName;
  final Value<String> title;
  final Value<String> orcid;
  final Value<String> tel;
  final Value<String> tel2;
  final Value<String> address;
  final Value<String?> country;
  final Value<bool> hideContactInfoFromPublic;
  const UserProfilesCompanion({
    this.id = const Value.absent(),
    this.ref = const Value.absent(),
    this.email = const Value.absent(),
    this.email2 = const Value.absent(),
    this.fullName = const Value.absent(),
    this.firstName = const Value.absent(),
    this.lastName = const Value.absent(),
    this.title = const Value.absent(),
    this.orcid = const Value.absent(),
    this.tel = const Value.absent(),
    this.tel2 = const Value.absent(),
    this.address = const Value.absent(),
    this.country = const Value.absent(),
    this.hideContactInfoFromPublic = const Value.absent(),
  });
  UserProfilesCompanion.insert({
    this.id = const Value.absent(),
    required int ref,
    required String email,
    this.email2 = const Value.absent(),
    required String fullName,
    required String firstName,
    required String lastName,
    required String title,
    required String orcid,
    required String tel,
    required String tel2,
    required String address,
    this.country = const Value.absent(),
    required bool hideContactInfoFromPublic,
  }) : ref = Value(ref),
       email = Value(email),
       fullName = Value(fullName),
       firstName = Value(firstName),
       lastName = Value(lastName),
       title = Value(title),
       orcid = Value(orcid),
       tel = Value(tel),
       tel2 = Value(tel2),
       address = Value(address),
       hideContactInfoFromPublic = Value(hideContactInfoFromPublic);
  static Insertable<UserEntity> custom({
    Expression<int>? id,
    Expression<int>? ref,
    Expression<String>? email,
    Expression<String>? email2,
    Expression<String>? fullName,
    Expression<String>? firstName,
    Expression<String>? lastName,
    Expression<String>? title,
    Expression<String>? orcid,
    Expression<String>? tel,
    Expression<String>? tel2,
    Expression<String>? address,
    Expression<String>? country,
    Expression<bool>? hideContactInfoFromPublic,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ref != null) 'ref': ref,
      if (email != null) 'email': email,
      if (email2 != null) 'email2': email2,
      if (fullName != null) 'full_name': fullName,
      if (firstName != null) 'first_name': firstName,
      if (lastName != null) 'last_name': lastName,
      if (title != null) 'title': title,
      if (orcid != null) 'orcid': orcid,
      if (tel != null) 'tel': tel,
      if (tel2 != null) 'tel2': tel2,
      if (address != null) 'address': address,
      if (country != null) 'country': country,
      if (hideContactInfoFromPublic != null)
        'hide_contact_info_from_public': hideContactInfoFromPublic,
    });
  }

  UserProfilesCompanion copyWith({
    Value<int>? id,
    Value<int>? ref,
    Value<String>? email,
    Value<String?>? email2,
    Value<String>? fullName,
    Value<String>? firstName,
    Value<String>? lastName,
    Value<String>? title,
    Value<String>? orcid,
    Value<String>? tel,
    Value<String>? tel2,
    Value<String>? address,
    Value<String?>? country,
    Value<bool>? hideContactInfoFromPublic,
  }) {
    return UserProfilesCompanion(
      id: id ?? this.id,
      ref: ref ?? this.ref,
      email: email ?? this.email,
      email2: email2 ?? this.email2,
      fullName: fullName ?? this.fullName,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      title: title ?? this.title,
      orcid: orcid ?? this.orcid,
      tel: tel ?? this.tel,
      tel2: tel2 ?? this.tel2,
      address: address ?? this.address,
      country: country ?? this.country,
      hideContactInfoFromPublic:
          hideContactInfoFromPublic ?? this.hideContactInfoFromPublic,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (ref.present) {
      map['ref'] = Variable<int>(ref.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (email2.present) {
      map['email2'] = Variable<String>(email2.value);
    }
    if (fullName.present) {
      map['full_name'] = Variable<String>(fullName.value);
    }
    if (firstName.present) {
      map['first_name'] = Variable<String>(firstName.value);
    }
    if (lastName.present) {
      map['last_name'] = Variable<String>(lastName.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (orcid.present) {
      map['orcid'] = Variable<String>(orcid.value);
    }
    if (tel.present) {
      map['tel'] = Variable<String>(tel.value);
    }
    if (tel2.present) {
      map['tel2'] = Variable<String>(tel2.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (country.present) {
      map['country'] = Variable<String>(country.value);
    }
    if (hideContactInfoFromPublic.present) {
      map['hide_contact_info_from_public'] = Variable<bool>(
        hideContactInfoFromPublic.value,
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserProfilesCompanion(')
          ..write('id: $id, ')
          ..write('ref: $ref, ')
          ..write('email: $email, ')
          ..write('email2: $email2, ')
          ..write('fullName: $fullName, ')
          ..write('firstName: $firstName, ')
          ..write('lastName: $lastName, ')
          ..write('title: $title, ')
          ..write('orcid: $orcid, ')
          ..write('tel: $tel, ')
          ..write('tel2: $tel2, ')
          ..write('address: $address, ')
          ..write('country: $country, ')
          ..write('hideContactInfoFromPublic: $hideContactInfoFromPublic')
          ..write(')'))
        .toString();
  }
}

class $ProgramsTable extends Programs
    with TableInfo<$ProgramsTable, ProgramEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProgramsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
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
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, code];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'programs';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProgramEntity> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('code')) {
      context.handle(
        _codeMeta,
        code.isAcceptableOrUnknown(data['code']!, _codeMeta),
      );
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProgramEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProgramEntity(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      code: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code'],
      )!,
    );
  }

  @override
  $ProgramsTable createAlias(String alias) {
    return $ProgramsTable(attachedDatabase, alias);
  }
}

class ProgramEntity extends DataClass implements Insertable<ProgramEntity> {
  /// Program reference
  final int id;

  /// Program display name
  final String name;

  /// Program slug
  final String code;
  const ProgramEntity({
    required this.id,
    required this.name,
    required this.code,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['code'] = Variable<String>(code);
    return map;
  }

  ProgramsCompanion toCompanion(bool nullToAbsent) {
    return ProgramsCompanion(
      id: Value(id),
      name: Value(name),
      code: Value(code),
    );
  }

  factory ProgramEntity.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProgramEntity(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      code: serializer.fromJson<String>(json['code']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'code': serializer.toJson<String>(code),
    };
  }

  ProgramEntity copyWith({int? id, String? name, String? code}) =>
      ProgramEntity(
        id: id ?? this.id,
        name: name ?? this.name,
        code: code ?? this.code,
      );
  ProgramEntity copyWithCompanion(ProgramsCompanion data) {
    return ProgramEntity(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      code: data.code.present ? data.code.value : this.code,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProgramEntity(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('code: $code')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, code);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProgramEntity &&
          other.id == this.id &&
          other.name == this.name &&
          other.code == this.code);
}

class ProgramsCompanion extends UpdateCompanion<ProgramEntity> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> code;
  const ProgramsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.code = const Value.absent(),
  });
  ProgramsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String code,
  }) : name = Value(name),
       code = Value(code);
  static Insertable<ProgramEntity> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? code,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (code != null) 'code': code,
    });
  }

  ProgramsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? code,
  }) {
    return ProgramsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProgramsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('code: $code')
          ..write(')'))
        .toString();
  }
}

class $RolesTable extends Roles with TableInfo<$RolesTable, RoleEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RolesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
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
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, code];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'roles';
  @override
  VerificationContext validateIntegrity(
    Insertable<RoleEntity> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('code')) {
      context.handle(
        _codeMeta,
        code.isAcceptableOrUnknown(data['code']!, _codeMeta),
      );
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RoleEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RoleEntity(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      code: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code'],
      )!,
    );
  }

  @override
  $RolesTable createAlias(String alias) {
    return $RolesTable(attachedDatabase, alias);
  }
}

class RoleEntity extends DataClass implements Insertable<RoleEntity> {
  /// Role reference
  final int id;

  /// Role display name
  final String name;

  /// Role slug
  final String code;
  const RoleEntity({required this.id, required this.name, required this.code});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['code'] = Variable<String>(code);
    return map;
  }

  RolesCompanion toCompanion(bool nullToAbsent) {
    return RolesCompanion(id: Value(id), name: Value(name), code: Value(code));
  }

  factory RoleEntity.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RoleEntity(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      code: serializer.fromJson<String>(json['code']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'code': serializer.toJson<String>(code),
    };
  }

  RoleEntity copyWith({int? id, String? name, String? code}) => RoleEntity(
    id: id ?? this.id,
    name: name ?? this.name,
    code: code ?? this.code,
  );
  RoleEntity copyWithCompanion(RolesCompanion data) {
    return RoleEntity(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      code: data.code.present ? data.code.value : this.code,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RoleEntity(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('code: $code')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, code);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RoleEntity &&
          other.id == this.id &&
          other.name == this.name &&
          other.code == this.code);
}

class RolesCompanion extends UpdateCompanion<RoleEntity> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> code;
  const RolesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.code = const Value.absent(),
  });
  RolesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String code,
  }) : name = Value(name),
       code = Value(code);
  static Insertable<RoleEntity> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? code,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (code != null) 'code': code,
    });
  }

  RolesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? code,
  }) {
    return RolesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RolesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('code: $code')
          ..write(')'))
        .toString();
  }
}

class $UserProgramRolesTable extends UserProgramRoles
    with TableInfo<$UserProgramRolesTable, UserProgramRole> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserProgramRolesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<int> userId = GeneratedColumn<int>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES user_profiles (id)',
    ),
  );
  static const VerificationMeta _programIdMeta = const VerificationMeta(
    'programId',
  );
  @override
  late final GeneratedColumn<int> programId = GeneratedColumn<int>(
    'program_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES programs (id)',
    ),
  );
  static const VerificationMeta _roleIdMeta = const VerificationMeta('roleId');
  @override
  late final GeneratedColumn<int> roleId = GeneratedColumn<int>(
    'role_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES roles (id)',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [userId, programId, roleId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_program_roles';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserProgramRole> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('program_id')) {
      context.handle(
        _programIdMeta,
        programId.isAcceptableOrUnknown(data['program_id']!, _programIdMeta),
      );
    } else if (isInserting) {
      context.missing(_programIdMeta);
    }
    if (data.containsKey('role_id')) {
      context.handle(
        _roleIdMeta,
        roleId.isAcceptableOrUnknown(data['role_id']!, _roleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_roleIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {userId, programId, roleId};
  @override
  UserProgramRole map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserProgramRole(
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}user_id'],
      )!,
      programId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}program_id'],
      )!,
      roleId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}role_id'],
      )!,
    );
  }

  @override
  $UserProgramRolesTable createAlias(String alias) {
    return $UserProgramRolesTable(attachedDatabase, alias);
  }
}

class UserProgramRole extends DataClass implements Insertable<UserProgramRole> {
  /// User identifier (foreign key)
  final int userId;

  /// Program identifier (foreign key)
  final int programId;

  /// Role identifier (foreign key)
  final int roleId;
  const UserProgramRole({
    required this.userId,
    required this.programId,
    required this.roleId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['user_id'] = Variable<int>(userId);
    map['program_id'] = Variable<int>(programId);
    map['role_id'] = Variable<int>(roleId);
    return map;
  }

  UserProgramRolesCompanion toCompanion(bool nullToAbsent) {
    return UserProgramRolesCompanion(
      userId: Value(userId),
      programId: Value(programId),
      roleId: Value(roleId),
    );
  }

  factory UserProgramRole.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserProgramRole(
      userId: serializer.fromJson<int>(json['userId']),
      programId: serializer.fromJson<int>(json['programId']),
      roleId: serializer.fromJson<int>(json['roleId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'userId': serializer.toJson<int>(userId),
      'programId': serializer.toJson<int>(programId),
      'roleId': serializer.toJson<int>(roleId),
    };
  }

  UserProgramRole copyWith({int? userId, int? programId, int? roleId}) =>
      UserProgramRole(
        userId: userId ?? this.userId,
        programId: programId ?? this.programId,
        roleId: roleId ?? this.roleId,
      );
  UserProgramRole copyWithCompanion(UserProgramRolesCompanion data) {
    return UserProgramRole(
      userId: data.userId.present ? data.userId.value : this.userId,
      programId: data.programId.present ? data.programId.value : this.programId,
      roleId: data.roleId.present ? data.roleId.value : this.roleId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserProgramRole(')
          ..write('userId: $userId, ')
          ..write('programId: $programId, ')
          ..write('roleId: $roleId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(userId, programId, roleId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserProgramRole &&
          other.userId == this.userId &&
          other.programId == this.programId &&
          other.roleId == this.roleId);
}

class UserProgramRolesCompanion extends UpdateCompanion<UserProgramRole> {
  final Value<int> userId;
  final Value<int> programId;
  final Value<int> roleId;
  final Value<int> rowid;
  const UserProgramRolesCompanion({
    this.userId = const Value.absent(),
    this.programId = const Value.absent(),
    this.roleId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserProgramRolesCompanion.insert({
    required int userId,
    required int programId,
    required int roleId,
    this.rowid = const Value.absent(),
  }) : userId = Value(userId),
       programId = Value(programId),
       roleId = Value(roleId);
  static Insertable<UserProgramRole> custom({
    Expression<int>? userId,
    Expression<int>? programId,
    Expression<int>? roleId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (userId != null) 'user_id': userId,
      if (programId != null) 'program_id': programId,
      if (roleId != null) 'role_id': roleId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserProgramRolesCompanion copyWith({
    Value<int>? userId,
    Value<int>? programId,
    Value<int>? roleId,
    Value<int>? rowid,
  }) {
    return UserProgramRolesCompanion(
      userId: userId ?? this.userId,
      programId: programId ?? this.programId,
      roleId: roleId ?? this.roleId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (userId.present) {
      map['user_id'] = Variable<int>(userId.value);
    }
    if (programId.present) {
      map['program_id'] = Variable<int>(programId.value);
    }
    if (roleId.present) {
      map['role_id'] = Variable<int>(roleId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserProgramRolesCompanion(')
          ..write('userId: $userId, ')
          ..write('programId: $programId, ')
          ..write('roleId: $roleId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UserRolesTable extends UserRoles
    with TableInfo<$UserRolesTable, UserRole> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserRolesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<int> userId = GeneratedColumn<int>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES user_profiles (id)',
    ),
  );
  static const VerificationMeta _roleCodeMeta = const VerificationMeta(
    'roleCode',
  );
  @override
  late final GeneratedColumn<String> roleCode = GeneratedColumn<String>(
    'role_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [userId, roleCode];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_roles';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserRole> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('role_code')) {
      context.handle(
        _roleCodeMeta,
        roleCode.isAcceptableOrUnknown(data['role_code']!, _roleCodeMeta),
      );
    } else if (isInserting) {
      context.missing(_roleCodeMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {userId, roleCode};
  @override
  UserRole map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserRole(
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}user_id'],
      )!,
      roleCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role_code'],
      )!,
    );
  }

  @override
  $UserRolesTable createAlias(String alias) {
    return $UserRolesTable(attachedDatabase, alias);
  }
}

class UserRole extends DataClass implements Insertable<UserRole> {
  /// User identifier (foreign key)
  final int userId;

  /// Role code, e.g. "alert_editor"
  final String roleCode;
  const UserRole({required this.userId, required this.roleCode});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['user_id'] = Variable<int>(userId);
    map['role_code'] = Variable<String>(roleCode);
    return map;
  }

  UserRolesCompanion toCompanion(bool nullToAbsent) {
    return UserRolesCompanion(userId: Value(userId), roleCode: Value(roleCode));
  }

  factory UserRole.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserRole(
      userId: serializer.fromJson<int>(json['userId']),
      roleCode: serializer.fromJson<String>(json['roleCode']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'userId': serializer.toJson<int>(userId),
      'roleCode': serializer.toJson<String>(roleCode),
    };
  }

  UserRole copyWith({int? userId, String? roleCode}) => UserRole(
    userId: userId ?? this.userId,
    roleCode: roleCode ?? this.roleCode,
  );
  UserRole copyWithCompanion(UserRolesCompanion data) {
    return UserRole(
      userId: data.userId.present ? data.userId.value : this.userId,
      roleCode: data.roleCode.present ? data.roleCode.value : this.roleCode,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserRole(')
          ..write('userId: $userId, ')
          ..write('roleCode: $roleCode')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(userId, roleCode);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserRole &&
          other.userId == this.userId &&
          other.roleCode == this.roleCode);
}

class UserRolesCompanion extends UpdateCompanion<UserRole> {
  final Value<int> userId;
  final Value<String> roleCode;
  final Value<int> rowid;
  const UserRolesCompanion({
    this.userId = const Value.absent(),
    this.roleCode = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserRolesCompanion.insert({
    required int userId,
    required String roleCode,
    this.rowid = const Value.absent(),
  }) : userId = Value(userId),
       roleCode = Value(roleCode);
  static Insertable<UserRole> custom({
    Expression<int>? userId,
    Expression<String>? roleCode,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (userId != null) 'user_id': userId,
      if (roleCode != null) 'role_code': roleCode,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserRolesCompanion copyWith({
    Value<int>? userId,
    Value<String>? roleCode,
    Value<int>? rowid,
  }) {
    return UserRolesCompanion(
      userId: userId ?? this.userId,
      roleCode: roleCode ?? this.roleCode,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (userId.present) {
      map['user_id'] = Variable<int>(userId.value);
    }
    if (roleCode.present) {
      map['role_code'] = Variable<String>(roleCode.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserRolesCompanion(')
          ..write('userId: $userId, ')
          ..write('roleCode: $roleCode, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $PlatformsTable platforms = $PlatformsTable(this);
  late final $UserProfilesTable userProfiles = $UserProfilesTable(this);
  late final $ProgramsTable programs = $ProgramsTable(this);
  late final $RolesTable roles = $RolesTable(this);
  late final $UserProgramRolesTable userProgramRoles = $UserProgramRolesTable(
    this,
  );
  late final $UserRolesTable userRoles = $UserRolesTable(this);
  late final AuthDao authDao = AuthDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    platforms,
    userProfiles,
    programs,
    roles,
    userProgramRoles,
    userRoles,
  ];
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
      Value<String?> operationNotes,
      Value<String?> platformCategory,
      Value<String?> reportingStatus,
      Value<String?> observingNetwork,
      Value<String?> latestOperationType,
      Value<DateTime?> latestOperationDate,
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
      Value<String?> operationNotes,
      Value<String?> platformCategory,
      Value<String?> reportingStatus,
      Value<String?> observingNetwork,
      Value<String?> latestOperationType,
      Value<DateTime?> latestOperationDate,
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

  ColumnFilters<String> get operationNotes => $composableBuilder(
    column: $table.operationNotes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get platformCategory => $composableBuilder(
    column: $table.platformCategory,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reportingStatus => $composableBuilder(
    column: $table.reportingStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get observingNetwork => $composableBuilder(
    column: $table.observingNetwork,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get latestOperationType => $composableBuilder(
    column: $table.latestOperationType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get latestOperationDate => $composableBuilder(
    column: $table.latestOperationDate,
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

  ColumnOrderings<String> get operationNotes => $composableBuilder(
    column: $table.operationNotes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get platformCategory => $composableBuilder(
    column: $table.platformCategory,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reportingStatus => $composableBuilder(
    column: $table.reportingStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get observingNetwork => $composableBuilder(
    column: $table.observingNetwork,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get latestOperationType => $composableBuilder(
    column: $table.latestOperationType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get latestOperationDate => $composableBuilder(
    column: $table.latestOperationDate,
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

  GeneratedColumn<String> get operationNotes => $composableBuilder(
    column: $table.operationNotes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get platformCategory => $composableBuilder(
    column: $table.platformCategory,
    builder: (column) => column,
  );

  GeneratedColumn<String> get reportingStatus => $composableBuilder(
    column: $table.reportingStatus,
    builder: (column) => column,
  );

  GeneratedColumn<String> get observingNetwork => $composableBuilder(
    column: $table.observingNetwork,
    builder: (column) => column,
  );

  GeneratedColumn<String> get latestOperationType => $composableBuilder(
    column: $table.latestOperationType,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get latestOperationDate => $composableBuilder(
    column: $table.latestOperationDate,
    builder: (column) => column,
  );
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
                Value<String?> operationNotes = const Value.absent(),
                Value<String?> platformCategory = const Value.absent(),
                Value<String?> reportingStatus = const Value.absent(),
                Value<String?> observingNetwork = const Value.absent(),
                Value<String?> latestOperationType = const Value.absent(),
                Value<DateTime?> latestOperationDate = const Value.absent(),
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
                operationNotes: operationNotes,
                platformCategory: platformCategory,
                reportingStatus: reportingStatus,
                observingNetwork: observingNetwork,
                latestOperationType: latestOperationType,
                latestOperationDate: latestOperationDate,
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
                Value<String?> operationNotes = const Value.absent(),
                Value<String?> platformCategory = const Value.absent(),
                Value<String?> reportingStatus = const Value.absent(),
                Value<String?> observingNetwork = const Value.absent(),
                Value<String?> latestOperationType = const Value.absent(),
                Value<DateTime?> latestOperationDate = const Value.absent(),
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
                operationNotes: operationNotes,
                platformCategory: platformCategory,
                reportingStatus: reportingStatus,
                observingNetwork: observingNetwork,
                latestOperationType: latestOperationType,
                latestOperationDate: latestOperationDate,
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
typedef $$UserProfilesTableCreateCompanionBuilder =
    UserProfilesCompanion Function({
      Value<int> id,
      required int ref,
      required String email,
      Value<String?> email2,
      required String fullName,
      required String firstName,
      required String lastName,
      required String title,
      required String orcid,
      required String tel,
      required String tel2,
      required String address,
      Value<String?> country,
      required bool hideContactInfoFromPublic,
    });
typedef $$UserProfilesTableUpdateCompanionBuilder =
    UserProfilesCompanion Function({
      Value<int> id,
      Value<int> ref,
      Value<String> email,
      Value<String?> email2,
      Value<String> fullName,
      Value<String> firstName,
      Value<String> lastName,
      Value<String> title,
      Value<String> orcid,
      Value<String> tel,
      Value<String> tel2,
      Value<String> address,
      Value<String?> country,
      Value<bool> hideContactInfoFromPublic,
    });

final class $$UserProfilesTableReferences
    extends BaseReferences<_$AppDatabase, $UserProfilesTable, UserEntity> {
  $$UserProfilesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$UserProgramRolesTable, List<UserProgramRole>>
  _userProgramRolesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.userProgramRoles,
    aliasName: $_aliasNameGenerator(
      db.userProfiles.id,
      db.userProgramRoles.userId,
    ),
  );

  $$UserProgramRolesTableProcessedTableManager get userProgramRolesRefs {
    final manager = $$UserProgramRolesTableTableManager(
      $_db,
      $_db.userProgramRoles,
    ).filter((f) => f.userId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _userProgramRolesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$UserRolesTable, List<UserRole>>
  _userRolesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.userRoles,
    aliasName: $_aliasNameGenerator(db.userProfiles.id, db.userRoles.userId),
  );

  $$UserRolesTableProcessedTableManager get userRolesRefs {
    final manager = $$UserRolesTableTableManager(
      $_db,
      $_db.userRoles,
    ).filter((f) => f.userId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_userRolesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$UserProfilesTableFilterComposer
    extends Composer<_$AppDatabase, $UserProfilesTable> {
  $$UserProfilesTableFilterComposer({
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

  ColumnFilters<int> get ref => $composableBuilder(
    column: $table.ref,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email2 => $composableBuilder(
    column: $table.email2,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fullName => $composableBuilder(
    column: $table.fullName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get firstName => $composableBuilder(
    column: $table.firstName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastName => $composableBuilder(
    column: $table.lastName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get orcid => $composableBuilder(
    column: $table.orcid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tel => $composableBuilder(
    column: $table.tel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tel2 => $composableBuilder(
    column: $table.tel2,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get country => $composableBuilder(
    column: $table.country,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get hideContactInfoFromPublic => $composableBuilder(
    column: $table.hideContactInfoFromPublic,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> userProgramRolesRefs(
    Expression<bool> Function($$UserProgramRolesTableFilterComposer f) f,
  ) {
    final $$UserProgramRolesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.userProgramRoles,
      getReferencedColumn: (t) => t.userId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserProgramRolesTableFilterComposer(
            $db: $db,
            $table: $db.userProgramRoles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> userRolesRefs(
    Expression<bool> Function($$UserRolesTableFilterComposer f) f,
  ) {
    final $$UserRolesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.userRoles,
      getReferencedColumn: (t) => t.userId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserRolesTableFilterComposer(
            $db: $db,
            $table: $db.userRoles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$UserProfilesTableOrderingComposer
    extends Composer<_$AppDatabase, $UserProfilesTable> {
  $$UserProfilesTableOrderingComposer({
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

  ColumnOrderings<int> get ref => $composableBuilder(
    column: $table.ref,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email2 => $composableBuilder(
    column: $table.email2,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fullName => $composableBuilder(
    column: $table.fullName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get firstName => $composableBuilder(
    column: $table.firstName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastName => $composableBuilder(
    column: $table.lastName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get orcid => $composableBuilder(
    column: $table.orcid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tel => $composableBuilder(
    column: $table.tel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tel2 => $composableBuilder(
    column: $table.tel2,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get country => $composableBuilder(
    column: $table.country,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get hideContactInfoFromPublic => $composableBuilder(
    column: $table.hideContactInfoFromPublic,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UserProfilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserProfilesTable> {
  $$UserProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get ref =>
      $composableBuilder(column: $table.ref, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get email2 =>
      $composableBuilder(column: $table.email2, builder: (column) => column);

  GeneratedColumn<String> get fullName =>
      $composableBuilder(column: $table.fullName, builder: (column) => column);

  GeneratedColumn<String> get firstName =>
      $composableBuilder(column: $table.firstName, builder: (column) => column);

  GeneratedColumn<String> get lastName =>
      $composableBuilder(column: $table.lastName, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get orcid =>
      $composableBuilder(column: $table.orcid, builder: (column) => column);

  GeneratedColumn<String> get tel =>
      $composableBuilder(column: $table.tel, builder: (column) => column);

  GeneratedColumn<String> get tel2 =>
      $composableBuilder(column: $table.tel2, builder: (column) => column);

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<String> get country =>
      $composableBuilder(column: $table.country, builder: (column) => column);

  GeneratedColumn<bool> get hideContactInfoFromPublic => $composableBuilder(
    column: $table.hideContactInfoFromPublic,
    builder: (column) => column,
  );

  Expression<T> userProgramRolesRefs<T extends Object>(
    Expression<T> Function($$UserProgramRolesTableAnnotationComposer a) f,
  ) {
    final $$UserProgramRolesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.userProgramRoles,
      getReferencedColumn: (t) => t.userId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserProgramRolesTableAnnotationComposer(
            $db: $db,
            $table: $db.userProgramRoles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> userRolesRefs<T extends Object>(
    Expression<T> Function($$UserRolesTableAnnotationComposer a) f,
  ) {
    final $$UserRolesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.userRoles,
      getReferencedColumn: (t) => t.userId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserRolesTableAnnotationComposer(
            $db: $db,
            $table: $db.userRoles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$UserProfilesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UserProfilesTable,
          UserEntity,
          $$UserProfilesTableFilterComposer,
          $$UserProfilesTableOrderingComposer,
          $$UserProfilesTableAnnotationComposer,
          $$UserProfilesTableCreateCompanionBuilder,
          $$UserProfilesTableUpdateCompanionBuilder,
          (UserEntity, $$UserProfilesTableReferences),
          UserEntity,
          PrefetchHooks Function({
            bool userProgramRolesRefs,
            bool userRolesRefs,
          })
        > {
  $$UserProfilesTableTableManager(_$AppDatabase db, $UserProfilesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> ref = const Value.absent(),
                Value<String> email = const Value.absent(),
                Value<String?> email2 = const Value.absent(),
                Value<String> fullName = const Value.absent(),
                Value<String> firstName = const Value.absent(),
                Value<String> lastName = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> orcid = const Value.absent(),
                Value<String> tel = const Value.absent(),
                Value<String> tel2 = const Value.absent(),
                Value<String> address = const Value.absent(),
                Value<String?> country = const Value.absent(),
                Value<bool> hideContactInfoFromPublic = const Value.absent(),
              }) => UserProfilesCompanion(
                id: id,
                ref: ref,
                email: email,
                email2: email2,
                fullName: fullName,
                firstName: firstName,
                lastName: lastName,
                title: title,
                orcid: orcid,
                tel: tel,
                tel2: tel2,
                address: address,
                country: country,
                hideContactInfoFromPublic: hideContactInfoFromPublic,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int ref,
                required String email,
                Value<String?> email2 = const Value.absent(),
                required String fullName,
                required String firstName,
                required String lastName,
                required String title,
                required String orcid,
                required String tel,
                required String tel2,
                required String address,
                Value<String?> country = const Value.absent(),
                required bool hideContactInfoFromPublic,
              }) => UserProfilesCompanion.insert(
                id: id,
                ref: ref,
                email: email,
                email2: email2,
                fullName: fullName,
                firstName: firstName,
                lastName: lastName,
                title: title,
                orcid: orcid,
                tel: tel,
                tel2: tel2,
                address: address,
                country: country,
                hideContactInfoFromPublic: hideContactInfoFromPublic,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$UserProfilesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({userProgramRolesRefs = false, userRolesRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (userProgramRolesRefs) db.userProgramRoles,
                    if (userRolesRefs) db.userRoles,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (userProgramRolesRefs)
                        await $_getPrefetchedData<
                          UserEntity,
                          $UserProfilesTable,
                          UserProgramRole
                        >(
                          currentTable: table,
                          referencedTable: $$UserProfilesTableReferences
                              ._userProgramRolesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$UserProfilesTableReferences(
                                db,
                                table,
                                p0,
                              ).userProgramRolesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.userId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (userRolesRefs)
                        await $_getPrefetchedData<
                          UserEntity,
                          $UserProfilesTable,
                          UserRole
                        >(
                          currentTable: table,
                          referencedTable: $$UserProfilesTableReferences
                              ._userRolesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$UserProfilesTableReferences(
                                db,
                                table,
                                p0,
                              ).userRolesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.userId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$UserProfilesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UserProfilesTable,
      UserEntity,
      $$UserProfilesTableFilterComposer,
      $$UserProfilesTableOrderingComposer,
      $$UserProfilesTableAnnotationComposer,
      $$UserProfilesTableCreateCompanionBuilder,
      $$UserProfilesTableUpdateCompanionBuilder,
      (UserEntity, $$UserProfilesTableReferences),
      UserEntity,
      PrefetchHooks Function({bool userProgramRolesRefs, bool userRolesRefs})
    >;
typedef $$ProgramsTableCreateCompanionBuilder =
    ProgramsCompanion Function({
      Value<int> id,
      required String name,
      required String code,
    });
typedef $$ProgramsTableUpdateCompanionBuilder =
    ProgramsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String> code,
    });

final class $$ProgramsTableReferences
    extends BaseReferences<_$AppDatabase, $ProgramsTable, ProgramEntity> {
  $$ProgramsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$UserProgramRolesTable, List<UserProgramRole>>
  _userProgramRolesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.userProgramRoles,
    aliasName: $_aliasNameGenerator(
      db.programs.id,
      db.userProgramRoles.programId,
    ),
  );

  $$UserProgramRolesTableProcessedTableManager get userProgramRolesRefs {
    final manager = $$UserProgramRolesTableTableManager(
      $_db,
      $_db.userProgramRoles,
    ).filter((f) => f.programId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _userProgramRolesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ProgramsTableFilterComposer
    extends Composer<_$AppDatabase, $ProgramsTable> {
  $$ProgramsTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> userProgramRolesRefs(
    Expression<bool> Function($$UserProgramRolesTableFilterComposer f) f,
  ) {
    final $$UserProgramRolesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.userProgramRoles,
      getReferencedColumn: (t) => t.programId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserProgramRolesTableFilterComposer(
            $db: $db,
            $table: $db.userProgramRoles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ProgramsTableOrderingComposer
    extends Composer<_$AppDatabase, $ProgramsTable> {
  $$ProgramsTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProgramsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProgramsTable> {
  $$ProgramsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  Expression<T> userProgramRolesRefs<T extends Object>(
    Expression<T> Function($$UserProgramRolesTableAnnotationComposer a) f,
  ) {
    final $$UserProgramRolesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.userProgramRoles,
      getReferencedColumn: (t) => t.programId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserProgramRolesTableAnnotationComposer(
            $db: $db,
            $table: $db.userProgramRoles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ProgramsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProgramsTable,
          ProgramEntity,
          $$ProgramsTableFilterComposer,
          $$ProgramsTableOrderingComposer,
          $$ProgramsTableAnnotationComposer,
          $$ProgramsTableCreateCompanionBuilder,
          $$ProgramsTableUpdateCompanionBuilder,
          (ProgramEntity, $$ProgramsTableReferences),
          ProgramEntity,
          PrefetchHooks Function({bool userProgramRolesRefs})
        > {
  $$ProgramsTableTableManager(_$AppDatabase db, $ProgramsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProgramsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProgramsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProgramsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> code = const Value.absent(),
              }) => ProgramsCompanion(id: id, name: name, code: code),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required String code,
              }) => ProgramsCompanion.insert(id: id, name: name, code: code),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ProgramsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({userProgramRolesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (userProgramRolesRefs) db.userProgramRoles,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (userProgramRolesRefs)
                    await $_getPrefetchedData<
                      ProgramEntity,
                      $ProgramsTable,
                      UserProgramRole
                    >(
                      currentTable: table,
                      referencedTable: $$ProgramsTableReferences
                          ._userProgramRolesRefsTable(db),
                      managerFromTypedResult: (p0) => $$ProgramsTableReferences(
                        db,
                        table,
                        p0,
                      ).userProgramRolesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.programId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$ProgramsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProgramsTable,
      ProgramEntity,
      $$ProgramsTableFilterComposer,
      $$ProgramsTableOrderingComposer,
      $$ProgramsTableAnnotationComposer,
      $$ProgramsTableCreateCompanionBuilder,
      $$ProgramsTableUpdateCompanionBuilder,
      (ProgramEntity, $$ProgramsTableReferences),
      ProgramEntity,
      PrefetchHooks Function({bool userProgramRolesRefs})
    >;
typedef $$RolesTableCreateCompanionBuilder =
    RolesCompanion Function({
      Value<int> id,
      required String name,
      required String code,
    });
typedef $$RolesTableUpdateCompanionBuilder =
    RolesCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String> code,
    });

final class $$RolesTableReferences
    extends BaseReferences<_$AppDatabase, $RolesTable, RoleEntity> {
  $$RolesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$UserProgramRolesTable, List<UserProgramRole>>
  _userProgramRolesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.userProgramRoles,
    aliasName: $_aliasNameGenerator(db.roles.id, db.userProgramRoles.roleId),
  );

  $$UserProgramRolesTableProcessedTableManager get userProgramRolesRefs {
    final manager = $$UserProgramRolesTableTableManager(
      $_db,
      $_db.userProgramRoles,
    ).filter((f) => f.roleId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _userProgramRolesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$RolesTableFilterComposer extends Composer<_$AppDatabase, $RolesTable> {
  $$RolesTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> userProgramRolesRefs(
    Expression<bool> Function($$UserProgramRolesTableFilterComposer f) f,
  ) {
    final $$UserProgramRolesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.userProgramRoles,
      getReferencedColumn: (t) => t.roleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserProgramRolesTableFilterComposer(
            $db: $db,
            $table: $db.userProgramRoles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RolesTableOrderingComposer
    extends Composer<_$AppDatabase, $RolesTable> {
  $$RolesTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RolesTableAnnotationComposer
    extends Composer<_$AppDatabase, $RolesTable> {
  $$RolesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  Expression<T> userProgramRolesRefs<T extends Object>(
    Expression<T> Function($$UserProgramRolesTableAnnotationComposer a) f,
  ) {
    final $$UserProgramRolesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.userProgramRoles,
      getReferencedColumn: (t) => t.roleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserProgramRolesTableAnnotationComposer(
            $db: $db,
            $table: $db.userProgramRoles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RolesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RolesTable,
          RoleEntity,
          $$RolesTableFilterComposer,
          $$RolesTableOrderingComposer,
          $$RolesTableAnnotationComposer,
          $$RolesTableCreateCompanionBuilder,
          $$RolesTableUpdateCompanionBuilder,
          (RoleEntity, $$RolesTableReferences),
          RoleEntity,
          PrefetchHooks Function({bool userProgramRolesRefs})
        > {
  $$RolesTableTableManager(_$AppDatabase db, $RolesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RolesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RolesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RolesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> code = const Value.absent(),
              }) => RolesCompanion(id: id, name: name, code: code),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required String code,
              }) => RolesCompanion.insert(id: id, name: name, code: code),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$RolesTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({userProgramRolesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (userProgramRolesRefs) db.userProgramRoles,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (userProgramRolesRefs)
                    await $_getPrefetchedData<
                      RoleEntity,
                      $RolesTable,
                      UserProgramRole
                    >(
                      currentTable: table,
                      referencedTable: $$RolesTableReferences
                          ._userProgramRolesRefsTable(db),
                      managerFromTypedResult: (p0) => $$RolesTableReferences(
                        db,
                        table,
                        p0,
                      ).userProgramRolesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.roleId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$RolesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RolesTable,
      RoleEntity,
      $$RolesTableFilterComposer,
      $$RolesTableOrderingComposer,
      $$RolesTableAnnotationComposer,
      $$RolesTableCreateCompanionBuilder,
      $$RolesTableUpdateCompanionBuilder,
      (RoleEntity, $$RolesTableReferences),
      RoleEntity,
      PrefetchHooks Function({bool userProgramRolesRefs})
    >;
typedef $$UserProgramRolesTableCreateCompanionBuilder =
    UserProgramRolesCompanion Function({
      required int userId,
      required int programId,
      required int roleId,
      Value<int> rowid,
    });
typedef $$UserProgramRolesTableUpdateCompanionBuilder =
    UserProgramRolesCompanion Function({
      Value<int> userId,
      Value<int> programId,
      Value<int> roleId,
      Value<int> rowid,
    });

final class $$UserProgramRolesTableReferences
    extends
        BaseReferences<_$AppDatabase, $UserProgramRolesTable, UserProgramRole> {
  $$UserProgramRolesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $UserProfilesTable _userIdTable(_$AppDatabase db) =>
      db.userProfiles.createAlias(
        $_aliasNameGenerator(db.userProgramRoles.userId, db.userProfiles.id),
      );

  $$UserProfilesTableProcessedTableManager get userId {
    final $_column = $_itemColumn<int>('user_id')!;

    final manager = $$UserProfilesTableTableManager(
      $_db,
      $_db.userProfiles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_userIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ProgramsTable _programIdTable(_$AppDatabase db) =>
      db.programs.createAlias(
        $_aliasNameGenerator(db.userProgramRoles.programId, db.programs.id),
      );

  $$ProgramsTableProcessedTableManager get programId {
    final $_column = $_itemColumn<int>('program_id')!;

    final manager = $$ProgramsTableTableManager(
      $_db,
      $_db.programs,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_programIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $RolesTable _roleIdTable(_$AppDatabase db) => db.roles.createAlias(
    $_aliasNameGenerator(db.userProgramRoles.roleId, db.roles.id),
  );

  $$RolesTableProcessedTableManager get roleId {
    final $_column = $_itemColumn<int>('role_id')!;

    final manager = $$RolesTableTableManager(
      $_db,
      $_db.roles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_roleIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$UserProgramRolesTableFilterComposer
    extends Composer<_$AppDatabase, $UserProgramRolesTable> {
  $$UserProgramRolesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$UserProfilesTableFilterComposer get userId {
    final $$UserProfilesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.userProfiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserProfilesTableFilterComposer(
            $db: $db,
            $table: $db.userProfiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ProgramsTableFilterComposer get programId {
    final $$ProgramsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.programId,
      referencedTable: $db.programs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProgramsTableFilterComposer(
            $db: $db,
            $table: $db.programs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$RolesTableFilterComposer get roleId {
    final $$RolesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.roleId,
      referencedTable: $db.roles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RolesTableFilterComposer(
            $db: $db,
            $table: $db.roles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$UserProgramRolesTableOrderingComposer
    extends Composer<_$AppDatabase, $UserProgramRolesTable> {
  $$UserProgramRolesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$UserProfilesTableOrderingComposer get userId {
    final $$UserProfilesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.userProfiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserProfilesTableOrderingComposer(
            $db: $db,
            $table: $db.userProfiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ProgramsTableOrderingComposer get programId {
    final $$ProgramsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.programId,
      referencedTable: $db.programs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProgramsTableOrderingComposer(
            $db: $db,
            $table: $db.programs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$RolesTableOrderingComposer get roleId {
    final $$RolesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.roleId,
      referencedTable: $db.roles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RolesTableOrderingComposer(
            $db: $db,
            $table: $db.roles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$UserProgramRolesTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserProgramRolesTable> {
  $$UserProgramRolesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$UserProfilesTableAnnotationComposer get userId {
    final $$UserProfilesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.userProfiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserProfilesTableAnnotationComposer(
            $db: $db,
            $table: $db.userProfiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ProgramsTableAnnotationComposer get programId {
    final $$ProgramsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.programId,
      referencedTable: $db.programs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProgramsTableAnnotationComposer(
            $db: $db,
            $table: $db.programs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$RolesTableAnnotationComposer get roleId {
    final $$RolesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.roleId,
      referencedTable: $db.roles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RolesTableAnnotationComposer(
            $db: $db,
            $table: $db.roles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$UserProgramRolesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UserProgramRolesTable,
          UserProgramRole,
          $$UserProgramRolesTableFilterComposer,
          $$UserProgramRolesTableOrderingComposer,
          $$UserProgramRolesTableAnnotationComposer,
          $$UserProgramRolesTableCreateCompanionBuilder,
          $$UserProgramRolesTableUpdateCompanionBuilder,
          (UserProgramRole, $$UserProgramRolesTableReferences),
          UserProgramRole,
          PrefetchHooks Function({bool userId, bool programId, bool roleId})
        > {
  $$UserProgramRolesTableTableManager(
    _$AppDatabase db,
    $UserProgramRolesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserProgramRolesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserProgramRolesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserProgramRolesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> userId = const Value.absent(),
                Value<int> programId = const Value.absent(),
                Value<int> roleId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserProgramRolesCompanion(
                userId: userId,
                programId: programId,
                roleId: roleId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int userId,
                required int programId,
                required int roleId,
                Value<int> rowid = const Value.absent(),
              }) => UserProgramRolesCompanion.insert(
                userId: userId,
                programId: programId,
                roleId: roleId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$UserProgramRolesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({userId = false, programId = false, roleId = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (userId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.userId,
                                    referencedTable:
                                        $$UserProgramRolesTableReferences
                                            ._userIdTable(db),
                                    referencedColumn:
                                        $$UserProgramRolesTableReferences
                                            ._userIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (programId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.programId,
                                    referencedTable:
                                        $$UserProgramRolesTableReferences
                                            ._programIdTable(db),
                                    referencedColumn:
                                        $$UserProgramRolesTableReferences
                                            ._programIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (roleId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.roleId,
                                    referencedTable:
                                        $$UserProgramRolesTableReferences
                                            ._roleIdTable(db),
                                    referencedColumn:
                                        $$UserProgramRolesTableReferences
                                            ._roleIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [];
                  },
                );
              },
        ),
      );
}

typedef $$UserProgramRolesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UserProgramRolesTable,
      UserProgramRole,
      $$UserProgramRolesTableFilterComposer,
      $$UserProgramRolesTableOrderingComposer,
      $$UserProgramRolesTableAnnotationComposer,
      $$UserProgramRolesTableCreateCompanionBuilder,
      $$UserProgramRolesTableUpdateCompanionBuilder,
      (UserProgramRole, $$UserProgramRolesTableReferences),
      UserProgramRole,
      PrefetchHooks Function({bool userId, bool programId, bool roleId})
    >;
typedef $$UserRolesTableCreateCompanionBuilder =
    UserRolesCompanion Function({
      required int userId,
      required String roleCode,
      Value<int> rowid,
    });
typedef $$UserRolesTableUpdateCompanionBuilder =
    UserRolesCompanion Function({
      Value<int> userId,
      Value<String> roleCode,
      Value<int> rowid,
    });

final class $$UserRolesTableReferences
    extends BaseReferences<_$AppDatabase, $UserRolesTable, UserRole> {
  $$UserRolesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $UserProfilesTable _userIdTable(_$AppDatabase db) =>
      db.userProfiles.createAlias(
        $_aliasNameGenerator(db.userRoles.userId, db.userProfiles.id),
      );

  $$UserProfilesTableProcessedTableManager get userId {
    final $_column = $_itemColumn<int>('user_id')!;

    final manager = $$UserProfilesTableTableManager(
      $_db,
      $_db.userProfiles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_userIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$UserRolesTableFilterComposer
    extends Composer<_$AppDatabase, $UserRolesTable> {
  $$UserRolesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get roleCode => $composableBuilder(
    column: $table.roleCode,
    builder: (column) => ColumnFilters(column),
  );

  $$UserProfilesTableFilterComposer get userId {
    final $$UserProfilesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.userProfiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserProfilesTableFilterComposer(
            $db: $db,
            $table: $db.userProfiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$UserRolesTableOrderingComposer
    extends Composer<_$AppDatabase, $UserRolesTable> {
  $$UserRolesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get roleCode => $composableBuilder(
    column: $table.roleCode,
    builder: (column) => ColumnOrderings(column),
  );

  $$UserProfilesTableOrderingComposer get userId {
    final $$UserProfilesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.userProfiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserProfilesTableOrderingComposer(
            $db: $db,
            $table: $db.userProfiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$UserRolesTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserRolesTable> {
  $$UserRolesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get roleCode =>
      $composableBuilder(column: $table.roleCode, builder: (column) => column);

  $$UserProfilesTableAnnotationComposer get userId {
    final $$UserProfilesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.userProfiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserProfilesTableAnnotationComposer(
            $db: $db,
            $table: $db.userProfiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$UserRolesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UserRolesTable,
          UserRole,
          $$UserRolesTableFilterComposer,
          $$UserRolesTableOrderingComposer,
          $$UserRolesTableAnnotationComposer,
          $$UserRolesTableCreateCompanionBuilder,
          $$UserRolesTableUpdateCompanionBuilder,
          (UserRole, $$UserRolesTableReferences),
          UserRole,
          PrefetchHooks Function({bool userId})
        > {
  $$UserRolesTableTableManager(_$AppDatabase db, $UserRolesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserRolesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserRolesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserRolesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> userId = const Value.absent(),
                Value<String> roleCode = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserRolesCompanion(
                userId: userId,
                roleCode: roleCode,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int userId,
                required String roleCode,
                Value<int> rowid = const Value.absent(),
              }) => UserRolesCompanion.insert(
                userId: userId,
                roleCode: roleCode,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$UserRolesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({userId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (userId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.userId,
                                referencedTable: $$UserRolesTableReferences
                                    ._userIdTable(db),
                                referencedColumn: $$UserRolesTableReferences
                                    ._userIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$UserRolesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UserRolesTable,
      UserRole,
      $$UserRolesTableFilterComposer,
      $$UserRolesTableOrderingComposer,
      $$UserRolesTableAnnotationComposer,
      $$UserRolesTableCreateCompanionBuilder,
      $$UserRolesTableUpdateCompanionBuilder,
      (UserRole, $$UserRolesTableReferences),
      UserRole,
      PrefetchHooks Function({bool userId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$PlatformsTableTableManager get platforms =>
      $$PlatformsTableTableManager(_db, _db.platforms);
  $$UserProfilesTableTableManager get userProfiles =>
      $$UserProfilesTableTableManager(_db, _db.userProfiles);
  $$ProgramsTableTableManager get programs =>
      $$ProgramsTableTableManager(_db, _db.programs);
  $$RolesTableTableManager get roles =>
      $$RolesTableTableManager(_db, _db.roles);
  $$UserProgramRolesTableTableManager get userProgramRoles =>
      $$UserProgramRolesTableTableManager(_db, _db.userProgramRoles);
  $$UserRolesTableTableManager get userRoles =>
      $$UserRolesTableTableManager(_db, _db.userRoles);
}
