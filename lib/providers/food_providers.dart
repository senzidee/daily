import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/food_source.dart';
import '../data/repositories/food_repository.dart';
import '../domain/food.dart';
import 'database_provider.dart';

final foodSourceProvider = Provider<FoodSource>((ref) => FakeFoodSource());

final foodRepositoryProvider = Provider<FoodRepository>(
  (ref) => DriftFoodRepository(
    ref.watch(databaseProvider),
    ref.watch(foodSourceProvider),
  ),
);

final foodSearchProvider = FutureProvider.family<List<Food>, String>(
  (ref, query) => ref.watch(foodRepositoryProvider).search(query),
);
