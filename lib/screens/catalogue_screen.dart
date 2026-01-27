import 'dart:async';

import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:smart_tags/database/db.dart';
import 'package:smart_tags/models/platform.dart' as model;
import 'package:smart_tags/screens/platform_detail_screen.dart';

/// A screen that displays a searchable catalogue of platforms.
class CatalogueScreen extends StatefulWidget {
  /// Creates a [CatalogueScreen].
  const CatalogueScreen({
    required this.database,
    super.key,
  });

  /// The local database instance.
  final AppDatabase database;

  @override
  State<CatalogueScreen> createState() => _CatalogueScreenState();
}

class _CatalogueScreenState extends State<CatalogueScreen> {
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
                : StreamBuilder<List<Platform>>(
                    stream: widget.database.watchPlatforms(query: _searchQuery),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }

                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final platforms = snapshot.data!;

                      if (platforms.isEmpty) {
                        return const Center(
                          child: Text('No results found'),
                        );
                      }

                      return ListView.separated(
                        itemCount: platforms.length,
                        separatorBuilder: (context, index) => const Divider(),
                        itemBuilder: (context, index) {
                          final platform = platforms[index];
                          return ListTile(
                            title: Text(platform.model),
                            subtitle: Text(platform.ref),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () {
                              final platformModel = model.Platform(
                                id: platform.ref,
                                model: platform.model,
                                network: platform.network,
                                latestPosition: LatLng(platform.lat, platform.lon),
                                status: platform.status == 'Active'
                                    ? model.PlatformStatus.active
                                    : model.PlatformStatus.inactive,
                                operationalStatus: platform.operationalStatus == 'Deployed'
                                    ? model.OperationalStatus.deployed
                                    : model.OperationalStatus.recovered,
                                lastUpdated: platform.lastUpdated,
                                operationLocation: LatLng(
                                  platform.operationLat,
                                  platform.operationLon,
                                ),
                              );
                              unawaited(
                                Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (context) => PlatformDetailScreen(platform: platformModel),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
