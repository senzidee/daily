import 'package:daylog/domain/macros.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Macros', () {
    const a = Macros(kcal: 100, carbs: 10, protein: 20, fat: 5);
    const b = Macros(kcal: 50, carbs: 5, protein: 2, fat: 1);

    test('adds two macros component-wise', () {
      final sum = a + b;
      expect(sum, const Macros(kcal: 150, carbs: 15, protein: 22, fat: 6));
    });

    test('multiplies by a scalar factor', () {
      final scaled = a * 2;
      expect(scaled, const Macros(kcal: 200, carbs: 20, protein: 40, fat: 10));
    });

    test('supports value equality', () {
      expect(const Macros(kcal: 100, carbs: 10, protein: 20, fat: 5), a);
      expect(a.hashCode, const Macros(kcal: 100, carbs: 10, protein: 20, fat: 5).hashCode);
      expect(a, isNot(b));
    });

    test('has a readable toString', () {
      expect(a.toString(), 'Macros(kcal: 100.0, carbs: 10.0, protein: 20.0, fat: 5.0)');
    });
  });

  group('scaleMealMacros', () {
    const per100g = Macros(kcal: 400, carbs: 40, protein: 30, fat: 10);

    test('scales per-100g macros to a gram quantity', () {
      expect(scaleMealMacros(per100g, 250), const Macros(kcal: 1000, carbs: 100, protein: 75, fat: 25));
    });

    test('returns zero for zero grams', () {
      expect(scaleMealMacros(per100g, 0), const Macros(kcal: 0, carbs: 0, protein: 0, fat: 0));
    });

    test('returns the per-100g values for 100 grams', () {
      expect(scaleMealMacros(per100g, 100), per100g);
    });
  });
}
