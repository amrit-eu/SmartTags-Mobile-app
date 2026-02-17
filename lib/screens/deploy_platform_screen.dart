// Screen for with a form deploying or recovering a platform.
// Form fields:
// Platform ID
// Platform model
// Event type (deployment/recovery)
// location (editable)
// Time (UTC) (editable)
// Notes (editable)

import 'package:flutter/material.dart';
import 'package:smart_tags/extensions/string_extension.dart';
import 'package:smart_tags/widgets/common/container.dart';
import 'package:smart_tags/widgets/top_navigation.dart';

enum DeployAction { deploy, recover }

class DeployPlatformScreen extends StatefulWidget {
  const DeployPlatformScreen({super.key, required this.action, required this.platformID});
  final DeployAction action;
  final String platformID;

  @override
  State<DeployPlatformScreen> createState() => _DeployPlatformScreenState();
}

class _DeployPlatformScreenState extends State<DeployPlatformScreen> {
  final _modelController = TextEditingController();
  final _locationController = TextEditingController();
  final _timeController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _modelController.dispose();
    _locationController.dispose();
    _timeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _submitForm() {
    final eventType = widget.action == DeployAction.deploy ? 'Deployment' : 'Recovery';
    print('--- $eventType Form Submitted ---');
    print('Platform ID: ${widget.platformID}');
    print('Platform Model: ${_modelController.text}');
    print('Event Type: $eventType');
    print('Location: ${_locationController.text}');
    print('Time (UTC): ${_timeController.text}');
    print('Notes: ${_notesController.text}');
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
                      initialValue: widget.platformID,
                      enabled: false, // Platform ID is not editable.
                    ),
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Platform Model'),
                      controller: _modelController,
                      enabled: false, // Platform Model is not editable.
                    ),
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Location'),
                      controller: _locationController,
                    ),
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Time (UTC)'),
                      controller: _timeController,
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
