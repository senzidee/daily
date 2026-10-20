import 'package:daylog/data/app_database.dart';
import 'package:daylog/providers/database_provider.dart';
import 'package:daylog/providers/food_providers.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late ProviderContainer container;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    container = ProviderContainer(
      overrides: [databaseProvider.overrideWithValue(db)],
    );
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  test('foodSearchProvider returns foods with non-null ids', () async {
    final foods = await container.read(foodSearchProvider('egg').future);

    expect(foods, isNotEmpty);
    expect(foods.every((f) => f.id != null), isTrue);
  });

  test('searching twice is idempotent with stable ids and no duplicates',
      () async {
    final repository = container.read(foodRepositoryProvider);

    final first = await repository.search('a');
    final second = await repository.search('a');

    expect(first.map((f) => f.id).toList(), second.map((f) => f.id).toList());

    final rows = await db.select(db.foods).get();
    expect(rows.length, first.length);
  });

  test('findById round-trips a searched food', () async {
    final foods = await container.read(foodSearchProvider('banana').future);
    final food = foods.single;

    final found = await container.read(foodRepositoryProvider).findById(food.id!);

    expect(found, isNotNull);
    expect(found!.name, food.name);
    expect(found.per100g, food.per100g);
  });

  test('findById returns null for an unknown id', () async {
    final found =
        await container.read(foodRepositoryProvider).findById(999999);
    expect(found, isNull);
  });
}
