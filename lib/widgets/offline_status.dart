import 'package:flutter/material.dart';
import 'package:smart_tags/widgets/common/app_status_banner.dart';

/// Displays a dismissible warning while recording an operation offline.
class OfflineStatus extends StatefulWidget {
  /// Creates an [OfflineStatus].
  const OfflineStatus({super.key});

  @override
  State<OfflineStatus> createState() => _OfflineStatusState();
}

class _OfflineStatusState extends State<OfflineStatus> {
  bool _dismissed = false;

  @override
  Widget build(BuildContext context) {
    if (_dismissed) {
      return const SizedBox.shrink();
    }

    return AppStatusBanner(
      message: 'You are offline. Changes will be saved locally and synced when you are back online.',
      severity: AppStatusBannerSeverity.warning,
      icon: Icons.signal_wifi_off,
      onDismiss: () {
        setState(() {
          _dismissed = true;
        });
      },
    );
  }
}
