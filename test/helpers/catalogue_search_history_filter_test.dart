import 'package:flutter_test/flutter_test.dart';
import 'package:smart_tags/database/db.dart';
import 'package:smart_tags/helpers/catalogue_search_history_filter.dart';

void main() {
  CatalogueSearchHistory entry({required String ref, String? model, String? wigosId}) {
    return CatalogueSearchHistory(
      id: 1,
      platformRef: ref,
      platformModel: model,
      wigosId: wigosId,
      searchedAt: DateTime.utc(2026),
    );
  }

  test('filter returns all entries when query is empty', () {
    final entries = [entry(ref: '5904198', model: 'Float')];
    expect(filterCatalogueSearchHistory(entries, ''), entries);
  });

  test('filter matches platform ref and model', () {
    final entries = [
      entry(ref: '5904198', model: 'SOLO'),
      entry(ref: 'PLT-002', model: 'Drifting Buoy'),
    ];
    expect(filterCatalogueSearchHistory(entries, '590'), hasLength(1));
    expect(filterCatalogueSearchHistory(entries, '590').first.platformRef, '5904198');
    expect(filterCatalogueSearchHistory(entries, 'drift'), hasLength(1));
  });

  test('filter matches WIGOS passport id from the start', () {
    final entries = [entry(ref: '6200763', model: 'SVP', wigosId: '0-22000-0-6200763')];
    expect(filterCatalogueSearchHistory(entries, '22000'), isEmpty);
    expect(filterCatalogueSearchHistory(entries, '0-22000'), hasLength(1));
  });

  test('filter does not match ref suffix', () {
    final entries = [entry(ref: '3902543', model: 'SOLO_II')];
    expect(filterCatalogueSearchHistory(entries, '43'), isEmpty);
    expect(filterCatalogueSearchHistory(entries, '390'), hasLength(1));
  });

  test('subtitle joins model and WIGOS', () {
    final history = entry(ref: '6200763', model: 'SVP', wigosId: '0-22000-0-6200763');
    expect(catalogueSearchHistorySubtitle(history), 'SVP · 0-22000-0-6200763');
  });
}
