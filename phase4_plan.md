# Phase 4: Calculation Engine Integration & 3D Visual Analysis JIT Plan

- [x] Implement `CalculationViewModel`:
    - Method to run the `PointByPointEngine` on a grid of points.
    - Use Flutter `compute` (Isolates) for performance.
- [x] Generate Heatmap Mesh:
    - Map lux values to a color gradient.
    - Create `Face3D` figures (or a large `Mesh3D`) representing the heatmap in the 3D scene.
- [x] Update `Simulation3DView`:
    - Add "Run Calculation" button.
    - Overlay the heatmap mesh on the Work Plane.
    - Display Average Lux and Uniformity ($E_{min}/E_{avg}$).
- [x] Implement Numerical Grid:
    - Optional: Display lux values as text (using `Point3D` or similar) on the grid points.
- [x] Verify by running a calculation for a 5x5 grid and seeing the heatmap.
