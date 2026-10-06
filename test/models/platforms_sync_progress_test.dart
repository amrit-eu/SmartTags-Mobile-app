import 'package:flutter_test/flutter_test.dart';
import 'package:smart_tags/models/platforms_sync_phase.dart';
import 'package:smart_tags/models/platforms_sync_progress.dart';

void main() {
  test('bannerMessage shows N/M when counts are set', () {
    const progress = PlatformsSyncProgress(completed: 12, total: 120);
    expect(
      progress.bannerMessage(PlatformsSyncPhase.saving),
      'Saving platforms…',
    );
    expect(progress.fraction, closeTo(0.1, 0.001));
  });

  test('bannerMessage falls back when counts missing', () {
    const progress = PlatformsSyncProgress.empty();
    expect(
      progress.bannerMessage(PlatformsSyncPhase.downloading),
      'Downloading platforms…',
    );
    expect(progress.fraction, isNull);
  });
}
