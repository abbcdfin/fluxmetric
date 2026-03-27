# Phase 7: GitHub CI/CD Pipeline JIT Plan

- [x] **Create Workflow File**:
    - [x] Create directory `.github/workflows`.
    - [x] Define `release.yml`.
    - [x] Configure `workflow_dispatch` and `push: tags: ['v*']` triggers.
- [x] **Implement Build Job**:
    - [x] Set `runs-on: windows-latest`.
    - [x] Checkout code.
    - [x] Setup Flutter using `subosito/flutter-action`.
    - [x] Run `flutter pub get` in `fluxmetric_engine`.
    - [x] Run `flutter pub get` in `fluxmetric_app`.
    - [x] Execute `flutter build windows --release` in `fluxmetric_app`.
- [x] **Package & Release**:
    - [x] Zip the `fluxmetric_app/build/windows/x64/runner/Release/` content.
    - [x] Add `softprops/action-gh-release` step to upload the zip.
- [x] **Verification**:
    - [x] Final YAML validation.
