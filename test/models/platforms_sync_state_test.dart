import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_tags/models/platforms_sync_phase.dart';
import 'package:smart_tags/models/platforms_sync_state.dart';
import 'package:smart_tags/providers/platforms_sync_phase_provider.dart';

void main() {
  group('PlatformsSyncState.downloadProgress', () {
    test('returns null when content length is unset during download', () {
      const state = PlatformsSyncState(phase: PlatformsSyncPhase.downloading);
      expect(state.downloadProgress, isNull);
    });

    test('returns null when content length is unknown', () {
      const state = PlatformsSyncState(
        phase: PlatformsSyncPhase.downloading,
        downloadBytesReceived: 100,
      );
      expect(state.downloadProgress, isNull);
    });

    test('returns fraction when length is known', () {
      const state = PlatformsSyncState(
        phase: PlatformsSyncPhase.downloading,
        downloadBytesReceived: 50,
        downloadContentLength: 100,
      );
      expect(state.downloadProgress, 0.5);
    });
  });

  test('late download progress does not clobber saving phase', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(platformsSyncPhaseProvider.notifier)
      ..setDownloading(contentLength: 100)
      ..updateDownloadProgress(bytesReceived: 100, contentLength: 100)
      ..setSaving();
    notifier.updateDownloadProgress(bytesReceived: 100, contentLength: 100);
    expect(container.read(platformsSyncPhaseProvider).phase, PlatformsSyncPhase.saving);
  });
}
