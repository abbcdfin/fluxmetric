# FluxMetric Development Plan

## Background & Motivation
FluxMetric is a high-precision, cross-platform lighting simulation tool built for engineers. It prioritizes mathematical accuracy (using the Point-by-Point method) and computational efficiency over photorealistic rendering. The application allows importing IES photometric data, visualizing light distribution, and simulating complex deployment plans.

## Scope & Impact
The project encompasses the development of a core lighting calculation engine (Dart package) and a cross-platform desktop UI (Flutter). Driven by user feedback, the application will feature a **proper 3D simulation environment** for both placing light fixtures and visualizing photometric distributions and resulting lux heatmaps, moving beyond a simple 2D CAD plan.

## Proposed Solution (Architecture)
- **Framework:** Flutter (Dart) targeting desktop (Windows, macOS, Linux).
- **Architecture Pattern:** MVVM (Model-View-ViewModel) to decouple the physics engine from the UI.
- **Core Engine:** Standalone Dart package for parsing IES files and performing Point-by-Point calculations.
- **Performance:** Background Isolates for parallel processing of illuminance ($E_{total}$) matrices.
- **Rendering:** Interactive 3D Workspace utilizing a suitable Flutter 3D rendering solution (to be evaluated, e.g., `flutter_cube`, `ditredi`, or `flutter_gpu` for Impeller) to handle full 3D coordinate placement, 3D IES web visualization, and 3D plane heatmaps.
- **Data Persistence:** JSON-based project files.

## Phased Implementation Plan

### Phase 1: Core Calculation Engine & IES Parsing (Standalone Dart Package) [COMPLETED]
- **Summary:** Successfully built `fluxmetric_engine` Dart package. Implemented LM-63 IES parser, bilinear interpolation for photometric webs, and the Point-by-Point calculation engine supporting Inverse Square and Cosine Laws with superposition. Verified via unit and integration tests.

### Phase 2: Project Setup & 3D Visualizer Foundation [COMPLETED]
- **Summary:** Initialized Flutter desktop project with MVVM architecture. Integrated `fluxmetric_engine` and `ditredi` 3D engine. Implemented `IesVisualizerViewModel` and `Ies3DView` capable of loading IES files, parsing them, and rendering their 3D photometric webs with camera controls and metadata display. Verified via successful Linux build.

### Phase 3: 3D Simulation Workspace & Parametric Placement [COMPLETED]
- **Summary:** Developed the 3D simulation workspace. Implemented `SimulationViewModel` for scene management and `Simulation3DView` for interactive 3D visualization. Added parametric grid placement logic and UI for fixture manipulation (height, selection, removal). Enabled navigation between library and workspace. Verified via successful build.

### Phase 4: Calculation Engine Integration & 3D Visual Analysis [COMPLETED]
- **Summary:** Integrated the core engine with the UI. Implemented `CalculationViewModel` using background isolates for high-performance illuminance grid calculations. Developed a 3D heatmap rendering system that maps lux values to a color-coded mesh overlaid on the work plane. Added UI for real-time compliance metrics ($E_{avg}, U_0$). Verified via final build.

## Project Complete
FluxMetric is now a functional 3D lighting evaluation tool with IES parsing, 3D visualization, parametric placement, and heatmapping capabilities.

## Work Flow (Vibe Coding)
- We will use `./plan.md` in the workspace as the interactive design board.
- For each phase, a Just-In-Time (JIT) granular plan will be formulated before execution.
- Upon phase completion, `./plan.md` will be updated with a concise summary.
- Progress and critical milestones will be tracked in `./checkpoint.md`.
- Architectural decisions and hardware quirks will be documented in `./knowledge.md`.
