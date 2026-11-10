import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_tags/helpers/connection_message.dart';
import 'package:smart_tags/providers/connection_provider.dart';
import 'package:smart_tags/providers/offline_access_provider.dart';
import 'package:smart_tags/screens/user_login.dart';
import 'package:smart_tags/widgets/common/app_status_banner.dart';

/// Whether access has expired while the device is known to be offline.
final _showBannerProvider = Provider<bool>((ref) {
  if (!ref.watch(offlineAccessExpiredProvider)) return false;
  final connectivity = ref.watch(checkConnectionProvider);
  return connectivity.hasValue && !isDeviceOnline(connectivity.value);
});

/// Persistent indicator shown while offline when the signed-in user's offline
/// access has expired: protected actions are unavailable until they log in
/// again online. Cached data and queued operations remain available.
///
/// Hidden while online: the session is then renewed in the background, and a
/// rejected renewal is reported by the session-expired notification instead.
class OfflineAccessBanner extends ConsumerStatefulWidget {
  /// Creates an [OfflineAccessBanner].
  const OfflineAccessBanner({super.key});

  @override
  ConsumerState<OfflineAccessBanner> createState() => _OfflineAccessBannerState();
}

class _OfflineAccessBannerState extends ConsumerState<OfflineAccessBanner> {
  bool _dismissed = false;

  @override
  Widget build(BuildContext context) {
    ref.listen(_showBannerProvider, (previous, next) {
      // Reset once the condition resolves, so the banner shows again if it recurs.
      if (_dismissed && !next) {
        setState(() {
          _dismissed = false;
        });
      }
    });

    if (!ref.watch(_showBannerProvider) || _dismissed) {
      return const SizedBox.shrink();
    }

    return AppStatusBanner(
      message: offlineAccessExpiredMessage,
      severity: AppStatusBannerSeverity.warning,
      icon: Icons.lock_clock,
      actionLabel: 'Log in',
      onAction: () async {
        await Navigator.of(context).push(
          MaterialPageRoute<UserLoginScreen>(builder: (_) => const UserLoginScreen()),
        );
      },
      onDismiss: () {
        setState(() {
          _dismissed = true;
        });
      },
    );
  }
}
