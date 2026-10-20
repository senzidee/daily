import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/day.dart';
import '../domain/food.dart';
import '../domain/macros.dart';
import '../domain/meal.dart';
import '../providers/food_providers.dart';
import '../providers/meal_providers.dart';
import '../providers/selected_day_provider.dart';

final _foodQueryProvider = NotifierProvider<_FoodQueryNotifier, String>(
  _FoodQueryNotifier.new,
);

class _FoodQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void set(String value) => state = value;
}

class MealsTab extends ConsumerWidget {
  const MealsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = ref.watch(_foodQueryProvider);
    return CustomScrollView(
      slivers: [
        const SliverToBoxAdapter(child: _SearchField()),
        if (query.trim().isNotEmpty) _SearchResults(query: query),
        const SliverToBoxAdapter(child: _SectionHeader('Meals')),
        const _DayMealsList(),
      ],
    );
  }
}

class _SearchField extends ConsumerStatefulWidget {
  const _SearchField();

  @override
  ConsumerState<_SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends ConsumerState<_SearchField> {
  final _controller = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      ref.read(_foodQueryProvider.notifier).set(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _controller,
        onChanged: _onChanged,
        textInputAction: TextInputAction.search,
        decoration: const InputDecoration(
          prefixIcon: Icon(Icons.search),
          hintText: 'Search foods',
          border: OutlineInputBorder(),
        ),
      ),
    );
  }
}

class _SearchResults extends ConsumerWidget {
  const _SearchResults({required this.query});

  final String query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final results = ref.watch(foodSearchProvider(query));
    return results.when(
      data: (foods) {
        if (foods.isEmpty) {
          return const SliverToBoxAdapter(child: _CenteredNote('No foods found'));
        }
        return SliverList.builder(
          itemCount: foods.length,
          itemBuilder: (context, index) {
            final food = foods[index];
            return ListTile(
              title: Text(food.name),
              subtitle: Text(_macrosLabel(food.per100g)),
              trailing: const Icon(Icons.add_circle_outline),
              onTap: () => _showLogMealDialog(context, food),
            );
          },
        );
      },
      loading: () => const SliverToBoxAdapter(child: _CenteredNote('Searching…')),
      error: (error, _) => SliverToBoxAdapter(
        child: _CenteredNote('Search failed: $error'),
      ),
    );
  }
}

class _DayMealsList extends ConsumerWidget {
  const _DayMealsList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final day = ref.watch(selectedDayProvider);
    final mealsAsync = ref.watch(mealsProvider);

    return mealsAsync.when(
      data: (meals) {
        final todaysMeals =
            meals.where((m) => isSameDay(m.consumedAt, day)).toList();
        if (todaysMeals.isEmpty) {
          return const SliverToBoxAdapter(
            child: _CenteredNote('No meals logged yet'),
          );
        }
        return SliverList.builder(
          itemCount: todaysMeals.length,
          itemBuilder: (context, index) => _MealTile(meal: todaysMeals[index]),
        );
      },
      loading: () => const SliverToBoxAdapter(child: _CenteredNote('Loading…')),
      error: (error, _) =>
          SliverToBoxAdapter(child: _CenteredNote('Failed to load meals: $error')),
    );
  }
}

class _MealTile extends ConsumerWidget {
  const _MealTile({required this.meal});

  final Meal meal;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final foodAsync = ref.watch(foodByIdProvider(meal.foodId));
    final name = foodAsync.maybeWhen(
      data: (food) => food?.name ?? 'Food #${meal.foodId}',
      orElse: () => 'Food #${meal.foodId}',
    );

    return Dismissible(
      key: ValueKey(meal.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Theme.of(context).colorScheme.error,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) {
        final id = meal.id;
        if (id != null) {
          ref.read(mealsProvider.notifier).delete(id);
        }
      },
      child: ListTile(
        title: Text(name),
        isThreeLine: true,
        subtitle: Text(
          '${_fmt(meal.grams)} g · ${_fmt(meal.macros.kcal)} kcal\n'
          'C ${_fmt(meal.macros.carbs)} · P ${_fmt(meal.macros.protein)} · '
          'F ${_fmt(meal.macros.fat)}',
        ),
        onTap: () => _showEditMealDialog(context, meal),
      ),
    );
  }
}

Future<void> _showLogMealDialog(BuildContext context, Food food) {
  return showDialog<void>(
    context: context,
    builder: (context) => _LogMealDialog(food: food),
  );
}

class _LogMealDialog extends ConsumerStatefulWidget {
  const _LogMealDialog({required this.food});

  final Food food;

  @override
  ConsumerState<_LogMealDialog> createState() => _LogMealDialogState();
}

class _LogMealDialogState extends ConsumerState<_LogMealDialog> {
  final _gramsController = TextEditingController();
  DateTime _time = DateTime.now();
  bool _submitting = false;

  @override
  void dispose() {
    _gramsController.dispose();
    super.dispose();
  }

  double? get _grams => double.tryParse(_gramsController.text);

  @override
  Widget build(BuildContext context) {
    final grams = _grams;
    final valid = grams != null && grams > 0;
    final preview = valid ? scaleMealMacros(widget.food.per100g, grams) : null;

    return AlertDialog(
      title: Text('Log ${widget.food.name}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _gramsController,
            keyboardType: TextInputType.number,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              labelText: 'Grams',
              hintText: 'e.g. 150',
              errorText: _gramsController.text.isNotEmpty && !valid
                  ? 'Enter a number greater than 0'
                  : null,
            ),
          ),
          const SizedBox(height: 16),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.schedule),
            title: const Text('Time'),
            subtitle: Text(_formatTime(_time)),
            onTap: _pickTime,
          ),
          if (preview != null) ...[
            const SizedBox(height: 8),
            Text(
              _macrosLabel(preview),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: valid && !_submitting ? _save : null,
          child: const Text('Save'),
        ),
      ],
    );
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_time),
    );
    if (picked != null) {
      setState(() {
        _time = DateTime(
          _time.year,
          _time.month,
          _time.day,
          picked.hour,
          picked.minute,
        );
      });
    }
  }

  Future<void> _save() async {
    final grams = _grams;
    if (grams == null) {
      return;
    }
    setState(() => _submitting = true);
    await ref.read(mealsProvider.notifier).add(
          food: widget.food,
          grams: grams,
          consumedAt: _time,
        );
    if (mounted) {
      Navigator.of(context).pop();
    }
  }
}

Future<void> _showEditMealDialog(BuildContext context, Meal meal) {
  return showDialog<void>(
    context: context,
    builder: (context) => _EditMealDialog(meal: meal),
  );
}

class _EditMealDialog extends ConsumerStatefulWidget {
  const _EditMealDialog({required this.meal});

  final Meal meal;

  @override
  ConsumerState<_EditMealDialog> createState() => _EditMealDialogState();
}

class _EditMealDialogState extends ConsumerState<_EditMealDialog> {
  late final TextEditingController _gramsController =
      TextEditingController(text: _fmt(widget.meal.grams));
  late DateTime _time = widget.meal.consumedAt;
  bool _submitting = false;

  @override
  void dispose() {
    _gramsController.dispose();
    super.dispose();
  }

  double? get _grams => double.tryParse(_gramsController.text);

  @override
  Widget build(BuildContext context) {
    final foodAsync = ref.watch(foodByIdProvider(widget.meal.foodId));
    final grams = _grams;
    final valid = grams != null && grams > 0;
    final hasFood = foodAsync.maybeWhen(
      data: (food) => food != null,
      orElse: () => false,
    );
    final preview = valid && hasFood
        ? scaleMealMacros(foodAsync.value!.per100g, grams)
        : null;

    return AlertDialog(
      title: Text(
        foodAsync.maybeWhen(
          data: (food) => 'Edit ${food?.name ?? 'meal'}',
          orElse: () => 'Edit meal',
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _gramsController,
            keyboardType: TextInputType.number,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              labelText: 'Grams',
              errorText: _gramsController.text.isNotEmpty && !valid
                  ? 'Enter a number greater than 0'
                  : null,
            ),
          ),
          const SizedBox(height: 16),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.schedule),
            title: const Text('Time'),
            subtitle: Text(_formatTime(_time)),
            onTap: _pickTime,
          ),
          if (preview != null) ...[
            const SizedBox(height: 8),
            Text(
              _macrosLabel(preview),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: valid && !_submitting ? _save : null,
          child: const Text('Save'),
        ),
      ],
    );
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_time),
    );
    if (picked != null) {
      setState(() {
        _time = DateTime(
          _time.year,
          _time.month,
          _time.day,
          picked.hour,
          picked.minute,
        );
      });
    }
  }

  Future<void> _save() async {
    final grams = _grams;
    if (grams == null) {
      return;
    }
    setState(() => _submitting = true);
    await ref.read(mealsProvider.notifier).updateMeal(
          Meal(
            id: widget.meal.id,
            foodId: widget.meal.foodId,
            grams: grams,
            macros: widget.meal.macros,
            consumedAt: _time,
          ),
        );
    if (mounted) {
      Navigator.of(context).pop();
    }
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _CenteredNote extends StatelessWidget {
  const _CenteredNote(this.message);

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }
}

String _fmt(double value) {
  final s = value.toStringAsFixed(1);
  return s.endsWith('.0') ? s.substring(0, s.length - 2) : s;
}

String _formatTime(DateTime time) {
  final hour = time.hour.toString().padLeft(2, '0');
  final minute = time.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}

String _macrosLabel(Macros m) =>
    '${_fmt(m.kcal)} kcal · C ${_fmt(m.carbs)} g · '
    'P ${_fmt(m.protein)} g · F ${_fmt(m.fat)} g';
