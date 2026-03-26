# FluxMetric Knowledge Base

## Technical Decisions

### IES File Decoding
- **Issue:** Some IES (LM-63) files use non-UTF-8 encodings (e.g., ISO-8859-1 / Latin-1), especially those containing non-ASCII characters in keywords or file names.
- **Solution:** Implement a tiered decoding strategy. Attempt to read the file as UTF-8 first; if it fails, fallback to `latin1` (ISO-8859-1).
- **Location:** `fluxmetric_app/lib/viewmodels/ies_visualizer_viewmodel.dart` in the `pickIesFile` method.

### 3D Engine Choice
- **Decision:** Used `ditredi` (pure-Dart 3D engine) over `flutter_scene` or `flutter_gpu`.
- **Reason:** `ditredi` is lightweight, cross-platform without experimental flags, and provides easy control over 3D primitive generation (`Line3D`, `Face3D`) which is ideal for engineering visualizations like photometric webs and heatmaps.

### Coordinate System
- **Orientation:** Nadir (fixture pointing straight down) is along the negative Z-axis.
- **Calculations:**
  - $\theta = 0$ at Nadir.
  - $\theta = 180$ at Zenith.
  - $\phi$ is the angle in the XY plane.
- **Implementation:** `PhotometricWeb.vectorToSpherical` converts 3D vectors to these $(\theta, \phi)$ coordinates for IES lookup.

## Known Constraints
- **Linux Platform:** The `file_picker` package requires `zenity` or `kdialog` to be installed on the host system to display native dialogs.
