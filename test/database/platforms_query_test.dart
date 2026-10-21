import 'dart:async';

import 'package:drift/drift.dart';
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

  PlatformsCompanion platform(int number) => PlatformsCompanion.insert(
    ref: 'PLT-${number.toString().padLeft(3, '0')}',
    model: 'Model $number',
    wigosId: Value('0-22000-0-$number'),
    category: 'Profiling Float',
    network: 'Argo',
    lat: 1,
    lon: 2,
    status: 'OPERATIONAL',
    operationalStatus: 'Deployed',
    lastUpdated: DateTime.utc(2026, 10, 19),
    operationLat: 1,
    operationLon: 2,
  );

  test('watchPlatforms orders by reference before applying an optional limit', () async {
    await db.insertPlatforms([platform(3), platform(1), platform(2)]);

    final preview = await db.watchPlatforms(limit: 2).first;
    expect(preview.map((p) => p.ref), ['PLT-001', 'PLT-002']);

    final all = await db.watchPlatforms().first;
    expect(all.map((p) => p.ref), ['PLT-001', 'PLT-002', 'PLT-003']);
  });

  test('watchPlatforms searches the full database and leaves searches unlimited by default', () async {
    await db.insertPlatforms(List.generate(60, (index) => platform(index + 1)));

    final matches = await db.watchPlatforms(query: 'model').first;
    expect(matches, hasLength(60));
    expect((await db.watchPlatforms(query: 'plt-060').first).single.ref, 'PLT-060');
    expect((await db.watchPlatforms(query: '0-22000-0-60').first).single.ref, 'PLT-060');
    expect(await db.watchPlatforms(query: 'missing').first, isEmpty);
  });

  test('watchPlatforms applies search filtering before its optional limit', () async {
    await db.insertPlatforms([platform(1), platform(20), platform(2), platform(3)]);

    final matches = await db.watchPlatforms(query: 'model 2', limit: 1).first;
    expect(matches.single.ref, 'PLT-002');
  });

  test('limited platform stream updates when a newly synced platform sorts first', () async {
    await db.insertPlatforms([platform(2), platform(3)]);
    final rows = StreamIterator(db.watchPlatforms(limit: 1));
    addTearDown(rows.cancel);

    expect(await rows.moveNext(), isTrue);
    expect(rows.current.single.ref, 'PLT-002');

    await db.upsertPlatforms([platform(1)]);
    expect(await rows.moveNext(), isTrue);
    expect(rows.current.single.ref, 'PLT-001');
  });

  test('platform count stream updates after local inserts and deletes', () async {
    final counts = StreamIterator(db.watchPlatformCount());
    addTearDown(counts.cancel);

    expect(await counts.moveNext(), isTrue);
    expect(counts.current, 0);

    await db.insertPlatforms([platform(1), platform(2), platform(3)]);
    expect(await counts.moveNext(), isTrue);
    expect(counts.current, 3);

    await db.delete(db.platforms).go();
    expect(await counts.moveNext(), isTrue);
    expect(counts.current, 0);
  });
}
