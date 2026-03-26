# Phase 6: Persistence & Metadata Customization JIT Plan

- [x] **Dependencies & Models**:
    - [x] Add `path_provider` to `pubspec.yaml`.
    - [x] Update `IesLibraryEntry` to include `displayName` and `rawContent` (the actual IES string).
- [x] **Persistence Logic**:
    - [x] Implement `toJson` and `fromJson` for `IesLibraryEntry`.
    - [x] Create `IesPersistenceService` to handle reading/writing the library file to disk.
    - [x] Update `IesVisualizerViewModel` to load the library on initialization and save on changes.
- [x] **Rename UI**:
    - [x] Add an edit icon next to the name in the IES Library list.
    - [x] Show a dialog to change the `displayName`.
- [x] **Verification**:
    - [x] Import, rename, restart, and verify persistence.
