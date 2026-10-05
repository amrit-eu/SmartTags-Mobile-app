import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_tags/database/db.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.executor(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  test('recordCatalogueSearchEntry dedupes by platformRef and keeps newest first', () async {
    await db.recordCatalogueSearchEntry(platformRef: '5904198', platformModel: 'A');
    await Future<void>.delayed(const Duration(milliseconds: 5));
    await db.recordCatalogueSearchEntry(platformRef: 'PLT-002', platformModel: 'B');
    await Future<void>.delayed(const Duration(milliseconds: 5));
    await db.recordCatalogueSearchEntry(platformRef: '5904198', platformModel: 'A2');

    final rows = await db.select(db.catalogueSearchHistories).get();
    expect(rows, hasLength(2));
    final reopened = rows.firstWhere((row) => row.platformRef == '5904198');
    expect(reopened.platformModel, 'A2');
  });

  test('clearCatalogueSearchHistory removes all rows', () async {
    await db.recordCatalogueSearchEntry(platformRef: 'PLT-001');
    await db.recordCatalogueSearchEntry(platformRef: 'PLT-002');

    await db.clearCatalogueSearchHistory();

    final rows = await db.select(db.catalogueSearchHistories).get();
    expect(rows, isEmpty);
  });

  test('recordCatalogueSearchEntry trims to limit', () async {
    for (var i = 0; i < AppDatabase.catalogueSearchHistoryLimit + 3; i++) {
      await db.recordCatalogueSearchEntry(platformRef: 'REF-$i');
    }
    final rows = await db.select(db.catalogueSearchHistories).get();
    expect(rows.length, AppDatabase.catalogueSearchHistoryLimit);
  });
}
