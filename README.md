# MAXKO F&B Mobile App

Flutter mobile ordering app based on the supplied MAXKO F&B design in `GiaoDien_Fluter`.

## Run

1. Install Flutter 3.0 or newer.
2. From this folder run `flutter pub get`.
3. Run `flutter run` with an Android, iOS, web, or Windows device selected.

## Included screens

- Home, nearby branches, brands, and best sellers
- Menu browsing and product customization
- Cart and checkout summary
- Promotions, order history, and loyalty

Food and brand photos load from the MAXKO API. The menu starts empty until API data arrives, so the app does not present demo products as live inventory.

## MAXKO API

The app connects to `https://api.legiapos.vn/api` by default. To use another API server, run Flutter with `--dart-define=MAXKO_API_BASE=https://your-api.example/api`.

Catalog, branches, categories, modifiers, hero banners, flash sales, promotions, vouchers, loyalty profile, delivery fees, order precheck, batch checkout, payment QR/status, and customer order history load through the MAXKO API. Customer sign-in is required for checkout. On Android and iOS, the API client also has a DNS-over-HTTPS fallback for networks that cannot resolve the API hostname normally.

## Google Play release

- Android application ID: `vn.legiapos.maxkofnb` (confirm this is the intended permanent ID before creating the Play listing).
- Release target SDK: 36.
- Release builds use a private upload keystore, never the debug signing key. A local upload keystore and `android/key.properties` are configured and excluded from Git. Back them up securely; do not commit or share them.
- Build the upload bundle from this folder with `flutter build appbundle --release`.
- See `PLAY_STORE_CHECKLIST.md` for the remaining account, privacy, and store listing requirements.
