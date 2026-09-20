# UTILIA release audit

## Current audit cycle

- Repository: `Baltas80/UTILIA-`
- Branch: `master`
- Application ID: `com.utilia.app.utilia`
- Flutter: `3.35.7` in CI
- Release line: `0.5.5`

## Verified in source/CI

- Dart sources and tests have been normalized with the Flutter 3.35.7 formatter.
- Production marker and tracked-secret scans pass in CI.
- Required Android production files and cleartext/backup hardening checks pass in CI.
- The public privacy-policy page exists at `docs/privacy-policy.html` and a root `privacy-policy.html` is also present for GitHub Pages publication.
- The in-app privacy-policy link uses the GitHub Pages URL.
- The release UI displays version `0.5.5`.

## Remaining release gate

A successful post-format CI run must validate analysis, tests, Android Play configuration, production signing, APK, AAB, and artifact verification before the repository can be considered READY FOR GOOGLE PLAY.

Do not treat this document as evidence that a release artifact has been generated; the final CI run is the authoritative evidence for build and signing status.
