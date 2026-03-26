# Phase 1: Core Calculation Engine & IES Parsing JIT Plan

- [x] Initialize `fluxmetric_engine` Dart package.
- [x] Define `IesData` and `PhotometricWeb` models.
- [x] Implement `IesParser` for LM-63 (basic keyword and data block extraction).
- [x] Implement 3D vector-to-spherical coordinate conversion and interpolation logic.
- [x] Implement `PointByPointEngine` (Inverse Square, Cosine Law, Superposition).
- [x] Add unit tests for parsing, interpolation, and lux calculations.
- [x] Verify the engine against benchmark data.

**Refinements & Fixes:**
- [x] **3D Rotation Support**: Integrated `vector_math` to support fixture Tilt (X-axis) and Pan (Z-axis).
- [x] **Orientation Fix**: Corrected vertical distance logic (`dz = z - fixture.height`) to ensure fixtures face directly down (negative Z) by default.
- [x] **Coordinate Transformation**: Implemented global-to-local vector transformation for accurate IES lookups on tilted fixtures.
