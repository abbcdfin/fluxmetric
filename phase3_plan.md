# Phase 3: 3D Simulation Workspace & Parametric Placement JIT Plan

- [x] Define `SimulationViewModel`:
    - Manage a list of `LightFixture` instances in a `Scene`.
    - Provide state for the active selection.
- [x] Implement Parametric Placement:
    - Logic to generate a grid ($N \times M$) of fixtures with spacing and height.
- [x] Implement `Simulation3DView`:
    - 3D view showing all fixtures (as simple 3D cubes/models).
    - Render a base "Work Plane" at $Z=0$ (or specified height).
- [x] Implement Fixture Manipulation UI:
    - Sidebar or dialog to edit selected fixture properties (XYZ coordinates, height, etc.).
    - Multi-select and bulk edit capability.
- [x] Verify by creating a 2x3 grid of fixtures and moving them around in 3D.
