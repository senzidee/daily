import 'macros.dart';

class Meal {
  const Meal({
    required this.foodId,
    required this.grams,
    required this.macros,
    required this.consumedAt,
    this.id,
  });

  final int? id;
  final int foodId;
  final double grams;
  final Macros macros;
  final DateTime consumedAt;
}
