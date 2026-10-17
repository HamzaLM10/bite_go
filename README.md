# Bite Go 🍔

A food delivery app built with **Flutter**: browse restaurants, order from a menu, and track the order live on a map.

> Personal portfolio project. It runs on a **mock data layer** (no real back-end yet), designed so a real REST API can replace it without touching the UI.

[العربية](README.ar.md)

## Screenshots

| Restaurants | Menu | Cart |
|:---:|:---:|:---:|
| ![Restaurants](screenshots/01_restaurants.png) | ![Menu](screenshots/02_menu.png) | ![Cart](screenshots/03_cart.png) |

| Checkout | Order tracking | Order history |
|:---:|:---:|:---:|
| ![Checkout](screenshots/04_checkout.png) | ![Tracking](screenshots/05_tracking.png) | ![History](screenshots/06_history.png) |

| Dark mode | Search & filters | Favorites |
|:---:|:---:|:---:|
| ![Dark](screenshots/07_dark.png) | ![Search](screenshots/08_search.png) | ![Favorites](screenshots/09_favorites.png) |

## Features

- **Restaurants list** with debounced search, cuisine filters, an "open now" switch, and favorites
- **Restaurant details** with the menu grouped by category (closed restaurants can be browsed but not ordered from)
- **Cart** limited to one restaurant at a time, with a confirmation dialog when switching restaurants
- **Checkout** with delivery address and payment method (cash / card)
- **Live order tracking**: a status timeline (placed → preparing → on the way → delivered), estimated arrival time, and a map with an animated driver marker (OpenStreetMap, no API key)
- **Order history**
- **Light and dark themes** with a toggle
- Prices in Syrian pounds (ل.س), Arabic UI with the **Cairo** font bundled in the app
- Unit and widget tests (cubits, blocs, repositories, pages)

## Tech stack

| Area | Choice |
|---|---|
| Framework | Flutter 3 / Dart 3 |
| State management | `flutter_bloc` (Cubit for simple state, full Bloc with events for search) + `equatable` |
| Navigation | `go_router` (ids in the path, so deep links work) |
| Map | `flutter_map` + `latlong2` (OpenStreetMap) |
| Streams | `stream_transform` (debounce + `switchMap` for search) |

## Architecture

Feature-first folders, with three layers inside each feature:

```
lib/
├── core/                  # theme, router, shared widgets, utils
└── features/
    ├── restaurants/       # domain / data / presentation
    ├── cart/
    ├── tracking/
    └── favorites/
```

- **domain**: entities and repository interfaces (pure Dart, knows nothing about the UI or the network)
- **data**: repository implementations. Today these are `Fake*Repository` classes with simulated delays; a real API replaces them with no change to the layers above
- **presentation**: pages, widgets, and Cubits/Blocs. Each page is split into a `Page` (provides the Cubit) and a `View` (draws the state)
- UI states are `sealed` classes (loading / loaded / error), so the compiler forces every case to be handled
- Derived values (totals, filtered lists) are getters, never stored next to their source

## Getting started

```bash
git clone https://github.com/HamzaLM10/bite_go.git
cd bite_go
flutter pub get
flutter run
```

Run the tests:

```bash
flutter test
```

## Known limitations

Listed on purpose, so you know what is real and what is simulated:

- **No real back-end.** Restaurants and orders come from in-memory fake repositories.
- **Nothing is saved between launches.** Cart, theme choice, favorites, and order history live in memory only.
- **Tracking is simulated.** Order status advances on a timer in the fake repository, and the driver position is derived from the status, not from real GPS data.
- **Prices use `double`** for simplicity. A production app should store money in the smallest unit as an integer.
- Strings are written directly in the widgets; localization (Arabic/English with RTL) is planned.
- Restaurant images are loaded from the internet and fall back to an icon when offline.

## Roadmap

- Login (mock auth with route protection)
- Favorite button on the restaurant details page
- Arabic/English localization with RTL
- Local persistence for cart, theme, and favorites
- Real API integration (REST or Firebase)

## Author

**Hamza Afif**, Flutter Developer, Damascus
GitHub: [@HamzaLM10](https://github.com/HamzaLM10)
