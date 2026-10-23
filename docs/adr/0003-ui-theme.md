# UI theme: Material 3 colors with a Taskez-inspired layout language

Daylog's UI is built on a single theme module (`lib/ui/theme/`) that keeps
Material 3 color roles from the existing deepPurple seed while adopting the
layout language of the downloaded Taskez template: generous rounded surfaces,
pill buttons, section labels, a floating bottom nav, and Lato typography. Lato
is bundled (SIL Open Font License) so the local-only app never fetches fonts at
runtime. Reusable primitives live in `lib/ui/widgets/`.

The Taskez `lib/widgets/` folder was deliberately not copied: it holds ~88
task/employee/chat/project widgets tied to GetX, `google_fonts`, Feather icons,
`fl_chart` and pre-Dart-3 APIs.

**Considered Options**:
- Copy the Taskez `widgets/` folder — rejected; almost all of it is Taskez
  domain code and its dependencies and APIs do not match daylog.
- Hardcode the Taskez dark palette (`#262A34` background, `#181A1F` surfaces,
  `#246CFD` accent) — rejected; daylog already supports light and dark and
  should follow system brightness through Material 3 semantic roles.
- Use `google_fonts` for Lato — rejected for a local-only app; it fetches and
  caches fonts at runtime.
- Theme tokens only, keeping stock Material widgets — rejected; the chosen
  direction is the Taskez visual language, not just a color swap.

**Consequences**:
- UI chrome uses `ColorScheme` roles. Data-viz accents (macros, metric dots,
  goal gradients) live in the `AppPalette` `ThemeExtension` and are adjusted per
  brightness.
- Only Lato 300/400/700/900 ship, matching Google Fonts' static cuts; avoid
  500/600 weights so Flutter does not synthesize them.
- `HomeShell` exposes `dayTitleKey`, and `AppFloatingNav` replaces
  `NavigationBar`; widget tests target those.
- New screens should compose `AppCard`, `AppSectionLabel`, `AppSearchField`,
  `AppEmptyState` and the shared theme instead of adding ad-hoc containers.
