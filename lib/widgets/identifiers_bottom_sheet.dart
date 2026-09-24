import 'package:flutter/material.dart';
import 'package:smart_tags/models/platform.dart';
import 'package:smart_tags/widgets/common/container.dart';

/// Opens the identifiers bottom sheet for [platform] (#98).
Future<void> showIdentifiersBottomSheet(BuildContext context, {required Platform platform}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) => _IdentifiersBottomSheet(platform: platform),
  );
}

/// Bottom sheet listing a platform's identifiers (#98).
class _IdentifiersBottomSheet extends StatelessWidget {
  const _IdentifiersBottomSheet({required this.platform});

  final Platform platform;

  static const String _placeholder = '-';

  static String _dash(String? value) {
    if (value == null || value.trim().isEmpty) {
      return _placeholder;
    }
    return value.trim();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Identifiers',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  tooltip: 'Close',
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const Divider(height: 24),
            ContainerRow(label: 'Name', value: _dash(platform.name)),
            const Divider(height: 16),
            ContainerRow(label: 'Reference', value: _dash(platform.platformRef)),
            const Divider(height: 16),
            ContainerRow(label: 'Internal ID', value: _dash(platform.internalId)),
            const Divider(height: 16),
            ContainerRow(label: 'GTS-ID (WMO)', value: _dash(platform.gtsId)),
            const Divider(height: 16),
            ContainerRow(label: 'Serial number', value: _dash(platform.serial)),
            const Divider(height: 16),
            ContainerRow(label: 'Wigos ID', value: _dash(platform.wigosId)),
          ],
        ),
      ),
    );
  }
}
