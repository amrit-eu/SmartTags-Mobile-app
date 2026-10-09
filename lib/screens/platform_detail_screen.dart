import 'dart:async';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:smart_tags/config/map_config.dart';
import 'package:smart_tags/constants/alert_style_palette.dart';
import 'package:smart_tags/constants/platform_status_palette.dart';
import 'package:smart_tags/database/db.dart' show PlatformsCompanion;
import 'package:smart_tags/database/mappers/platform_mapper.dart';
import 'package:smart_tags/helpers/connection_message.dart';
import 'package:smart_tags/helpers/coordinate_format.dart';
import 'package:smart_tags/helpers/latest_operation_status.dart';
import 'package:smart_tags/helpers/operation_record_route.dart';
import 'package:smart_tags/models/alert.dart';
import 'package:smart_tags/models/platform.dart';
import 'package:smart_tags/models/qr_scan_result.dart';
import 'package:smart_tags/providers/auth_provider.dart';
import 'package:smart_tags/providers/connection_provider.dart';
import 'package:smart_tags/providers/db_providers.dart';
import 'package:smart_tags/providers/permission_provider.dart';
import 'package:smart_tags/screens/alerts_screen.dart';
import 'package:smart_tags/screens/operation_record_screen.dart';
import 'package:smart_tags/screens/qr_scan_screen.dart';
import 'package:smart_tags/services/auth_service.dart';
import 'package:smart_tags/services/gateway_repository.dart';
import 'package:smart_tags/widgets/alerts_bottom_sheet.dart';
import 'package:smart_tags/widgets/common/container.dart';
import 'package:smart_tags/widgets/identifiers_bottom_sheet.dart';
import 'package:smart_tags/widgets/status_badge.dart';
import 'package:smart_tags/widgets/top_navigation.dart';

/// A screen displaying detailed information about a specific platform.
class PlatformDetailScreen extends ConsumerStatefulWidget {
  /// Creates a [PlatformDetailScreen] widget.
  const PlatformDetailScreen({required this.platformRef, super.key});

  /// The platform reference used to watch live updates from the database.
  final String platformRef;

  @override
  ConsumerState<PlatformDetailScreen> createState() => _PlatformDetailScreenState();
}

class _PlatformDetailScreenState extends ConsumerState<PlatformDetailScreen> {
  late final MapController _mapController;
  bool _isPairing = false;
  String? _confirmedQrCode;

  static const _offlinePairingMessage = 'Pairing functionality disabled: Offline';

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  void _showPairingMessage(String message, {bool success = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message, style: const TextStyle(color: Colors.white)),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
  }

  Future<bool> _isOnlineForPairing() async {
    final connection = ref.read(checkConnectionProvider);
    if (connection.hasValue || connection.hasError) {
      return isDeviceOnline(connection.value);
    }
    try {
      return isDeviceOnline(await ref.read(checkConnectionProvider.future).timeout(const Duration(seconds: 5)));
    } on Object {
      return false;
    }
  }

  Future<void> _pairPlatform(Platform platform) async {
    if (_isPairing || _confirmedQrCode != null) return;
    setState(() => _isPairing = true);
    try {
      final online = await _isOnlineForPairing();
      if (!mounted) return;
      if (!online) {
        _showPairingMessage(_offlinePairingMessage);
        return;
      }
      if (ref.read(authProvider).value == null) {
        _showPairingMessage('Log in to pair this platform to a QR code.');
        return;
      }
      final ptfId = platform.ptfId;
      final numericId = ptfId == null ? null : int.tryParse(ptfId.trim(), radix: 10);
      if (numericId == null || numericId <= 0) {
        _showPairingMessage('Platform ID is unavailable. Refresh platform data and try again.');
        return;
      }

      final result = await Navigator.of(context).push<QrScanResult>(
        MaterialPageRoute(builder: (_) => const QrScanScreen.pairing()),
      );
      if (!mounted) return;
      if (result == null) {
        _showPairingMessage('Pairing cancelled.');
        return;
      }
      final qrCode = result.qrCode;
      if (qrCode == null) {
        _showPairingMessage(result.errorMessage ?? 'Unable to scan QR code.');
        return;
      }

      final stillOnline = await _isOnlineForPairing();
      if (!mounted) return;
      if (!stillOnline) {
        _showPairingMessage(_offlinePairingMessage);
        return;
      }

      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Pair this platform to this QR code?'),
          content: Text(
            'Platform: ${(platform.name?.trim().isNotEmpty ?? false) ? platform.name : platform.model}\n'
            '${(platform.wigosId?.trim().isNotEmpty ?? false) ? 'WIGOS ID: ${platform.wigosId}' : 'Reference: ${platform.platformRef}'}\n\n'
            'QR code: $qrCode',
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: const Text('Cancel')),
            FilledButton(onPressed: () => Navigator.of(dialogContext).pop(true), child: const Text('Pair')),
          ],
        ),
      );
      if (!mounted) return;
      if (confirmed != true) {
        _showPairingMessage('Pairing cancelled.');
        return;
      }
      final onlineAfterConfirmation = await _isOnlineForPairing();
      if (!mounted) return;
      if (!onlineAfterConfirmation) {
        _showPairingMessage(_offlinePairingMessage);
        return;
      }

      final currentPlatform = ref.read(platformByRefStreamProvider(widget.platformRef)).value;
      if (currentPlatform == null) {
        _showPairingMessage('Platform is no longer available. Refresh platform data and try again.');
        return;
      }
      if (currentPlatform.qrCode?.trim().isNotEmpty ?? false) {
        _showPairingMessage(
          currentPlatform.qrCode == qrCode
              ? 'Platform is already paired to this QR code.'
              : 'Platform is already paired to a different QR code.',
          success: currentPlatform.qrCode == qrCode,
        );
        return;
      }

      final gateway = ref.read(gatewayRepositoryProvider);
      final database = ref.read(databaseProvider);
      final platformRef = widget.platformRef;
      await gateway.pairPlatformToQRCode(ptfId!, qrCode);
      // Keep the confirmed association visible while passport regeneration
      // catches up, including if a background refresh returns stale data.
      if (mounted) setState(() => _confirmedQrCode = qrCode);
      try {
        await database.updatePlatforms([
          PlatformsCompanion(ref: Value(platformRef), qrCode: Value(qrCode)),
        ]);
      } on Object catch (error) {
        debugPrint('Could not save confirmed QR pairing locally: $error');
        _showPairingMessage('Platform paired to QR code. Refresh to update local data.', success: true);
        return;
      }
      _showPairingMessage('Platform paired to QR code successfully.', success: true);
    } on GatewayException catch (error) {
      if (mounted) {
        _showPairingMessage(
          isDeviceOnline(ref.read(checkConnectionProvider).value) ? error.message : _offlinePairingMessage,
        );
      }
    } on RefreshException {
      _showPairingMessage('Session expired. Please log in again.');
    } on Object {
      _showPairingMessage('Unable to pair platform to QR code. Please try again.');
    } finally {
      if (mounted) setState(() => _isPairing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final platformAsync = ref.watch(platformByRefStreamProvider(widget.platformRef));
    final platform = platformAsync.value?.toDomain();

    if (platform == null) {
      return Scaffold(
        appBar: TopNavigation(title: const Text('Platform Details'), leading: const BackButton()),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    // Permissions
    final userPermissions = ref.watch(permissionProvider);
    final canEditExamplePlatform = userPermissions.canEdit(Resource.deployment, programId: platform.program?.id ?? 0);
    final isLoggedIn = ref.watch(authProvider).value != null;
    final isOnline = isDeviceOnline(ref.watch(checkConnectionProvider).value);

    // Listen for position updates and auto-center map
    ref.listen(platformByRefStreamProvider(widget.platformRef), (previous, next) {
      next.whenData((dbPlatform) {
        if (dbPlatform != null && mounted) {
          final newPosition = LatLng(dbPlatform.lat, dbPlatform.lon);
          _mapController.move(newPosition, _mapController.camera.zoom);
        }
      });
    });

    return Scaffold(
      appBar: TopNavigation(
        title: const Text('Platform Details'),
        leading: const BackButton(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Map Section
            SectionContainer(
              height: 250,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  children: [
                    FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: platform.latestPosition,
                        initialZoom: 10,
                        interactionOptions: const InteractionOptions(flags: InteractiveFlag.none),
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: MapConfig.oceanBaseTileUrl,
                          userAgentPackageName: MapConfig.userAgentPackageName,
                        ),
                        TileLayer(
                          urlTemplate: MapConfig.oceanReferenceTileUrl,
                          userAgentPackageName: MapConfig.userAgentPackageName,
                        ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: platform.latestPosition,
                              width: 40,
                              height: 40,
                              child: Icon(
                                Icons.location_on,
                                color: PlatformStatusPalette.forStatus(platform.status).backgroundColor,
                                size: 40,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(200),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Latest observation',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            _PlatformSummaryCard(
              platform: platform,
              confirmedQrCode: _confirmedQrCode,
              isPairing: _isPairing,
              isOnline: isOnline,
              onPair: () => unawaited(_pairPlatform(platform)),
            ),
            const SizedBox(height: 16),

            _AlertsSummaryRow(platformRef: widget.platformRef),
            const SizedBox(height: 16),

            _LatestOperationCard(platform: platform),
            const SizedBox(height: 72),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: platform.operationalStatus == OperationalStatus.deployed ? 'recover' : 'deploy',
        backgroundColor: canEditExamplePlatform ? null : Theme.of(context).disabledColor,
        foregroundColor: canEditExamplePlatform
            ? null
            : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.38),
        onPressed: () async {
          if (!canEditExamplePlatform) {
            final message = isLoggedIn
                ? "You don't have permission to edit this platform. You must be member of the ${platform.program?.name} program."
                : 'Log in to edit this platform.';
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(message)),
            );
            return;
          }
          final result = await Navigator.of(context).push<OperationSubmitResult>(
            operationRecordRoute(
              DeployPlatformScreen(
                action: platform.operationalStatus == OperationalStatus.deployed
                    ? DeployAction.recover
                    : DeployAction.deploy,
                platform: platform,
              ),
            ),
          );
          if (!context.mounted || result == null) return;
          applyOperationSubmitResult(
            container: ProviderScope.containerOf(context, listen: false),
            result: result,
            messenger: ScaffoldMessenger.of(context),
          );
        },
        icon: platform.operationalStatus == OperationalStatus.deployed
            ? const Icon(Icons.repeat)
            : const Icon(Icons.arrow_circle_up_rounded),
        label: platform.operationalStatus == OperationalStatus.deployed ? const Text('Recover') : const Text('Deploy'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

/// Passport-aligned summary on the platform details page (#97).
class _PlatformSummaryCard extends StatelessWidget {
  const _PlatformSummaryCard({
    required this.platform,
    required this.isPairing,
    required this.isOnline,
    required this.onPair,
    this.confirmedQrCode,
  });

  final Platform platform;
  final bool isPairing;
  final bool isOnline;
  final VoidCallback onPair;
  final String? confirmedQrCode;

  static String _dash(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '-';
    }
    final trimmed = value.trim();
    if (trimmed.toLowerCase() == 'unknown') {
      return '-';
    }
    return trimmed;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final qrCode = confirmedQrCode ?? platform.qrCode;
    final isUnpaired = qrCode?.trim().isEmpty ?? true;

    return SectionContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _dash(platform.category),
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _dash(platform.model),
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              StatusBadge.fromOperationalStatus(
                operationalStatus: platform.operationalStatus,
                showLeadingDot: true,
              ),
            ],
          ),
          const Divider(height: 24),
          InkWell(
            onTap: () => showIdentifiersBottomSheet(context, platform: platform),
            child: Row(
              children: [
                Expanded(
                  child: ContainerRow(
                    label: 'WIGOS ID',
                    value: _dash(platform.wigosId),
                  ),
                ),
                Icon(Icons.chevron_right, color: theme.colorScheme.onSurfaceVariant),
              ],
            ),
          ),
          const Divider(height: 16),
          Row(
            children: [
              Expanded(
                child: ContainerRow(
                  label: 'QR Code',
                  value: isUnpaired ? 'Not paired' : qrCode!,
                ),
              ),
              if (isUnpaired) ...[
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: isPairing ? null : onPair,
                  style: isOnline
                      ? null
                      : OutlinedButton.styleFrom(
                          foregroundColor: theme.disabledColor,
                          side: BorderSide(color: theme.disabledColor),
                        ),
                  icon: isPairing
                      ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.qr_code_scanner),
                  label: Text(isPairing ? 'Pairing...' : 'Pair to QR Code'),
                ),
              ],
            ],
          ),
          const Divider(height: 16),
          ContainerRow(
            label: 'Latest observation',
            value: formatLatLng(platform.latestPosition),
          ),
          const Divider(height: 16),
          ContainerRow(
            label: 'Last updated',
            value: '${DateFormat('MMM dd, yyyy, hh:mm a').format(platform.lastUpdated)} UTC',
          ),
          const Divider(height: 16),
          ContainerRow(
            label: 'Observing network',
            value: _dash(platform.observingNetwork ?? platform.network),
          ),
        ],
      ),
    );
  }
}

/// Alerts summary row showing aggregate alert status for the platform (#84).
class _AlertsSummaryRow extends ConsumerWidget {
  const _AlertsSummaryRow({required this.platformRef});

  final String platformRef;

  static String _label({required int openCount, required int acknowledgedCount}) {
    if (openCount > 0 && acknowledgedCount > 0) {
      final totalCount = openCount + acknowledgedCount;
      return '$totalCount Active ${totalCount == 1 ? 'alert' : 'alerts'}';
    }

    if (openCount > 0) {
      return '$openCount Open ${openCount == 1 ? 'alert' : 'alerts'}';
    }
    if (acknowledgedCount > 0) {
      return '$acknowledgedCount Acknowledged ${acknowledgedCount == 1 ? 'alert' : 'alerts'}';
    }
    return 'No active alerts';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alerts = ref.watch(alertsByResourceStreamProvider(platformRef)).value ?? const <Alert>[];
    final openCount = alerts.where((alert) => alert.status == AlertStatus.open).length;
    final acknowledgedCount = alerts.where((alert) => alert.status == AlertStatus.acknowledged).length;

    final style = AlertStatusPalette.forCounts(openCount: openCount, acknowledgedCount: acknowledgedCount);
    final label = _label(openCount: openCount, acknowledgedCount: acknowledgedCount);
    final theme = Theme.of(context);

    final hasActiveAlerts = openCount + acknowledgedCount > 0;

    return SectionContainer(
      child: InkWell(
        onTap: hasActiveAlerts
            ? () => showAlertsBottomSheet(
                context,
                alerts: alerts,
                totalAlertCount: alerts.length,
                platformRef: platformRef,
              )
            : alerts.isNotEmpty
            ? () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => AlertsScreen(platformRef: platformRef)),
              )
            : null,
        child: Row(
          children: [
            Icon(style.displayIcon, color: style.color),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Alerts',
                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            if (openCount > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: style.color,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(style.displayIcon, size: 16, color: Colors.black87),
                    const SizedBox(width: 6),
                    Text(
                      label,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              )
            else
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: style.color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            const SizedBox(width: 8),
            if (hasActiveAlerts) Icon(Icons.chevron_right, color: theme.colorScheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}

/// Latest operation card with planned/completed status (#99, #100).
class _LatestOperationCard extends StatelessWidget {
  const _LatestOperationCard({required this.platform});

  final Platform platform;

  static String _dash(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '-';
    }
    return value.trim();
  }

  static String _operationLabel(Platform platform) {
    final type = platform.latestOperationType?.trim();
    if (type != null && type.isNotEmpty) {
      return type;
    }
    return platform.operationalStatus == OperationalStatus.recovered ? 'Recovery' : 'Deployment';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final completionStatus = resolveOperationCompletionStatus(platform);
    final completionStyle = operationCompletionStyle(completionStatus);
    final operationDate = platform.latestOperationDate;

    return SectionContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Latest Operation',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const Divider(height: 24),
          Row(
            children: [
              Expanded(
                child: Text(
                  _operationLabel(platform),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (completionStatus != OperationCompletionStatus.unknown)
                StatusBadge.fromStyle(
                  style: completionStyle,
                  showLeadingDot: true,
                ),
            ],
          ),
          const Divider(height: 16),
          ContainerRow(
            label: 'Date',
            value: operationDate == null ? '-' : '${DateFormat('MMM dd, yyyy, hh:mm a').format(operationDate)} UTC',
          ),
          const Divider(height: 16),
          ContainerRow(
            label: 'Location',
            value: formatLatLng(platform.operationLocation),
          ),
          if (platform.operationNotes != null && platform.operationNotes!.trim().isNotEmpty) ...[
            const Divider(height: 16),
            ContainerRow(
              label: 'Notes',
              value: _dash(platform.operationNotes),
            ),
          ],
        ],
      ),
    );
  }
}
