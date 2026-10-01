import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_tags/database/db.dart';
import 'package:smart_tags/helpers/catalogue_search_history_filter.dart';
import 'package:smart_tags/providers/catalogue_search_history_provider.dart';
import 'package:smart_tags/providers/db_providers.dart';
import 'package:smart_tags/providers/platforms_refresh_provider.dart';
import 'package:smart_tags/widgets/platform_card.dart';
import 'package:smart_tags/widgets/pull_to_refresh.dart';
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
  final FocusNode _searchFocusNode = FocusNode();
  String _searchQuery = '';

  /// Keeps the latest-viewed panel open after clear history (#143).
  bool _keepLatestViewedPanelOpen = false;

  /// While the clear-history dialog is open, ignore focus loss on the search field.
  bool _clearHistoryDialogOpen = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
    _searchFocusNode.addListener(() {
      if (!_searchFocusNode.hasFocus && !_clearHistoryDialogOpen) {
        _keepLatestViewedPanelOpen = false;
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refreshPlatforms() async {
    // Errors are shown by [InitialSyncShell] (top banner + Retry).
    await ref.read(platformsRefreshProvider.notifier).refresh();
  }

  void _applyHistoryEntry(String platformRef) {
    _searchController
      ..text = platformRef
      ..selection = TextSelection.collapsed(offset: platformRef.length);
    _searchFocusNode.unfocus();
  }

  void _closeSearchHistory() {
    if (_clearHistoryDialogOpen) {
      return;
    }
    _keepLatestViewedPanelOpen = false;
    if (_searchFocusNode.hasFocus) {
      _searchFocusNode.unfocus();
    }
  }

  Future<void> _confirmClearSearchHistory() async {
    setState(() {
      _keepLatestViewedPanelOpen = true;
      _clearHistoryDialogOpen = true;
    });

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear history?'),
        content: const Text('Remove all latest viewed platforms from this device.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (!mounted) {
      return;
    }

    setState(() => _clearHistoryDialogOpen = false);
    _searchFocusNode.requestFocus();

    if (confirmed ?? false) {
      await clearCatalogueSearchHistory(ref);
      if (mounted) {
        setState(() => _keepLatestViewedPanelOpen = true);
        _searchFocusNode.requestFocus();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final historyAsync = ref.watch(catalogueSearchHistoryProvider);
    final history = historyAsync.value ?? const [];
    final suggestions = filterCatalogueSearchHistory(history, _searchQuery);
    final showHistory =
        _keepLatestViewedPanelOpen || (_searchFocusNode.hasFocus && suggestions.isNotEmpty);

    return Scaffold(
      body: PullToRefresh(
        // Header + search bar: same pull-from-top chrome as the map.
        edgeStartMaxY: kToolbarHeight + 88,
        onRefresh: _refreshPlatforms,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GestureDetector(
              onTap: _closeSearchHistory,
              behavior: HitTestBehavior.translucent,
              child: SizedBox(
                height: kToolbarHeight,
                child: TopNavigation(title: const Text('Platform Catalogue')),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: SearchBar(
                focusNode: _searchFocusNode,
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
            if (showHistory)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: _LatestViewedPlatformsPanel(
                  suggestions: suggestions,
                  onSelect: _applyHistoryEntry,
                  onClearHistory: _confirmClearSearchHistory,
                ),
              ),
            Expanded(
              child: GestureDetector(
                onTap: _closeSearchHistory,
                behavior: HitTestBehavior.translucent,
                child: _buildResults(hideEmptyPrompt: showHistory && _searchQuery.trim().isEmpty),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResults({required bool hideEmptyPrompt}) {
    if (_searchQuery.isEmpty) {
      if (hideEmptyPrompt) {
        return const SizedBox.shrink();
      }
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 96),
          Center(
            child: _CataloguePlaceholder(
              icon: Icons.manage_search_rounded,
              headline: 'Start searching',
              message: 'Enter a platform ID or model to search',
            ),
          ),
        ],
      );
    }

    return ref.watch(platformsWatchProvider(_searchQuery)).when(
      data: (platforms) {
        if (platforms.isEmpty) {
          return ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: const [
              SizedBox(height: 96),
              Center(
                child: _CataloguePlaceholder(
                  icon: Icons.search_off_rounded,
                  headline: 'No results found',
                  message: 'Try another ID, model, or WIGOS identifier',
                ),
              ),
            ],
          );
        }

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
          itemBuilder: (context, index) {
            final platform = platforms[index];
            return PlatformCard(
              platform: platform,
              onBeforeOpen: () => recordCatalogueSearchHistory(
                ref,
                platformRef: platform.ref,
                platformModel: platform.model,
                wigosId: platform.wigosId,
              ),
            );
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
            SizedBox(height: 96),
            Center(
              child: _CataloguePlaceholder(
                icon: Icons.cloud_off_outlined,
                headline: 'Failed to fetch platforms',
                message: 'Pull down to refresh and try again',
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Empty / no-results messaging for the catalogue tab.
class _CataloguePlaceholder extends StatelessWidget {
  const _CataloguePlaceholder({
    required this.icon,
    required this.headline,
    required this.message,
  });

  final IconData icon;
  final String headline;
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colorScheme.primaryContainer,
                  Color.alphaBlend(
                    colorScheme.primary.withValues(alpha: 0.12),
                    colorScheme.surface,
                  ),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.primary.withValues(alpha: 0.22),
                  blurRadius: 28,
                  spreadRadius: -4,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Icon(icon, size: 44, color: colorScheme.primary),
            ),
          ),
          const SizedBox(height: 28),
          ShaderMask(
            blendMode: BlendMode.srcIn,
            shaderCallback: (bounds) => LinearGradient(
              colors: [
                colorScheme.primary,
                Color.lerp(colorScheme.primary, colorScheme.tertiary, 0.45)!,
              ],
            ).createShader(bounds),
            child: Text(
              headline,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: 0.15,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.78),
              fontWeight: FontWeight.w500,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

/// In-flow list of recently opened catalogue platforms (#143).
class _LatestViewedPlatformsPanel extends StatefulWidget {
  const _LatestViewedPlatformsPanel({
    required this.suggestions,
    required this.onSelect,
    required this.onClearHistory,
  });

  /// Maximum history rows visible before the list scrolls inside the panel.
  static const int maxVisibleRows = 3;

  /// Fixed row height so exactly [maxVisibleRows] fit in the viewport.
  static const double historyRowHeight = 76;

  final List<CatalogueSearchHistory> suggestions;
  final ValueChanged<String> onSelect;
  final VoidCallback onClearHistory;

  @override
  State<_LatestViewedPlatformsPanel> createState() => _LatestViewedPlatformsPanelState();
}

class _LatestViewedPlatformsPanelState extends State<_LatestViewedPlatformsPanel> {
  final ScrollController _historyScrollController = ScrollController();

  @override
  void dispose() {
    _historyScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final suggestions = widget.suggestions;
    final isEmpty = suggestions.isEmpty;
    final canScroll = suggestions.length > _LatestViewedPlatformsPanel.maxVisibleRows;
    final visibleRowCount =
        isEmpty ? 1 : suggestions.length.clamp(0, _LatestViewedPlatformsPanel.maxVisibleRows);
    final listViewportHeight = visibleRowCount * _LatestViewedPlatformsPanel.historyRowHeight +
        (visibleRowCount > 1 ? visibleRowCount - 1 : 0);

    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      color: theme.colorScheme.surfaceContainerHighest,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 4, 4, 0),
            child: Row(
              children: [
                const SizedBox(width: 48),
                Expanded(
                  child: Text(
                    'Latest viewed platforms',
                    key: const Key('catalogue-latest-viewed-platforms'),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (suggestions.isNotEmpty)
                  IconButton(
                    key: const Key('catalogue-clear-search-history'),
                    icon: const Icon(Icons.delete_outline),
                    tooltip: 'Clear history',
                    onPressed: widget.onClearHistory,
                  )
                else
                  const SizedBox(width: 48),
              ],
            ),
          ),
          const Divider(height: 1),
          SizedBox(
            height: listViewportHeight,
            child: isEmpty
                ? Center(
                    child: Text(
                      'No recent platforms',
                      key: const Key('catalogue-search-history-empty'),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  )
                : ScrollbarTheme(
                    data: theme.scrollbarTheme.copyWith(
                      thumbVisibility: WidgetStateProperty.all(canScroll),
                      trackVisibility: WidgetStateProperty.all(canScroll),
                      thickness: WidgetStateProperty.all(canScroll ? 6.0 : null),
                      radius: const Radius.circular(8),
                      crossAxisMargin: 2,
                      mainAxisMargin: 4,
                    ),
                    child: Scrollbar(
                      controller: _historyScrollController,
                      thumbVisibility: canScroll,
                      trackVisibility: canScroll,
                      interactive: true,
                      child: ListView.separated(
                        controller: _historyScrollController,
                        primary: false,
                        padding: EdgeInsets.zero,
                        itemCount: suggestions.length,
                        separatorBuilder: (_, _) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final entry = suggestions[index];
                          final subtitle = catalogueSearchHistorySubtitle(entry);
                          return SizedBox(
                            height: _LatestViewedPlatformsPanel.historyRowHeight,
                            child: ListTile(
                              key: Key('catalogue-search-history-${entry.platformRef}'),
                              leading: const Icon(Icons.history),
                              title: Text(entry.platformRef),
                              subtitle: subtitle != null
                                  ? Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis)
                                  : null,
                              onTap: () => widget.onSelect(entry.platformRef),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
