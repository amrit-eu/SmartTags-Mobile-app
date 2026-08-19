import 'dart:async';

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
import 'package:smart_tags/models/deploy_action.dart';
import 'package:smart_tags/models/passport_event.dart';
import 'package:smart_tags/models/platform.dart';
import 'package:smart_tags/providers/connection_provider.dart';
import 'package:smart_tags/providers/db_providers.dart';
import 'package:smart_tags/providers/passport_event_queue_provider.dart';
import 'package:smart_tags/widgets/common/collapsible_section.dart';
import 'package:smart_tags/widgets/common/container.dart';
import 'package:smart_tags/widgets/offline_status.dart';
import 'package:smart_tags/widgets/top_navigation.dart';

export 'package:smart_tags/models/deploy_action.dart';

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

  String get _eventType => widget.action == DeployAction.deploy ? 'Deployment' : 'Recovery';

  void setUseLiveLocation({required bool enabled}) {
    setState(() {
      useLiveLocation = enabled; // Set live location updates on or off based on the provided flag.
    });
    if (useLiveLocation) {
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
              if (mounted) setUseLiveLocation(enabled: false);
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
                if (mounted) setUseLiveLocation(enabled: false);
              });
            }
          },
        );
      }
    }
    // Cancel the listener subscriptions to stop battery drain
    if (!useLiveLocation) {
      unawaited(_liveLocationSubscription?.cancel());
      unawaited(_serviceStatusSubscription?.cancel());
    }
  }

  void toggleLiveUpdates() {
    setUseLiveLocation(enabled: !useLiveLocation); // Toggle the live location updates on or off.
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
    unawaited(_liveLocationSubscription?.cancel());
    unawaited(_serviceStatusSubscription?.cancel());
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
        Navigator.pop(context);
      }
      return;
    }

    final latitude = double.parse(_latitudeController.text);
    final longitude = double.parse(_longitudeController.text);
    final request = widget.action == DeployAction.deploy
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
        .enqueueOrSend(platformRef: widget.platform.platformRef, action: widget.action, request: request);

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
          operationalStatus: Value(widget.action == DeployAction.deploy ? 'Deployed' : 'Recovered'),
          status: Value(widget.platform.status.apiName),
          operationNotes: Value(_notesController.text),
        ),
      ]);
    } on Exception catch (e) {
      debugPrint('Error updating platform: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update platform.')),
        );
      }
      return;
    }

    // If successful, show a success message.
    if (mounted) {
      final message = switch (outcome) {
        PassportEventSubmitOutcome.sent => '$_eventType successful! Changes have been saved and synced.',
        PassportEventSubmitOutcome.queuedAuthRequired =>
          '$_eventType successful! Changes saved locally. Log in to sync this change.',
        PassportEventSubmitOutcome.queued =>
          '$_eventType successful! Changes have been saved locally and queued for sync.',
      };
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
      Navigator.pop(context);
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

    if (widget.action == DeployAction.deploy) {
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
      appBar: TopNavigation(title: Text('${widget.action.name.capitalize()} Platform'), leading: const BackButton()),
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
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Platform ID'),
                      initialValue: widget.platform.platformRef,
                      enabled: false, // Platform ID is not editable.
                    ),
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Platform Model'),
                      initialValue: widget.platform.model,
                      enabled: false, // Platform Model is not editable.
                    ),
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
                            keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
                            enabled: !useLiveLocation, // Disable manual input if using live location.
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
                            keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
                            enabled: !useLiveLocation, // Disable manual input if using live location.
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
                        IconButton(
                          icon: const Icon(Icons.my_location),
                          color: useLiveLocation ? Colors.lightBlue : null,
                          onPressed: toggleLiveUpdates,
                          tooltip: useLiveLocation ? 'Disable live location updates' : 'Enable live location updates',
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
                      enabled: !useLiveLocation, // Disable manual input if using live location time.
                      validator: (value) => (value == null || value.isEmpty) ? '$_eventType Time is required' : null,
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
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Notes'),
                      controller: _notesController,
                      maxLines: 3,
                    ),
                    CollapsibleSection(title: 'Other fields', children: _buildOtherFields()),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      spacing: 16,
                      children: [
                        ElevatedButton(
                          onPressed: _submitForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                          ),
                          child: Text('${widget.action.name.capitalize()} Platform'),
                        ),
                        ElevatedButton(onPressed: () => {Navigator.pop(context)}, child: const Text('Cancel')),
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
