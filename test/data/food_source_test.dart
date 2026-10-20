import 'package:flutter_test/flutter_test.dart';

import 'package:daylog/data/food_source.dart';

void main() {
  group('FakeFoodSource', () {
    final source = FakeFoodSource();

    test('blank query returns empty list', () async {
      expect(await source.search(''), isEmpty);
      expect(await source.search('   '), isEmpty);
    });

    test('unknown query returns empty list', () async {
      expect(await source.search('zzzznope'), isEmpty);
    });

    test('matches case-insensitively on trimmed substring', () async {
      final results = await source.search('  EGG  ');
      expect(results, isNotEmpty);
      expect(results.every((f) => f.name.contains('egg')), isTrue);
    });

    test('sort results by name', () async {
      final results = await source.search('a');
      final names = results.map((f) => f.name).toList();
      final sorted = [...names]..sort();
      expect(names, sorted);
    });

    test('catalog is non-empty', () async {
      final results = await source.search('a');
      expect(results, isNotEmpty);
    });

    test('every returned food has sane macros', () async {
      final results = await source.search('a');
      for (final food in results) {
        expect(food.per100g.kcal, greaterThan(0),
            reason: '${food.name} should have kcal > 0');
        expect(food.per100g.carbs, greaterThanOrEqualTo(0));
        expect(food.per100g.protein, greaterThanOrEqualTo(0));
        expect(food.per100g.fat, greaterThanOrEqualTo(0));
      }
    });
  });
}
