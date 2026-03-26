# FluxMetric

## Introduction
**FluxMetric** is a high-precision, cross-platform lighting evaluation tool built for engineers. It prioritizes **mathematical accuracy** and **computational efficiency** over photorealistic rendering. The application allows engineers to import industry-standard photometric data, visualize light distribution, and simulate complex deployment plans to ensure compliance with technical lighting requirements.

---

## Strategy

### 1. Scientific Foundation (The "Why")
This application is possible because professional lighting simulation relies on deterministic physics. **FluxMetric** utilizes the **Point-by-Point Method** based on four core pillars:

* **Photometric Digitization (The IES File):** Industry-standard .ies files (LM-63) act as the "Digital Twin" of a physical light fixture. They provide a high-resolution map of **Luminous Intensity ($I$)** measured in candelas across a spherical coordinate system ($\theta, \phi$). Instead of guessing light output, the engine "looks up" the exact intensity for any specific vector.
* **Inverse Square Law:** Once the intensity $I$ is retrieved from the IES file, the illuminance ($E$) at a point is calculated as inversely proportional to the square of the distance ($d$).
  $$E = \frac{I(\theta, \phi)}{d^2}$$
* **Lambert’s Cosine Law:** To find the precise Lux on a flat work plane, the calculation accounts for the angle ($\alpha$) at which the light ray strikes the surface.
  $$E_{h} = \frac{I(\theta, \phi) \cdot \cos \alpha}{d^2}$$
* **Principle of Superposition (Additive Property):** For multi-fixture environments, the total illuminance ($E_{total}$) at any specific coordinate is the algebraic sum of the individual contributions from every light source.
  $$E_{total} = \sum_{i=1}^{n} E_i$$

### 2. Execution Plan
1. **Engine-First Development:** Develop the "Point-by-Point" calculation engine as a standalone Dart package before building the UI.
2. **Desktop-Centric UX:** Focus on mouse/keyboard interactions, including right-click menus, drag-and-drop, and precise coordinate-based inputs.
3. **Modular Rollout:**
    * **Phase 1:** IES Parsing & 3D Web Visualization.
    * **Phase 2:** Parametric Array Logic (The "Precision Placement" system).
    * **Phase 3:** Calculation Engine & Heatmap Overlays.

---

## Core Features
* **IES 3D Visualizer:** Interactive 3D "Photometric Web" inspector for individual fixtures to visualize beam distribution (e.g., batwing, narrow, or asymmetric).
* **Parametric Placement Engine:**
    * **Grid Array:** Programmatic deployment by defining $N \times M$ fixtures, intervals (spacing), and offsets from boundaries.
    * **Bulk Management:** Grouping and mass-editing of fixture heights, tilts, and rotations.
* **Precision Evaluation:**
    * **Calculation Grid:** A user-defined "Work Plane" (e.g., 0.8m height) where Lux is calculated at every grid intersection.
    * **Compliance Metrics:** Automatic readout of $E_{avg}$ (Average Lux) and $U_0$ (Uniformity ratio $E_{min} / E_{avg}$).
* **Visual Analysis:** Color-coded **Isolux heatmaps** and numerical grid overlays for engineering validation.

---

## Architecture Considerations
* **Framework:** **Flutter (Dart)** for cross-platform desktop support (Windows, macOS, Linux).
* **Asynchronous Processing:** Use **Background Isolates** for the calculation engine to keep the UI responsive during complex $E_{total}$ summations for hundreds of points.
* **Design Pattern:** **MVVM (Model-View-ViewModel)** to decouple the physics engine (Model) from the interactive CAD canvas (View).
* **Rendering Strategy:**
    * **2D Workspace:** High-performance rendering via `CustomPainter` for CAD-like floor plans.
    * **3D Inspector:** Lightweight vertex-based rendering for the IES web (avoiding heavy game engines).
* **Data Persistence:** Projects are saved as **JSON** files, ensuring designs are lightweight, human-readable, and version-control friendly.
