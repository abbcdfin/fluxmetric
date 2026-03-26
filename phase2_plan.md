# Phase 2: Project Setup & 3D Visualizer Foundation JIT Plan

- [x] Initialize Flutter desktop project (`fluxmetric`).
- [x] Add dependencies: `ditredi`, `vector_math`, `file_picker`, and path reference to `fluxmetric_engine`.
- [x] Set up MVVM folder structure.
- [x] Implement `IesVisualizerViewModel`:
    - Method to pick and parse IES files.
    - Convert `IesData` into a collection of `Line3D` for the photometric web.
- [x] Implement `Ies3DView`:
    - Integrate `DiTreDi` widget.
    - Add basic camera controls (zoom, rotate).
    - Display fixture metadata.
- [x] Verify by importing a sample IES and viewing its 3D web.
