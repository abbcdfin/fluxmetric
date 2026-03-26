# Phase 2: Project Setup & 3D Visualizer Foundation JIT Plan

- [x] Initialize Flutter desktop project (`fluxmetric`).
- [x] Add dependencies: `ditredi`, `vector_math`, `file_picker`, `fast_gbk`, and path reference to `fluxmetric_engine`.
- [x] Set up MVVM folder structure.
- [x] Implement `IesVisualizerViewModel`:
    - [x] Method to pick and parse IES files.
    - [x] Convert `IesData` into a collection of `Line3D` for the photometric web.
- [x] Implement `Ies3DView`:
    - [x] Integrate `DiTreDi` widget.
    - [x] Add basic camera controls (zoom, rotate).
    - [x] Display fixture metadata.
- [x] Verify by importing a sample IES and viewing its 3D web.

**Refinements & Fixes:**
- [x] **Tiered Decoding**: Implemented robust IES file reading with UTF-8 first, fallback to GBK (for Chinese files), and final fallback to Latin-1.
- [x] **Export Alignment**: Updated `fluxmetric_engine.dart` to properly export models and the parser for application use.
