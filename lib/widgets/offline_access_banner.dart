import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_tags/providers/offline_access_provider.dart';
import 'package:smart_tags/screens/user_login.dart';
import 'package:smart_tags/widgets/common/app_status_banner.dart';

/// Persistent indicator shown when the signed-in user's offline access has
/// expired: protected actions are unavailable until they log in again online.
/// Cached data and queued operations remain available.
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
    ref.listen(offlineAccessExpiredProvider, (previous, next) {
      // Reset once access is restored, so the banner shows again if it recurs.
      if (_dismissed && !next) {
        setState(() {
          _dismissed = false;
        });
      }
    });

    if (!ref.watch(offlineAccessExpiredProvider) || _dismissed) {
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
