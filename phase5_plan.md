# Phase 5: IES Library Management JIT Plan

- [x] **Library State Management**:
    - [x] Create `IesLibraryEntry` model to store parsed data, web lines, and file info.
    - [x] Update `IesVisualizerViewModel` to hold a list of `IesLibraryEntry` and a `selectedIndex`.
- [x] **Multi-File Library UI**:
    - [x] Update `Ies3DView` to include a scrollable list of imported IES files in the Operation Panel (Sidebar).
    - [x] Move Metadata display below the list.
- [x] **Selection & Removal**:
    - [x] Implement logic to switch the active preview when a library entry is clicked.
    - [x] Add a delete/remove button for each library entry.
- [x] **Fixture Integration**:
    - [x] Ensure "Add to Workspace" and "Grid Array" always use the currently selected library entry.
- [x] **Verification**:
    - [x] Import multiple files, switch between them, and verify independent fixture deployment.
