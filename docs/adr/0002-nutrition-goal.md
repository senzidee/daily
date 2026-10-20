# Nutrition goal: kcal target + macro split as % of energy

To turn a user's "40% carbs / 40% protein / 20% fat" into daily targets, the
goal stores a daily kcal target plus a macro split expressed as a percentage of
energy, and derives gram targets (carbs/protein 4 kcal/g, fat 9 kcal/g).

**Considered Options**:
- A gram-percentage split — rejected because 20% fat by grams is not 20% of
  energy (fat is ~9 kcal/g), so the percentages would mislead.

**Consequences**:
The user sets kcal + percentages and sees/targets grams; the split is
energy-based even though the display is in grams.
