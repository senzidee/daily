# Food data source: USDA FoodData Central behind a FoodSource interface

The app logs meals whose macros come from a food database. We use USDA
FoodData Central (public domain, CC0) behind a `FoodSource` interface, queried
only during food search and cached into drift locally.

**Considered Options**:
- Open Food Facts — open data but ODbL share-alike (UI attribution + a derived
  database may need to be released open) and crowd-sourced; barcode-oriented,
  weak on generic whole foods.
- CREA (Italy's official tables) — authoritative but a static spreadsheet, no
  natural-language or barcode API.

**Consequences**:
Coverage is US/English-centric; Italian branded/barcode lookup is deferred and
will slot in behind `FoodSource` later.
