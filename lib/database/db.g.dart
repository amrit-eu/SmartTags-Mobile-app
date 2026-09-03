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
  static const VerificationMeta _endingCauseIdMeta = const VerificationMeta(
    'endingCauseId',
  );
  @override
  late final GeneratedColumn<int> endingCauseId = GeneratedColumn<int>(
    'ending_cause_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _hasLatestObservationMeta =
      const VerificationMeta('hasLatestObservation');
  @override
  late final GeneratedColumn<bool> hasLatestObservation = GeneratedColumn<bool>(
    'has_latest_observation',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("has_latest_observation" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
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
    endingCauseId,
    hasLatestObservation,
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
    if (data.containsKey('ending_cause_id')) {
      context.handle(
        _endingCauseIdMeta,
        endingCauseId.isAcceptableOrUnknown(
          data['ending_cause_id']!,
          _endingCauseIdMeta,
        ),
      );
    }
    if (data.containsKey('has_latest_observation')) {
      context.handle(
        _hasLatestObservationMeta,
        hasLatestObservation.isAcceptableOrUnknown(
          data['has_latest_observation']!,
          _hasLatestObservationMeta,
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
      endingCauseId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ending_cause_id'],
      ),
      hasLatestObservation: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}has_latest_observation'],
      )!,
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

  /// Passport ending cause id for recovery status (#100).
  final int? endingCauseId;

  /// Whether passport includes a GTS latest observation (#100).
  final bool hasLatestObservation;
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
    this.endingCauseId,
    required this.hasLatestObservation,
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
    if (!nullToAbsent || endingCauseId != null) {
      map['ending_cause_id'] = Variable<int>(endingCauseId);
    }
    map['has_latest_observation'] = Variable<bool>(hasLatestObservation);
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
      endingCauseId: endingCauseId == null && nullToAbsent
          ? const Value.absent()
          : Value(endingCauseId),
      hasLatestObservation: Value(hasLatestObservation),
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
      endingCauseId: serializer.fromJson<int?>(json['endingCauseId']),
      hasLatestObservation: serializer.fromJson<bool>(
        json['hasLatestObservation'],
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
      'endingCauseId': serializer.toJson<int?>(endingCauseId),
      'hasLatestObservation': serializer.toJson<bool>(hasLatestObservation),
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
    Value<int?> endingCauseId = const Value.absent(),
    bool? hasLatestObservation,
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
    endingCauseId: endingCauseId.present
        ? endingCauseId.value
        : this.endingCauseId,
    hasLatestObservation: hasLatestObservation ?? this.hasLatestObservation,
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
      endingCauseId: data.endingCauseId.present
          ? data.endingCauseId.value
          : this.endingCauseId,
      hasLatestObservation: data.hasLatestObservation.present
          ? data.hasLatestObservation.value
          : this.hasLatestObservation,
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
          ..write('latestOperationDate: $latestOperationDate, ')
          ..write('endingCauseId: $endingCauseId, ')
          ..write('hasLatestObservation: $hasLatestObservation')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
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
    endingCauseId,
    hasLatestObservation,
  ]);
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
          other.latestOperationDate == this.latestOperationDate &&
          other.endingCauseId == this.endingCauseId &&
          other.hasLatestObservation == this.hasLatestObservation);
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
  final Value<int?> endingCauseId;
  final Value<bool> hasLatestObservation;
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
    this.endingCauseId = const Value.absent(),
    this.hasLatestObservation = const Value.absent(),
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
    this.endingCauseId = const Value.absent(),
    this.hasLatestObservation = const Value.absent(),
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
    Expression<int>? endingCauseId,
    Expression<bool>? hasLatestObservation,
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
      if (endingCauseId != null) 'ending_cause_id': endingCauseId,
      if (hasLatestObservation != null)
        'has_latest_observation': hasLatestObservation,
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
    Value<int?>? endingCauseId,
    Value<bool>? hasLatestObservation,
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
      endingCauseId: endingCauseId ?? this.endingCauseId,
      hasLatestObservation: hasLatestObservation ?? this.hasLatestObservation,
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
    if (endingCauseId.present) {
      map['ending_cause_id'] = Variable<int>(endingCauseId.value);
    }
    if (hasLatestObservation.present) {
      map['has_latest_observation'] = Variable<bool>(
        hasLatestObservation.value,
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
          ..write('latestOperationDate: $latestOperationDate, ')
          ..write('endingCauseId: $endingCauseId, ')
          ..write('hasLatestObservation: $hasLatestObservation')
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
      Value<String?> operationNotes,
      Value<String?> platformCategory,
      Value<String?> reportingStatus,
      Value<String?> observingNetwork,
      Value<String?> latestOperationType,
      Value<DateTime?> latestOperationDate,
      Value<int?> endingCauseId,
      Value<bool> hasLatestObservation,
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
      Value<int?> endingCauseId,
      Value<bool> hasLatestObservation,
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

  ColumnFilters<int> get endingCauseId => $composableBuilder(
    column: $table.endingCauseId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get hasLatestObservation => $composableBuilder(
    column: $table.hasLatestObservation,
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

  ColumnOrderings<int> get endingCauseId => $composableBuilder(
    column: $table.endingCauseId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get hasLatestObservation => $composableBuilder(
    column: $table.hasLatestObservation,
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

  GeneratedColumn<int> get endingCauseId => $composableBuilder(
    column: $table.endingCauseId,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get hasLatestObservation => $composableBuilder(
    column: $table.hasLatestObservation,
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
                Value<int?> endingCauseId = const Value.absent(),
                Value<bool> hasLatestObservation = const Value.absent(),
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
                endingCauseId: endingCauseId,
                hasLatestObservation: hasLatestObservation,
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
                Value<int?> endingCauseId = const Value.absent(),
                Value<bool> hasLatestObservation = const Value.absent(),
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
                endingCauseId: endingCauseId,
                hasLatestObservation: hasLatestObservation,
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
