# Customer App (Flutter)

This is a small Flutter demo application that shows:
- Login using the provided API
- Paginated customer list with images and details
- Token persistence (SharedPreferences)
- Provider for state management

API configuration (see `lib/services/api_service.dart`):
- baseLink: https://www.pqstec.com/InvoiceApps/Values/
- imageBaseLink: https://www.pqstec.com/InvoiceApps/

Default credentials (for testing):
- UserName: admin@gmail.com
- Password: admin1234

Run locally:
1. flutter pub get
2. flutter run

Assets included in this repo
- assets/login.png — login screen illustration
- assets/list.png — list placeholder image
- assets/customer.png — default customer avatar

Changelog / What I changed in this repository
- Implemented token-based login and persistence using `AuthProvider`.
- Built paginated customer list and customer detail screens (providers in `lib/providers`).
- Added `AuthImage` widget to fetch and render protected images. Improved robustness: percent-encode image paths, show fade-in placeholders, and add retry affordance.
- Fixed a bug where `auth_image.dart` returned widgets from inside an async helper (caused compile errors). Cleaned and reimplemented the widget.
- Added a development image proxy (`server/server.js`) and wired `ApiService` to route proxied image URLs when running on web (avoids CORS Authorization issues during development).
- Added `url_launcher` support and tap-to-open behavior for viewing the full image in a browser/tab.
- Improved responsiveness for web: images now respect parent constraints and avoid being stretched.

Notes
- The `server` proxy is intended for local development only (see `server/README.md`). If you deploy to production, configure proper CORS on the image host or secure the proxy.

