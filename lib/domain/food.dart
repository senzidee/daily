import 'macros.dart';

class Food {
  const Food({
    required this.name,
    required this.per100g,
    this.id,
  });

  final int? id;
  final String name;
  final Macros per100g;
}
