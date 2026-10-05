import 'package:smart_tags/database/db.dart';

/// Filters [entries] to those matching [query] on ref or model (#143).
List<CatalogueSearchHistory> filterCatalogueSearchHistory(
  List<CatalogueSearchHistory> entries,
  String query,
) {
  final normalized = query.trim().toLowerCase();
  if (normalized.isEmpty) {
    return entries;
  }
  return entries
      .where(
        (entry) =>
            entry.platformRef.toLowerCase().startsWith(normalized) ||
            (entry.platformModel?.toLowerCase().startsWith(normalized) ?? false) ||
            (entry.wigosId?.toLowerCase().startsWith(normalized) ?? false),
      )
      .toList();
}

/// Subtitle for a history row: model and WIGOS / passport id when known (#143).
String? catalogueSearchHistorySubtitle(CatalogueSearchHistory entry) {
  final parts = <String>[];
  final model = entry.platformModel?.trim();
  final wigos = entry.wigosId?.trim();
  if (model != null && model.isNotEmpty) {
    parts.add(model);
  }
  if (wigos != null && wigos.isNotEmpty) {
    parts.add(wigos);
  }
  if (parts.isEmpty) {
    return null;
  }
  return parts.join(' · ');
}
