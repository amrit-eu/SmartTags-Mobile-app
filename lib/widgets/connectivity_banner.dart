import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_tags/helpers/connection_message.dart';
import 'package:smart_tags/providers/connection_provider.dart';
import 'package:smart_tags/providers/db_providers.dart';
import 'package:smart_tags/widgets/common/app_status_banner.dart';

/// Persistent offline indicator shown in the main shell when local data exists.
class ConnectivityBanner extends ConsumerStatefulWidget {
  /// Creates a [ConnectivityBanner].
  const ConnectivityBanner({super.key});

  @override
  ConsumerState<ConnectivityBanner> createState() =>
      _ConnectivityBannerState();
}

class _ConnectivityBannerState
    extends ConsumerState<ConnectivityBanner> {
  bool _dismissed = false;

  @override
  Widget build(BuildContext context) {
    ref.listen(checkConnectionProvider, (previous, next) {
      if (_dismissed && isDeviceOnline(next.value)) {
        setState(() {
          _dismissed = false;
        });
      }
    });

    final connectivity = ref.watch(checkConnectionProvider).value;

    if (isDeviceOnline(connectivity)) {
      return const SizedBox.shrink();
    }

    final platformCount =
        ref.watch(platformsStreamProvider).value?.length ?? 0;

    if (platformCount == 0 || _dismissed) {
      // First-load empty state is handled by [InitialSyncShell].
      return const SizedBox.shrink();
    }

    return AppStatusBanner(
      message: 'Offline — showing local data',
      severity: AppStatusBannerSeverity.warning,
      icon: Icons.wifi_off,
      onDismiss: () {
        setState(() {
          _dismissed = true;
        });
      },
    );
  }
}
