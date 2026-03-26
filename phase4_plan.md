# Phase 4: Calculation Engine Integration & 3D Visual Analysis JIT Plan

- [x] Implement `CalculationViewModel`:
    - [x] Method to run the `PointByPointEngine` on a grid of points.
    - [x] Implemented on main thread for stability (asynchronous UI maintained).
- [x] Generate Heatmap Mesh:
    - [x] Map lux values to a color gradient.
    - [x] Create `Face3D` figures representing the heatmap in the 3D scene.
- [x] Update `Simulation3DView`:
    - [x] Add "Run Calculation" button.
    - [x] Overlay the heatmap mesh on the Work Plane at the correct height.
    - [x] Display Average Lux and Uniformity ($E_{min}/E_{avg}$).
- [x] Verify by running a calculation for a 5x5 grid and seeing the heatmap.

**Refinements & Fixes:**
- [x] **2D Technical Heatmap**: Added a dedicated tab for a crisp, top-down technical view using `CustomPainter` with auto-scaling and a color legend.
- [x] **Scale Controls**: Implemented a toggle between **Dynamic Scale** (max based on current result) and **Fixed Scale** (user-defined max lux) for consistent technical reporting.
- [x] **Double-Sided Rendering**: Made 3D heatmap faces visible from both top and bottom (+/- Z) to ensure clarity during 3D navigation.
- [x] **Heatmap Positioning**: Fixed vertical offset bugs to ensure the heatmap renders exactly on the work plane.
- [x] **Camera Controls**: Added a "Reset Top View" button to the 3D viewport.
