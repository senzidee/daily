# AGENTS.md

Flutter app (iOS + Android), local-only: day-by-day diary notes plus metric and
food tracking.

## Commands

- `flutter analyze` — lint + typecheck
- `flutter test` — unit/widget tests
- `flutter run` — run on a device/simulator

## Naming

Domain vocabulary and its _Avoid_ terms live in CONTEXT.md: DiaryEntry, Metric,
Measurement, Food, Meal, NutritionGoal. Follow those names when naming any type,
field, or class that touches those concepts.

## Architecture

State is managed with Riverpod. Keep layers separate: UI (widgets) renders, logic
(providers/notifiers) holds behavior, and data (repositories) does I/O. A widget
talks to providers, never to a repository directly.

## Decisions

Architecture decisions are recorded as ADRs in `docs/adr/`. Read the relevant ADR
before changing a subsystem it covers; write a new ADR for a decision of that scale.

## Agent skills

### Issue tracker

Issues and specs live in this repo's GitHub Issues, via `gh`. See `docs/agents/issue-tracker.md`.

### Triage labels

Five canonical labels — `needs-triage`, `needs-info`, `ready-for-agent`, `ready-for-human`, `wontfix`. See `docs/agents/triage-labels.md`.

### Domain docs

Single-context: `CONTEXT.md` at the root plus `docs/adr/`. See `docs/agents/domain.md`.
