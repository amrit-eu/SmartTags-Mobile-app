import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_tags/database/db.dart';
import 'package:smart_tags/providers/db_providers.dart';
import 'package:smart_tags/providers/platforms_refresh_provider.dart';
import 'package:smart_tags/providers/qr_passport_lookup_provider.dart';
import 'package:smart_tags/widgets/platform_card.dart';
import 'package:smart_tags/widgets/pull_to_refresh.dart';
import 'package:smart_tags/widgets/top_navigation.dart';

/// A screen that displays a searchable catalogue of platforms.
class CatalogueScreen extends ConsumerStatefulWidget {
  /// Creates a [CatalogueScreen].
  const CatalogueScreen({super.key, this.onScanAgain});

  /// Selects the scanner tab after an empty QR lookup.
  final VoidCallback? onScanAgain;

  @override
  ConsumerState<CatalogueScreen> createState() => _CatalogueScreenState();
}

class _CatalogueScreenState extends ConsumerState<CatalogueScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refreshPlatforms() async {
    if (ref.read(qrPassportLookupProvider).phase != QrLookupPhase.idle) {
      await ref.read(qrPassportLookupProvider.notifier).retry();
      return;
    }
    // Errors are shown by [InitialSyncShell] (top banner + Retry).
    await ref.read(platformsRefreshProvider.notifier).refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PullToRefresh(
        // Header + search bar: same pull-from-top chrome as the map.
        edgeStartMaxY: kToolbarHeight + 88,
        onRefresh: _refreshPlatforms,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: kToolbarHeight,
              child: TopNavigation(title: const Text('Platform Catalogue')),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: SearchBar(
                controller: _searchController,
                hintText: 'Search by ID or Model',
                leading: const Icon(Icons.search),
                trailing: [
                  if (_searchQuery.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: _searchController.clear,
                    ),
                ],
                onChanged: (value) {
                  // State updates via listener
                },
              ),
            ),
            if (ref.watch(qrPassportLookupProvider).phase != QrLookupPhase.idle)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    const Expanded(child: Text('Results for scanned QR code')),
                    TextButton(
                      onPressed: () {
                        ref.read(qrPassportLookupProvider.notifier).clear();
                        _searchController.clear();
                      },
                      child: const Text('Clear scan'),
                    ),
                  ],
                ),
              ),
            Expanded(child: _buildResults()),
          ],
        ),
      ),
    );
  }

  Widget _buildResults() {
    final scan = ref.watch(qrPassportLookupProvider);
    switch (scan.phase) {
      case QrLookupPhase.loading:
        return const Center(child: CircularProgressIndicator());
      case QrLookupPhase.error:
        return _scanMessage(
          scan.message ?? 'Could not look up passports for this QR code.',
          'Retry lookup',
          () => ref.read(qrPassportLookupProvider.notifier).retry(),
        );
      case QrLookupPhase.data:
        final query = _searchQuery.toLowerCase();
        final platforms = scan.result!.platforms.where((platform) {
          return platform.ref.toLowerCase().contains(query) || platform.model.toLowerCase().contains(query);
        }).toList();
        if (scan.result!.platforms.isEmpty) {
          return _scanMessage('No passports available for this QR code', 'Scan again', () {
            ref.read(qrPassportLookupProvider.notifier).clear();
            _searchController.clear();
            widget.onScanAgain?.call();
          });
        }
        if (platforms.isEmpty) {
          return _scanMessage('No results found', 'Clear search', _searchController.clear);
        }
        return _platformGrid(platforms);
      case QrLookupPhase.idle:
        break;
    }
    if (_searchQuery.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 120),
          Center(
            child: Text('Enter a platform ID or model to search'),
          ),
        ],
      );
    }

    return ref
        .watch(platformsWatchProvider(_searchQuery))
        .when(
          data: (platforms) {
            if (platforms.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 120),
                  Center(child: Text('No results found')),
                ],
              );
            }

            return _platformGrid(platforms);
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) {
            if (kDebugMode) {
              debugPrint('Error: $error \n Stack: $stack');
            }
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [
                SizedBox(height: 120),
                Center(child: Text('Failed to fetch platforms')),
              ],
            );
          },
        );
  }

  Widget _scanMessage(String message, String action, VoidCallback onPressed) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 100),
        Center(child: Text(message, textAlign: TextAlign.center)),
        Center(
          child: TextButton(onPressed: onPressed, child: Text(action)),
        ),
      ],
    );
  }

  Widget _platformGrid(List<Platform> platforms) {
    return GridView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 400,
        mainAxisExtent: 150,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: platforms.length,
      itemBuilder: (context, index) => PlatformCard(platform: platforms[index]),
    );
  }
}
