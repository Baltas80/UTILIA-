# UTILIA release audit

## Current audit cycle

- Repository: `Baltas80/UTILIA-`
- Branch: `master`
- Application ID: `com.utilia.app.utilia`
- Flutter: `3.47.6` in CI
- Release line: `0.6.0+12`

## Verified in source/CI

- `applicationId` is `com.utilia.app.utilia`.
- `versionName` is `0.6.0`.
- `versionCode` is `12`.
- `compileSdk` and `targetSdk` are 36.
- Java/Kotlin target is Java 17.
- Release signing is mandatory and uses the configured production upload keystore.
- The latest successful CI run before the production-AdMob hardening built both the release APK and AAB and verified their signatures against the configured production upload certificate.
- Production source scans for tracked secrets and development endpoints pass.
- Required Android production files and cleartext/backup hardening checks pass.
- The repository now rejects Google test AdMob identifiers for Android builds.
- CI now requires production AdMob App ID and banner ID secrets and passes them explicitly into release APK/AAB builds.
- The public privacy-policy page exists at `docs/privacy-policy.html`.

## Current release blockers

1. A new CI run must pass with the production AdMob secrets configured.
2. The resulting AAB must be installed and smoke-tested on an Android device/emulator.
3. Play Billing product `utilia_premium` must be active and purchase/restoration tested through Google Play.
4. The exact tested AAB must be retained for the production submission.

## Versioning

The currently validated release line is `0.6.0+12`. If a new artifact is required, the next version should be `0.6.1+13`. Do not increment merely to move an already tested artifact between Play tracks.

## Decision

The Android release configuration is hardened. Final **GO** requires a successful CI build with real AdMob configuration plus a final device smoke test.
