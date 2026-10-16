import 'package:flutter/material.dart';
import 'package:smart_tags/widgets/common/app_status_banner.dart';

/// Shared progress strip used for first-load sync and pull-to-refresh.
class PlatformsLoadingBanner extends StatelessWidget {
  /// Creates a [PlatformsLoadingBanner].
  const PlatformsLoadingBanner({
    super.key,
    this.message = 'Downloading platforms…',
    this.progress,
  });

  /// Status text shown under the progress bar.
  final String message;

  /// Optional determinate progress `0..1`. When null, the bar is indeterminate.
  final double? progress;

  @override
  Widget build(BuildContext context) {
    return AppStatusBanner(
      message: message,
      showProgress: true,
      progress: progress,
    );
  }
}
