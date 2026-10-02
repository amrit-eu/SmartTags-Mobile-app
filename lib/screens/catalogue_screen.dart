import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_tags/constants/platform_status_palette.dart';
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
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
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
                child: TopNavigation(
                  title: const Text('Platform Catalogue'),
                  backgroundColor: colorScheme.surface,
                  surfaceTintColor: Colors.transparent,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, showHistory ? 8 : 0),
              child: _CatalogueSearchChrome(
                searchFocusNode: _searchFocusNode,
                searchController: _searchController,
                searchQuery: _searchQuery,
                showHistory: showHistory,
                suggestions: suggestions,
                onSelectHistory: _applyHistoryEntry,
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
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
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
          CircleAvatar(
            radius: 36,
            backgroundColor: colorScheme.primaryContainer,
            child: Icon(icon, size: 36, color: colorScheme.onPrimaryContainer),
          ),
          const SizedBox(height: 20),
          Text(
            headline,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

/// Search field plus optional recent-history list in one surface (#143).
class _CatalogueSearchChrome extends StatelessWidget {
  const _CatalogueSearchChrome({
    required this.searchFocusNode,
    required this.searchController,
    required this.searchQuery,
    required this.showHistory,
    required this.suggestions,
    required this.onSelectHistory,
    required this.onClearHistory,
  });

  final FocusNode searchFocusNode;
  final TextEditingController searchController;
  final String searchQuery;
  final bool showHistory;
  final List<CatalogueSearchHistory> suggestions;
  final ValueChanged<String> onSelectHistory;
  final VoidCallback onClearHistory;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    const borderRadius = BorderRadius.all(Radius.circular(28));
    const closedShadow = [
      BoxShadow(
        color: Color(0x0D000000),
        blurRadius: 10,
        offset: Offset(0, 4),
      ),
    ];
    const openShadow = [
      BoxShadow(
        color: Color(0x14000000),
        blurRadius: 16,
        offset: Offset(0, 6),
      ),
      BoxShadow(
        color: Color(0x08000000),
        blurRadius: 4,
        offset: Offset(0, 1),
      ),
    ];

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: borderRadius,
        border: showHistory
            ? null
            : Border.all(color: colorScheme.outline.withValues(alpha: 0.35)),
        boxShadow: showHistory ? openShadow : closedShadow,
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SearchBar(
              focusNode: searchFocusNode,
              controller: searchController,
              hintText: 'Search by ID or Model',
              elevation: const WidgetStatePropertyAll(0),
              backgroundColor: WidgetStatePropertyAll(colorScheme.surface),
              side: const WidgetStatePropertyAll(BorderSide.none),
              overlayColor: const WidgetStatePropertyAll(Colors.transparent),
              leading: Icon(Icons.search, color: colorScheme.onSurfaceVariant),
              trailing: [
                if (searchQuery.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: searchController.clear,
                    style: IconButton.styleFrom(
                      hoverColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                    ),
                  ),
              ],
              onChanged: (_) {},
            ),
            if (showHistory) ...[
              Divider(height: 1, thickness: 1, color: colorScheme.outline.withValues(alpha: 0.45)),
              _LatestViewedPlatformsPanel(
                suggestions: suggestions,
                onSelect: onSelectHistory,
                onClearHistory: onClearHistory,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Recent catalogue platforms shown under the search field (#143).
class _LatestViewedPlatformsPanel extends StatefulWidget {
  const _LatestViewedPlatformsPanel({
    required this.suggestions,
    required this.onSelect,
    required this.onClearHistory,
  });

  /// Maximum history rows visible before the list scrolls inside the panel.
  static const int maxVisibleRows = 3;

  /// Fixed row height so exactly [maxVisibleRows] fit in the viewport.
  static const double historyRowHeight = 64;

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

    final colorScheme = theme.colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 8, 6),
          child: Row(
            children: [
              Icon(Icons.history_rounded, size: 18, color: colorScheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Latest viewed platforms',
                  key: const Key('catalogue-latest-viewed-platforms'),
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (suggestions.isNotEmpty)
                TextButton.icon(
                  key: const Key('catalogue-clear-search-history'),
                  onPressed: widget.onClearHistory,
                  icon: Icon(Icons.delete_outline, size: 18, color: colorScheme.error),
                  label: Text(
                    'Clear',
                    style: TextStyle(color: colorScheme.error),
                  ),
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                ),
            ],
          ),
        ),
        SizedBox(
          height: listViewportHeight,
          child: isEmpty
              ? Center(
                  child: Text(
                    'No recent platforms',
                    key: const Key('catalogue-search-history-empty'),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                )
              : ScrollbarTheme(
                  data: theme.scrollbarTheme.copyWith(
                    thumbVisibility: WidgetStateProperty.all(canScroll),
                    trackVisibility: WidgetStateProperty.all(canScroll),
                    thickness: WidgetStateProperty.all(canScroll ? 5.0 : null),
                    radius: const Radius.circular(8),
                    crossAxisMargin: 0,
                    mainAxisMargin: 6,
                  ),
                  child: Scrollbar(
                    controller: _historyScrollController,
                    thumbVisibility: canScroll,
                    trackVisibility: canScroll,
                    interactive: canScroll,
                    child: ListView.separated(
                      controller: _historyScrollController,
                      primary: false,
                      padding: const EdgeInsets.only(bottom: 8),
                      itemCount: suggestions.length,
                      separatorBuilder: (_, _) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Divider(height: 1, color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
                      ),
                      itemBuilder: (context, index) {
                        final entry = suggestions[index];
                        final subtitle = catalogueSearchHistorySubtitle(entry);
                        return SizedBox(
                          height: _LatestViewedPlatformsPanel.historyRowHeight,
                          child: _CatalogueHistoryRow(
                            key: Key('catalogue-search-history-${entry.platformRef}'),
                            platformRef: entry.platformRef,
                            subtitle: subtitle,
                            onTap: () => widget.onSelect(entry.platformRef),
                          ),
                        );
                      },
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}

class _CatalogueHistoryRow extends ConsumerWidget {
  const _CatalogueHistoryRow({
    required this.platformRef,
    required this.subtitle,
    required this.onTap,
    super.key,
  });

  final String platformRef;
  final String? subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final platform = ref.watch(platformByRefStreamProvider(platformRef)).value;
    final statusStyle = PlatformStatusPalette.resolve(platform?.status);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
        focusColor: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: statusStyle.backgroundColor,
                child: Icon(
                  Icons.sensors,
                  size: 20,
                  color: statusStyle.textColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      platformRef,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(Icons.north_west_rounded, size: 16, color: colorScheme.outline),
            ],
          ),
        ),
      ),
    );
  }
}
