# Places Monitor

An iOS app with home screen widgets for monitoring Google Maps business information (ratings, hours, open/closed status). A Rust Cloudflare Worker proxies the Google Places API to keep credentials server-side.

## Components

### Cloudflare Worker (`worker/`)

Rust-based API proxy with two endpoints:

| Endpoint | Description |
|---|---|
| `GET /api/search?query=...` | Search for places by name/address |
| `GET /api/place/:placeId` | Get full details (rating, hours, phone, status) |

### iOS App (`PlacesApp/`)

SwiftUI app (iOS 17+) with a WidgetKit extension:

- **Search tab** — find businesses and add them to your monitored list
- **Places tab** — view monitored places with pull-to-refresh
- **Widgets** — small and medium home screen widgets showing live business info, configurable per-place, refreshing every 30 minutes

## Setup

### Worker

```bash
cd worker
cargo install worker-build
npx wrangler secret put GOOGLE_MAPS_API_KEY
npx wrangler deploy
```

Then update `PlacesApp/PlacesShared/Constants.swift` with your deployed worker URL.

### iOS App

```bash
brew install xcodegen   # if not installed
cd PlacesApp
xcodegen generate
open PlacesApp.xcodeproj
```

Build and run from Xcode. Both the app and widget extension share data via the `group.com.places.monitor` App Group.

## Requirements

- Xcode 16.0+
- Rust stable toolchain with `wasm32-unknown-unknown` target
- [xcodegen](https://github.com/yonaskolb/XcodeGen)
- Google Maps Places API key (New)
- Cloudflare account (for worker deployment)
