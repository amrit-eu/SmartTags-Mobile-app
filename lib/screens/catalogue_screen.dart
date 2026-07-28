import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_tags/providers/db_providers.dart';
import 'package:smart_tags/providers/platforms_refresh_provider.dart';
import 'package:smart_tags/widgets/platform_card.dart';
import 'package:smart_tags/widgets/top_navigation.dart';

/// A screen that displays a searchable catalogue of platforms.
class CatalogueScreen extends ConsumerStatefulWidget {
  /// Creates a [CatalogueScreen].
  const CatalogueScreen({super.key});

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
    await ref.read(platformsRefreshProvider.notifier).refresh();
    if (!mounted) {
      return;
    }

    final refresh = ref.read(platformsRefreshProvider);
    if (refresh.hasError) {
      final error = refresh.error!;
      // Full details are already logged by PlatformsRefreshNotifier / GatewayRepository.
      final message = error is StateError
          ? error.message
          : 'Could not refresh platforms';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopNavigation(title: const Text('Platform Catalogue')),
      body: Column(
        children: [
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
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshPlatforms,
              child: _searchQuery.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: const [
                        SizedBox(height: 120),
                        Center(
                          child: Text('Enter a platform ID or model to search'),
                        ),
                      ],
                    )
                  : ref.watch(platformsWatchProvider(_searchQuery)).when(
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

                          return GridView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 400,
                              mainAxisExtent: 180,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                            itemCount: platforms.length,
                            itemBuilder: (context, index) {
                              return PlatformCard(platform: platforms[index]);
                            },
                          );
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
                      ),
            ),
          ),
        ],
      ),
    );
  }
}
