# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build Commands

### Rust Cloudflare Worker (`worker/`)

```bash
cd worker
cargo +stable check --target wasm32-unknown-unknown   # type-check
cargo install worker-build && worker-build --release   # full build (wasm)
npx wrangler dev                                       # local dev server
npx wrangler deploy                                    # deploy to Cloudflare
npx wrangler secret put GOOGLE_MAPS_API_KEY            # set API key secret
```

Requires stable Rust toolchain with `wasm32-unknown-unknown` target (configured via `rust-toolchain.toml`).

### iOS App (`PlacesApp/`)

```bash
cd PlacesApp
xcodegen generate                                      # regenerate .xcodeproj from project.yml
xcodebuild -project PlacesApp.xcodeproj -scheme PlacesApp -destination "generic/platform=iOS Simulator" -sdk iphonesimulator build
```

Requires Xcode 16.0+, xcodegen, iOS 17.0 deployment target. The Xcode project is generated from `project.yml` — edit that file, not the `.xcodeproj` directly.

## Architecture

Two-component system: a Rust Cloudflare Worker proxies the Google Places API (keeping the API key server-side), and a SwiftUI iOS app with a WidgetKit extension consumes it.

### Worker → Google Places API (New)

- `GET /api/search?query=...` → calls `places.googleapis.com/v1/places:searchText`
- `GET /api/place/:placeId` → calls `places.googleapis.com/v1/places/{placeId}`

Router is in `lib.rs`, handlers in `search.rs` and `place.rs`, all types in `models.rs`.

### iOS App — Three Xcode Targets

1. **PlacesApp** — main app with search and monitored places tabs
2. **PlacesWidget** — WidgetKit extension (small/medium) with AppIntentConfiguration for place selection, 30-min timeline refresh
3. **PlacesShared** — not a separate framework target; source files (`Constants.swift`, `Place.swift`, `PlaceStore.swift`) are compiled into both app and widget targets

### Data Sharing

App and widget share data via **App Group** `group.com.places.monitor` using `UserDefaults(suiteName:)`. `PlaceStore` is the single persistence layer — observable in the app, static accessor for the widget.

## Configuration

`PlacesShared/Constants.swift` contains `workerBaseURL` which must be updated to your deployed worker URL (default is a placeholder `CHANGEME`).

## Preferences

- Server/worker code should be written in Rust, not TypeScript.
