import 'dart:async';

// Subscriptions are cancelled in [setUseLiveLocation] and [dispose].
// ignore_for_file: cancel_subscriptions

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:smart_tags/constants/oceanops_codes.dart';
import 'package:smart_tags/database/db.dart' hide Platform;
import 'package:smart_tags/extensions/string_extension.dart';
import 'package:smart_tags/helpers/location/location_fetcher.dart';
import 'package:smart_tags/models/deploy_action.dart';
import 'package:smart_tags/models/passport_event.dart';
import 'package:smart_tags/models/platform.dart';
import 'package:smart_tags/providers/connection_provider.dart';
import 'package:smart_tags/providers/db_providers.dart';
import 'package:smart_tags/providers/passport_event_queue_provider.dart';
import 'package:smart_tags/providers/platforms_refresh_provider.dart';
import 'package:smart_tags/widgets/common/container.dart';
import 'package:smart_tags/widgets/offline_status.dart';
import 'package:smart_tags/widgets/top_navigation.dart';

export 'package:smart_tags/models/deploy_action.dart';

/// Result returned when a deploy/recover form is submitted successfully.
class OperationSubmitResult {
  /// Creates an [OperationSubmitResult].
  const OperationSubmitResult({
    required this.message,
    required this.platformRef,
  });

  /// User-facing confirmation shown after returning to the previous screen.
  final String message;

  /// Platform that was updated.
  final String platformRef;
}

/// Shows post-submit feedback after [OperationSubmitResult] is returned from the form route.
void applyOperationSubmitResult({
  required ProviderContainer container,
  required OperationSubmitResult result,
  required ScaffoldMessengerState messenger,
}) {
  messenger.showSnackBar(SnackBar(content: Text(result.message)));
}

/// A screen for deploying or recovering a platform, allowing users to input relevant details.
class DeployPlatformScreen extends ConsumerStatefulWidget {
  /// Creates a [DeployPlatformScreen] widget.
  /// [action] specifies whether the user is deploying or recovering a platform.
  /// [platform] is the platform being deployed or recovered.
  const DeployPlatformScreen({
    required this.action,
    required this.platform,
    this.positionStream,
    this.serviceStatusStream,
    this.ensureLocationPermission,
    super.key,
  });

  /// The type of operation being performed (deploy or recover).
  final DeployAction action;

  /// The platform being deployed or recovered.
  final Platform platform;

  /// Optional test injection for position stream
  @visibleForTesting
  final Stream<Position>? positionStream;

  /// Optional test injection for service status stream
  @visibleForTesting
  final Stream<ServiceStatus>? serviceStatusStream;

  /// Optional test injection to bypass [Geolocator] permission checks.
  @visibleForTesting
  final Future<bool> Function()? ensureLocationPermission;

  @override
  ConsumerState<DeployPlatformScreen> createState() => _DeployPlatformScreenState();
}

class _DeployPlatformScreenState extends ConsumerState<DeployPlatformScreen> {
  final _formKey = GlobalKey<FormState>();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  final _dateTimeController = TextEditingController();
  final _notesController = TextEditingController();
  final _maxWaterDepthController = TextEditingController();
  final _elevationController = TextEditingController();
  final _shipImoNumberController = TextEditingController();
  final _shipOvhIdController = TextEditingController();
  final _shipNameController = TextEditingController();
  String? _selectedMethodCode;
  String? _selectedEndingCauseCode;
  late ConnectivityResult _connectivityState;

  StreamSubscription<Position>? _liveLocationSubscription;
  StreamSubscription<ServiceStatus>? _serviceStatusSubscription;
  bool useLiveLocation = false; // Default to false to save battery.
  DateTime? _selectedDateTime;

  /// The currently selected operation type, editable via the segmented control.
  /// Seeded from [DeployPlatformScreen.action] but can be overridden in-form.
  late DeployAction _selectedAction;

  bool _submitInProgress = false;

  String get _eventType => _selectedAction == DeployAction.deploy ? 'Deployment' : 'Recovery';

  void _closeForm([OperationSubmitResult? result]) {
    if (!mounted) return;
    final navigator = Navigator.of(context);
    if (!navigator.canPop()) return;
    navigator.pop(result);
  }

  @override
  void initState() {
    super.initState();
    _selectedAction = widget.action;
  }

  Future<void> setUseLiveLocation({required bool enabled}) async {
    if (enabled) {
      final ensurePermission = widget.ensureLocationPermission ?? () => LocationFetcher().ensureLocationPermission();
      final allowed = await ensurePermission();
      if (!allowed) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permission is required for live updates.')),
          );
        }
        return;
      }
    }

    if (!mounted) {
      return;
    }
    setState(() {
      useLiveLocation = enabled; // Set live location updates on or off based on the provided flag.
    });
    if (!useLiveLocation) {
      return;
    }

    // Create fresh streams from providers or use injected ones (for testing)
    final positionStream = widget.positionStream ?? Geolocator.getPositionStream();
    // getServiceStatusStream is not supported on web platform
    final serviceStatusStream = widget.serviceStatusStream ?? (!kIsWeb ? Geolocator.getServiceStatusStream() : null);

    // Monitor location changes.
    _liveLocationSubscription = positionStream.listen(
      (position) {
        if (mounted) {
          setState(() {
            _latitudeController.text = position.latitude.toStringAsFixed(6);
            _longitudeController.text = position.longitude.toStringAsFixed(6);
            _setSelectedDateTime(position.timestamp);
          });
        }
      },
      onError: (Object error) {
        debugPrint('Location stream error: $error');
        if (mounted && useLiveLocation) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error fetching live location. Live updates stopped.')),
          );
          // addPostFrameCallback used to avoid setState during build
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) unawaited(setUseLiveLocation(enabled: false));
          });
        }
      },
    );
    // Monitor location service status changes (mobile only).
    if (serviceStatusStream != null) {
      _serviceStatusSubscription = serviceStatusStream.listen(
        (status) {
          if (status == ServiceStatus.disabled && useLiveLocation && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Location services disabled. Live updates stopped.')),
            );
            // addPostFrameCallback used to avoid setState during build
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) unawaited(setUseLiveLocation(enabled: false));
            });
          }
        },
      );
    }
  }

  void _cancelLiveLocationSubscriptions() {
    final live = _liveLocationSubscription;
    if (live != null) {
      live.cancel().ignore();
      _liveLocationSubscription = null;
    }
    final service = _serviceStatusSubscription;
    if (service != null) {
      service.cancel().ignore();
      _serviceStatusSubscription = null;
    }
  }

  void toggleLiveUpdates() {
    unawaited(setUseLiveLocation(enabled: !useLiveLocation));
  }

  void _setSelectedDateTime(DateTime? dateTime) {
    /// Helper method to update the selected date and time,
    /// and update the corresponding text field.
    setState(() {
      _selectedDateTime = dateTime;
      _dateTimeController.text = _selectedDateTime != null
          ? DateFormat('MMM dd, yyyy, hh:mm a').format(_selectedDateTime!)
          : '';
    });
  }

  @override
  void dispose() {
    _latitudeController.dispose();
    _longitudeController.dispose();
    _dateTimeController.dispose();
    _notesController.dispose();
    _maxWaterDepthController.dispose();
    _elevationController.dispose();
    _shipImoNumberController.dispose();
    _shipOvhIdController.dispose();
    _shipNameController.dispose();
    _cancelLiveLocationSubscriptions();
    super.dispose();
  }

  String? _validateOptionalNumber(String? value, String label) {
    if (value == null || value.isEmpty) return null;
    try {
      double.parse(value);
    } on FormatException {
      return '$label must be a valid number';
    }
    return null;
  }

  Future<void> _submitForm() async {
    if (_submitInProgress) return;

    // Validate form before submission
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final ptfId = widget.platform.ptfId;
    if (ptfId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Missing Gateway platform ID — refresh platform data (reconnect) before syncing.'),
          ),
        );
        _closeForm();
      }
      return;
    }

    setState(() => _submitInProgress = true);

    final latitude = double.parse(_latitudeController.text);
    final longitude = double.parse(_longitudeController.text);
    final request = _selectedAction == DeployAction.deploy
        ? PassportEventRequest.deployment(
            ptfId: ptfId,
            deployment: DeploymentEventPayload(
              latitude: latitude,
              longitude: longitude,
              date: _selectedDateTime!,
              methodCode: _selectedMethodCode,
              maxWaterDepth: double.tryParse(_maxWaterDepthController.text),
              elevation: double.tryParse(_elevationController.text),
              shipImoNumber: _shipImoNumberController.text,
              shipOvhId: _shipOvhIdController.text,
              shipName: _shipNameController.text,
            ),
          )
        : PassportEventRequest.retrieval(
            ptfId: ptfId,
            retrieval: RetrievalEventPayload(
              latitude: latitude,
              longitude: longitude,
              startDate: _selectedDateTime!,
              endingCauseCode: _selectedEndingCauseCode,
              shipImoNumber: _shipImoNumberController.text,
              shipOvhId: _shipOvhIdController.text,
              shipName: _shipNameController.text,
            ),
          );

    final outcome = await ref
        .read(passportEventQueueProvider.notifier)
        .enqueueOrSend(platformRef: widget.platform.platformRef, action: _selectedAction, request: request);

    if (outcome == PassportEventSubmitOutcome.sent) {
      // The event was actually sent to the Gateway now, so schedule a
      // delayed refresh to pick up the server-side change once it's had
      // time to propagate. Fire-and-forget and deliberately not awaited
      ref.read(platformsRefreshProvider.notifier).refreshAfterDelay().ignore();
    }

    // The event was sent (or queued for later sync) successfully; reflect
    // the new state in the local database so the UI updates immediately.
    try {
      await ref.read(databaseProvider).updatePlatforms([
        PlatformsCompanion(
          ref: Value(widget.platform.platformRef),
          model: Value(widget.platform.model),
          lat: Value(latitude),
          lon: Value(longitude),
          lastUpdated: Value(_selectedDateTime!),
          operationLat: Value(latitude),
          operationLon: Value(longitude),
          operationalStatus: Value(_selectedAction == DeployAction.deploy ? 'Deployed' : 'Recovered'),
          latestOperationType: Value(_selectedAction == DeployAction.deploy ? 'Deployed' : 'Recovered'),
          status: Value(widget.platform.status.apiName),
          operationNotes: Value(_notesController.text),
        ),
      ]);
    } on Exception catch (e) {
      debugPrint('Error updating platform: $e');
      if (mounted) {
        setState(() => _submitInProgress = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update platform.')),
        );
      }
      return;
    }

    if (mounted) {
      final message = switch (outcome) {
        PassportEventSubmitOutcome.sent => '$_eventType successful! Changes have been saved and synced.',
        PassportEventSubmitOutcome.queuedAuthRequired =>
          '$_eventType successful! Changes saved locally. Log in to sync this change.',
        PassportEventSubmitOutcome.queued =>
          '$_eventType successful! Changes have been saved locally and queued for sync.',
      };
      _closeForm(
        OperationSubmitResult(
          message: message,
          platformRef: widget.platform.platformRef,
        ),
      );
    }
  }

  List<Widget> _buildOtherFields() {
    final shipFields = [
      TextFormField(
        decoration: const InputDecoration(labelText: 'Ship IMO Number'),
        controller: _shipImoNumberController,
      ),
      TextFormField(
        decoration: const InputDecoration(labelText: 'Ship OVH Id'),
        controller: _shipOvhIdController,
      ),
      TextFormField(
        decoration: const InputDecoration(labelText: 'Ship Name'),
        controller: _shipNameController,
      ),
    ];

    if (_selectedAction == DeployAction.deploy) {
      return [
        DropdownButtonFormField<String>(
          initialValue: _selectedMethodCode,
          decoration: const InputDecoration(labelText: 'Method'),
          items: OceanopsCodes.deploymentMethodCodes
              .map((code) => DropdownMenuItem(value: code, child: Text(code)))
              .toList(),
          onChanged: (value) => setState(() => _selectedMethodCode = value),
        ),
        TextFormField(
          decoration: const InputDecoration(labelText: 'Max Water Depth (m)'),
          controller: _maxWaterDepthController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          validator: (value) => _validateOptionalNumber(value, 'Max Water Depth'),
        ),
        TextFormField(
          decoration: const InputDecoration(labelText: 'Elevation (m)'),
          controller: _elevationController,
          keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
          validator: (value) => _validateOptionalNumber(value, 'Elevation'),
        ),
        ...shipFields,
      ];
    }

    return [
      DropdownButtonFormField<String>(
        initialValue: _selectedEndingCauseCode,
        decoration: const InputDecoration(labelText: 'Ending Cause'),
        items: OceanopsCodes.endingCauseCodes.map((code) => DropdownMenuItem(value: code, child: Text(code))).toList(),
        onChanged: (value) => setState(() => _selectedEndingCauseCode = value),
      ),
      ...shipFields,
    ];
  }

  @override
  Widget build(BuildContext context) {
    // Listen for connectivity changes to update the UI accordingly.
    _connectivityState = ref.watch(checkConnectionProvider).value ?? ConnectivityResult.none;

    return Scaffold(
      appBar: TopNavigation(title: const Text('Record Operation'), leading: const BackButton()),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (_connectivityState == ConnectivityResult.none)
              const OfflineStatus(), // Show offline status if the device is offline.
            SectionContainer(
              child: Form(
                key: _formKey,
                child: Column(
                  spacing: 16,
                  children: [
                    Center(
                      child: SegmentedButton<DeployAction>(
                        segments: const [
                          ButtonSegment(value: DeployAction.deploy, label: Text('Deploy')),
                          ButtonSegment(value: DeployAction.recover, label: Text('Recover')),
                        ],
                        selected: {_selectedAction},
                        onSelectionChanged: (newSelection) {
                          setState(() => _selectedAction = newSelection.first);
                        },
                      ),
                    ),
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Wigos ID'),
                      initialValue: widget.platform.wigosId,
                      enabled: false, // Wigos ID is not editable.
                    ),
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Platform Category'),
                      initialValue: widget.platform.category,
                      enabled: false, // Platform Model is not editable.
                    ),
                    Row(
                      spacing: 8,
                      children: [
                        _AutofillLocationTimeControl(
                          active: useLiveLocation,
                          onPressed: toggleLiveUpdates,
                        ),
                        Expanded(
                          child: Column(
                            spacing: 16,
                            children: [
                              Row(
                                spacing: 8,
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      decoration: const InputDecoration(
                                        labelText: 'Latitude',
                                        errorMaxLines: 3,
                                      ),
                                      controller: _latitudeController,
                                      keyboardType: const TextInputType.numberWithOptions(
                                        signed: true,
                                        decimal: true,
                                      ),
                                      enabled: !useLiveLocation,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Latitude is required';
                                        }
                                        try {
                                          final latitude = double.parse(value);
                                          if (latitude < -90 || latitude > 90) {
                                            return 'Latitude must be between -90 and 90';
                                          }
                                        } on FormatException {
                                          return 'Latitude must be a valid number';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  Expanded(
                                    child: TextFormField(
                                      decoration: const InputDecoration(
                                        labelText: 'Longitude',
                                        errorMaxLines: 3,
                                      ),
                                      controller: _longitudeController,
                                      keyboardType: const TextInputType.numberWithOptions(
                                        signed: true,
                                        decimal: true,
                                      ),
                                      enabled: !useLiveLocation,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Longitude is required';
                                        }
                                        try {
                                          final longitude = double.parse(value);
                                          if (longitude < -180 || longitude > 180) {
                                            return 'Longitude must be between -180 and 180';
                                          }
                                        } on FormatException {
                                          return 'Longitude must be a valid number';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              TextFormField(
                                decoration: InputDecoration(
                                  labelText: '$_eventType Time (UTC)',
                                  errorMaxLines: 3,
                                ),
                                controller: _dateTimeController,
                                readOnly: true,
                                enabled: !useLiveLocation,
                                validator: (value) =>
                                    (value == null || value.isEmpty) ? '$_eventType Time is required' : null,
                                onTap: () async {
                                  final date = await showDatePicker(
                                    context: this.context,
                                    initialDate: _selectedDateTime ?? DateTime.now(),
                                    firstDate: DateTime(2000),
                                    lastDate: DateTime(2100),
                                    helpText: 'Date',
                                  );
                                  if (date == null) return;
                                  if (!mounted) return;
                                  final time = await showTimePicker(
                                    context: this.context,
                                    initialTime: _selectedDateTime != null
                                        ? TimeOfDay.fromDateTime(_selectedDateTime!)
                                        : TimeOfDay.now(),
                                    helpText: 'Time (UTC)',
                                  );
                                  if (time == null) return;
                                  if (!mounted) return;
                                  final combined = DateTime(
                                    date.year,
                                    date.month,
                                    date.day,
                                    time.hour,
                                    time.minute,
                                  );
                                  _setSelectedDateTime(combined);
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Notes'),
                      controller: _notesController,
                      maxLines: 3,
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Other fields', style: Theme.of(context).textTheme.titleMedium),
                    ),
                    ..._buildOtherFields(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      spacing: 16,
                      children: [
                        ElevatedButton(
                          onPressed: _submitInProgress ? null : _submitForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                          ),
                          child: Text('${_selectedAction.name.capitalize()} Platform'),
                        ),
                        ElevatedButton(
                          onPressed: _submitInProgress ? null : _closeForm,
                          child: const Text('Cancel'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AutofillLocationTimeControl extends StatelessWidget {
  const _AutofillLocationTimeControl({
    required this.active,
    required this.onPressed,
  });

  final bool active;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final accent = active ? colorScheme.primary : null;

    return Tooltip(
      message: active ? 'Stop autofill (location & time)' : 'Autofill location & time',
      child: TextButton(
        key: const Key('autofill-location-time'),
        onPressed: onPressed,
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          foregroundColor: accent,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.my_location, color: accent),
            const SizedBox(height: 4),
            Text(
              active ? 'Stop' : 'Autofill',
              style: theme.textTheme.labelSmall,
              textAlign: TextAlign.center,
            ),
            Text(
              active ? 'live' : 'loc. & time',
              style: theme.textTheme.labelSmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
