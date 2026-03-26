# Phase 3: 3D Simulation Workspace & Technical Placement JIT Plan

- [x] **Workspace Area Definition**:
    - [x] Update `Scene` model and `SimulationViewModel` with `width` and `length`.
    - [x] Update `Simulation3DView` to render the workspace boundary plane.
- [x] **Technical Placement Logic**:
    - [x] Enhance `SimulationViewModel.createGridArray` with auto-centering logic.
    - [x] Implement `updateSelectedPosition` for X, Y, and Z coordinates.
    - [x] Implement `updateSelectedRotation` for Tilt and Pan.
- [x] **Programmatic Grid UI**:
    - [x] Create a dialog for grid deployment (N x M, spacing, auto-center vs manual X/Y).
- [x] **Fixture Management UI**:
    - [x] Add a scrollable **Fixture List** to the sidebar for easy selection.
    - [x] Add X, Y, H, Tilt, and Pan input fields for selected fixture(s).
- [x] **Verification**:
    - [x] Set workspace to 20x20m.
    - [x] Deploy 3x3 grid centered.
    - [x] Adjust one fixture height individually.

**Refinements & Fixes:**
- [x] **3D Web Overlay**: Added visualization of the photometric web for the selected fixture directly in the workspace.
- [x] **Technical Input Widget**: Created a custom `TechnicalInput` with persistent controllers to fix focus/cursor reset issues during number editing.
- [x] **Selection Logic**: Added "Select All" and "Clear Selection" for bulk management.
