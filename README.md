# Supreme Ioniq 6 Logger — iOS V1.0 foundation

Native iPhone application foundation written in SwiftUI, targeting iOS 16.0 and later.
The iPad is intentionally excluded (`TARGETED_DEVICE_FAMILY = 1`).

## Included in this first delivery

- SwiftUI iPhone app with Live, Trip History and Settings tabs.
- Start and end trip workflow.
- CoreLocation tracking and route point collection.
- Distance, current speed, average speed and maximum speed calculations.
- Reverse geocoding for the trip start city/region.
- Local JSON persistence in the app Documents directory.
- Trip detail route preview using MapKit.
- CSV export through the iOS share sheet.
- Basic unit tests for trip calculations.
- Codemagic build-validation workflow.
- XcodeGen project specification (`project.yml`).

## Not yet implemented

This is the V1.0 foundation, not a completed replacement for the Android app.
The following remain planned work:
- CoreBluetooth OBD2 connection and IONIQ 6 PID parsing.
- SOC, battery temperature, voltage/current/power and energy calculations.
- Charging, meal and other stop workflow.
- Automatic charging detection and Open Charge Map integration.
- Full trip summary and PDF export.
- Android `trips.json` importer and migration validation.
- App icon, privacy disclosures, accessibility and App Store screenshots.

The Android ZIP remains the source of truth for the existing OBD2 protocol. In particular, the Android implementation identifies a Nordic UART BLE profile and Hyundai/Kia EV extended diagnostic responses. Those byte offsets and formulas must be ported and verified against the actual Vgate adapter and vehicle before they are used in the iOS app.

## Requirements

- Xcode 15 or newer for local builds; a current Xcode image is recommended for App Store submission.
- XcodeGen (`brew install xcodegen`) to generate the `.xcodeproj`.
- iOS 16.0+ iPhone for device testing.
- Apple Developer Program membership and App Store Connect access for TestFlight/App Store distribution.

You do not need to own a Mac if you use a hosted macOS CI provider such as Codemagic.

## Generate the Xcode project

```bash
brew install xcodegen
xcodegen generate
```

Then open `SupremeIoniq6Logger.xcodeproj` in Xcode.

## Build in Codemagic from Windows/Linux

1. Create a private GitHub repository and upload this project.
2. In Codemagic, connect the GitHub repository.
3. Select the `ios-validation` workflow from `codemagic.yaml`.
4. Start a build. This workflow validates compilation on an iOS Simulator target.
5. After the app compiles, configure Apple Developer signing and App Store Connect API credentials in Codemagic to create a signed archive and publish to TestFlight.

The included workflow intentionally validates compilation without signing. It does not yet upload to TestFlight. Signing credentials must be configured securely in Codemagic before distribution.

## Location permission and background behavior

The app requests location permission when a trip is started. For background tracking, the user must grant Always authorization in iOS Settings after being shown the in-app explanation. iOS can still suspend or limit background work; test with the screen locked and with other apps open. The app must be transparent about location use and comply with Apple's review requirements.

## Data format

Trips are stored locally as `trips-v1.json` using ISO-8601 dates. A compatibility importer for the Android JSON schema will be added after the exact legacy schema is mapped.

## Important

Bundle identifier currently set to `com.supreme.ioniq6logger`. Confirm availability in your Apple Developer account before signing. Never commit certificates, provisioning profiles, API keys or passwords to GitHub.
