# Daylog

A personal, local-only Flutter app (iOS + Android) for day-by-day diary notes and
tracking measurements and food intake.

## Language

**DiaryEntry**:
A freeform note attached to a specific time, holding optional text and optional
audio (at least one required).
_Avoid_: Note, post, journal entry

**Metric**:
A user-defined numeric thing to track over time, with a name, a unit, and an
aggregation mode (`last`, `sum`, or `avg`). `weight` (kg) is the seeded metric.
_Avoid_: Thing, tracker, field

**Measurement**:
A single value of a Metric recorded at a specific time. Multiple per day,
back-datable.
_Avoid_: Reading, data point

**Food**:
A food catalog item cached from USDA FoodData Central, holding per-100g macros
(kcal, carbs, protein, fat).
_Avoid_: Product, item

**Meal**:
A logged consumption: a Food plus a quantity in grams and the four scaled macros,
recorded at a specific time. Multiple per day, back-datable, fully editable.
_Avoid_: Entry, food entry, record

**NutritionGoal**:
A single active goal with a daily kcal target and a macro split expressed as a
percentage of energy; gram targets are derived from it.
_Avoid_: Diet, plan, target
