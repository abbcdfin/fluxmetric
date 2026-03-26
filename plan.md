# FluxMetric Revised Development Plan

## Background & Motivation
FluxMetric is a high-precision lighting simulation tool that requires robust workspace definition and technical fixture placement. This revised plan focuses on Phase 3 and Phase 4, addressing workspace area definition (Width/Length), programmatic grid placement with automatic centering, and independent hanging height management for each light fixture. Structured data export is deferred to a future phase.

## Phased Implementation Plan

### Phase 1: Core Calculation Engine & IES Parsing (Standalone Dart Package) [COMPLETED]
- **Summary:** Successfully built `fluxmetric_engine` Dart package. Implemented LM-63 IES parser, bilinear interpolation for photometric webs, and the Point-by-Point calculation engine supporting Inverse Square and Cosine Laws with superposition. Verified via unit and integration tests.

### Phase 2: Project Setup & 3D Visualizer Foundation [COMPLETED]
- **Summary:** Initialized Flutter desktop project with MVVM architecture. Integrated `fluxmetric_engine` and `ditredi` 3D engine. Implemented `IesVisualizerViewModel` and `Ies3DView` capable of loading IES files, parsing them, and rendering their 3D photometric webs with camera controls and metadata display. Verified via successful Linux build.

### Phase 3: 3D Simulation Workspace & Technical Placement [COMPLETED]
- **Summary**: Transformed the workspace into a technical design tool. Added `width` and `length` to the simulation area with 3D boundary visualization. Implemented a programmatic **Grid Array Dialog** with auto-centering and manual override options. Developed a comprehensive **Fixture Management UI** in the sidebar, including a scrollable fixture list and individual/bulk controls for X, Y, and hanging height (Z). Verified via successful 3x3 grid deployment and individual height adjustment.

### Phase 4: Calculation Engine Integration & 3D Visual Analysis [COMPLETED]
- **Summary**: Integrated the core engine with the UI to perform illuminance calculations within the defined workspace boundaries. Implemented `CalculationViewModel` using background isolates for non-blocking, multi-fixture calculations. Developed a dynamic 3D heatmap rendering system that maps lux values to a color-coded mesh overlaid on the work plane. Added UI for real-time compliance metrics (Average Lux and Uniformity). Verified via successful multi-fixture simulation and calculation runs.

## Project Complete
FluxMetric is now a high-precision 3D lighting evaluation tool supporting robust workspace definition, technical fixture placement, and interactive visual analysis.

## Work Flow (Vibe Coding)
- We will use `./plan.md` in the workspace as the interactive design board.
- For each phase, a Just-In-Time (JIT) granular plan will be formulated before execution.
- Upon phase completion, `./plan.md` will be updated with a concise summary.
- Progress and critical milestones will be tracked in `./checkpoint.md`.
- Architectural decisions and hardware quirks will be documented in `./knowledge.md`.
