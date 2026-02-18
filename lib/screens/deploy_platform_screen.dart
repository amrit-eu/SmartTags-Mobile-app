// Screen for with a form deploying or recovering a platform.
// Form fields:
// Platform ID
// Platform model
// Event type (deployment/recovery)
// location (editable)
// Time (UTC) (editable)
// Notes (editable)

import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:smart_tags/database/db.dart' hide Platform;
import 'package:smart_tags/extensions/string_extension.dart';
import 'package:smart_tags/helpers/location/location_fetcher.dart';
import 'package:smart_tags/models/platform.dart';
import 'package:smart_tags/providers/db_providers.dart';
import 'package:smart_tags/widgets/common/container.dart';
import 'package:smart_tags/widgets/top_navigation.dart';

enum DeployAction { deploy, recover }

class DeployPlatformScreen extends ConsumerStatefulWidget {
  const DeployPlatformScreen({super.key, required this.action, required this.platform});
  final DeployAction action;
  final Platform platform;

  @override
  ConsumerState<DeployPlatformScreen> createState() => _DeployPlatformScreenState();
}

class _DeployPlatformScreenState extends ConsumerState<DeployPlatformScreen> {
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  final _dateTimeController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime? _selectedDateTime;

  String get _eventType => widget.action == DeployAction.deploy ? 'Deployment' : 'Recovery';

  @override
  void dispose() {
    _latitudeController.dispose();
    _longitudeController.dispose();
    _dateTimeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    final eventType = _eventType;
    debugPrint('--- $eventType Form Submitted ---');
    debugPrint('Platform ID: ${widget.platform.platformId}');
    debugPrint('Platform Model:${widget.platform.model}');
    debugPrint('Event Type: $eventType');
    debugPrint('Latitude: ${_latitudeController.text}');
    debugPrint('Longitude: ${_longitudeController.text}');
    debugPrint('Time (UTC): ${_dateTimeController.text}');
    debugPrint('Notes: ${_notesController.text}');

    // Attempt to update the record in the local sqlite database.
    try {
    await ref.read(databaseProvider).updatePlatforms(
      [
        PlatformsCompanion(
          ref: Value(widget.platform.platformId),
          model: Value(widget.platform.model),
          lat: Value(double.parse(_latitudeController.text)),
          lon: Value(double.parse(_longitudeController.text)),
          lastUpdated: Value(_selectedDateTime ?? DateTime.now()),
          operationLat: Value(widget.platform.operationLocation.latitude),
          operationLon: Value(widget.platform.operationLocation.longitude),
          operationalStatus: Value(widget.action == DeployAction.deploy ? 'Deployed' : 'Recovered'),
          status: Value(PlatformStatus.platformStatusToDb(widget.platform.status)),
        ),
      ]
    );
    } on Exception catch (e) {
      debugPrint('Error updating platform: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update platform: $e')),
        );
      }
      return;
    }
    // If successful, pop the screen and show a success message.
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$eventType successful!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopNavigation(title: Text('${widget.action.name.capitalize()} Platform'), leading: const BackButton()),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SectionContainer(
              child: Form(
                child: Column(
                  spacing: 16,
                  children: [
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Platform ID'),
                      initialValue: widget.platform.platformId,
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
                            decoration: const InputDecoration(labelText: 'Latitude'),
                            controller: _latitudeController,
                            keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
                          ),
                        ),
                        Expanded(
                          child: TextFormField(
                            decoration: const InputDecoration(labelText: 'Longitude'),
                            controller: _longitudeController,
                            keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.my_location),
                          onPressed: () async {
                            final locationFetcher = LocationFetcher();
                            final location = await locationFetcher.getUserLocation();
                            if (location != null) {
                              setState(() {
                                _latitudeController.text = location.latitude.toStringAsFixed(6);
                                _longitudeController.text = location.longitude.toStringAsFixed(6);
                              });
                            } else {
                              if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Failed to fetch location. Please enter manually.')),
                              );
                              }
                            }
                          },
                        ),
                      ],
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: '$_eventType Time (UTC)'),
                      controller: _dateTimeController,
                      readOnly: true,
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _selectedDateTime ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                          helpText: 'Date',
                        );
                        if (date == null) return;
                        if (!context.mounted) return;
                        final time = await showTimePicker(
                          context: context,
                          initialTime: _selectedDateTime != null
                              ? TimeOfDay.fromDateTime(_selectedDateTime!)
                              : TimeOfDay.now(),
                          helpText: 'Time (UTC)',
                        );
                        if (time == null) return;
                        final combined = DateTime(
                          date.year, date.month, date.day,
                          time.hour, time.minute,
                        );
                        setState(() {
                          _selectedDateTime = combined;
                          _dateTimeController.text = DateFormat(
                            'MMM dd, yyyy, hh:mm a',
                          ).format(combined);
                        });
                      },
                    ),
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Notes'),
                      controller: _notesController,
                      maxLines: 3,
                    ),
                    ElevatedButton(
                      onPressed: _submitForm,
                      child: Text('${widget.action.name.capitalize()} Platform'),
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
