# MAXKO F&B Google Play release checklist

## Configured in this project

- Android target SDK is set to 36, the current requirement for new Google Play apps and updates.
- Release builds use a separate upload signing configuration instead of the debug key.
- Android app label is MAXKO F&B; the launcher and Play icon use the MAXKO Vietnam logo from the supplied MAXKO source files.
- Store listing icon (512 × 512 PNG) and feature graphic (1024 × 500 PNG) are in `play_store_assets/`.
- Android internet permission is declared in the main manifest.
- API catalog data comes from the configured MAXKO service; no sample catalog is shown as live inventory.

## Required before building an upload bundle

1. Confirm `vn.legiapos.maxkofnb` is the permanent Android application ID for this app. Google Play does not let an existing listing change its application ID.
2. Securely back up the configured `android/upload-keystore.jks` and `android/key.properties`. Keep both private and out of Git. Play App Signing is recommended.
3. Increment the app version in `pubspec.yaml` for every later upload.
4. Build with `flutter build appbundle --release` and test the signed bundle on supported Android devices before internal testing.

## Required in Play Console and company policy setup

- Publish a public, non-editable privacy policy webpage and link it both in Play Console and from inside the app. It must name the developer/app, describe the user data and third parties, explain security and retention, and provide a privacy contact.
- Complete the Data safety form to match the app and all included SDKs. The app handles account identifiers and contact information, orders, delivery details, and loyalty data through the MAXKO API.
- Provide account deletion inside the app and a public web deletion-request page. The API's current authenticated `DELETE /customers/:id` route does not verify that the caller owns the requested account, so the app must not call it for self-service deletion until the backend adds an ownership-checked deletion flow. The backend must delete associated account data as required by policy.
- Complete content rating, target audience, ads, app access/test credentials, store description, and phone/tablet screenshots. The icon and feature graphic are prepared in `play_store_assets/`.

## Before first upload

The app ID, developer identity, privacy policy URL/contact, deletion behavior, and store listing assets need confirmation from the app owner. Do not publish a release signed with the debug key or commit any upload key/password.
