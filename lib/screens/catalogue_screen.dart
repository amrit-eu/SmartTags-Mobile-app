import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_tags/components/platform_card.dart';
import 'package:smart_tags/providers.dart';

/// A screen that displays a searchable catalogue of platforms.
class CatalogueScreen extends ConsumerStatefulWidget {
  /// Creates a [CatalogueScreen].
  const CatalogueScreen({super.key});

  /// The local database instance.

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Platforms'),
      ),
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
            child: _searchQuery.isEmpty
                ? const Center(
                    child: Text('Enter a platform ID or model to search'),
                  )
                : ref
                      .watch(platformsWatchProvider(_searchQuery))
                      .when(
                        data: (platforms) {
                          if (platforms.isEmpty) {
                            return const Center(
                              child: Text('No results found'),
                            );
                          }

                          return GridView.builder(
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
                        error: (error, stack) => Center(child: Text('Error: $error')),
                      ),
          ),
        ],
      ),
    );
  }
}
