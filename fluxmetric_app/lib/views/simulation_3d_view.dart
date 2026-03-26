import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ditredi/ditredi.dart';
import 'package:vector_math/vector_math_64.dart' as vector;
import 'package:fluxmetric_engine/fluxmetric_engine.dart';
import '../viewmodels/simulation_viewmodel.dart';
import '../viewmodels/calculation_viewmodel.dart';

class Simulation3DView extends StatefulWidget {
  const Simulation3DView({super.key});

  @override
  State<Simulation3DView> createState() => _Simulation3DViewState();
}

class _Simulation3DViewState extends State<Simulation3DView> {
  final _controller = DiTreDiController(
    rotationX: -20,
    rotationY: 30,
    light: vector.Vector3(-1, -1, -1),
    maxUserScale: 5.0,
    minUserScale: 0.1,
  );

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SimulationViewModel>();
    final calcVm = context.watch<CalculationViewModel>();

    return Scaffold(
      body: Row(
        children: [
          // 3D Viewport
          Expanded(
            flex: 4,
            child: Container(
              color: Colors.black87,
              child: Stack(
                children: [
                  DiTreDiDraggable(
                    controller: _controller,
                    child: DiTreDi(
                      figures: [
                        // Grid lines for reference
                        for (int i = -10; i <= 10; i++) ...[
                          Line3D(vector.Vector3(i.toDouble(), -10, 0), vector.Vector3(i.toDouble(), 10, 0), color: Colors.white10),
                          Line3D(vector.Vector3(-10, i.toDouble(), 0), vector.Vector3(10, i.toDouble(), 0), color: Colors.white10),
                        ],
                        
                        // Work Plane reference
                        Plane3D(
                          20.0,
                          Axis3D.z,
                          false,
                          vector.Vector3(0, 0, vm.scene.workPlaneHeight),
                          color: Colors.blue.withOpacity(0.05),
                        ),

                        // Heatmap
                        if (calcVm.heatmapFaces.isNotEmpty)
                          ...calcVm.heatmapFaces.map((f) => Face3D(
                            vector.Triangle.points(
                              f.triangle.point0 + vector.Vector3(0, 0, vm.scene.workPlaneHeight),
                              f.triangle.point1 + vector.Vector3(0, 0, vm.scene.workPlaneHeight),
                              f.triangle.point2 + vector.Vector3(0, 0, vm.scene.workPlaneHeight),
                            ),
                            color: f.color,
                          )),

                        // Fixtures
                        for (var fixture in vm.scene.fixtures)
                          _buildFixture3D(fixture, vm.isSelected(fixture.id)),

                        // Origin marker
                        Point3D(vector.Vector3(0, 0, 0), color: Colors.red),
                        Line3D(vector.Vector3(0,0,0), vector.Vector3(1,0,0), color: Colors.red),
                        Line3D(vector.Vector3(0,0,0), vector.Vector3(0,1,0), color: Colors.green),
                        Line3D(vector.Vector3(0,0,0), vector.Vector3(0,0,1), color: Colors.blue),
                      ],
                      controller: _controller,
                    ),
                  ),
                  if (calcVm.isCalculating)
                    const Center(
                      child: Card(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(height: 16),
                              Text('Calculating Illuminance...'),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Sidebar
          Container(
            width: 300,
            color: Colors.grey[100],
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Simulation Workspace', style: Theme.of(context).textTheme.titleLarge),
                const Divider(),
                
                Text('Scene Settings', style: Theme.of(context).textTheme.titleSmall),
                _numericInput('Work Plane Height (m)', vm.scene.workPlaneHeight, (val) => vm.setWorkPlaneHeight(val)),
                
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: vm.scene.fixtures.isEmpty || calcVm.isCalculating
                      ? null
                      : () => calcVm.runCalculation(
                            fixtures: vm.scene.fixtures,
                            workPlaneHeight: vm.scene.workPlaneHeight,
                            width: 20,
                            length: 20,
                            resolution: 0.5,
                          ),
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Run Calculation'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 40),
                  ),
                ),

                if (calcVm.result != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Results', style: Theme.of(context).textTheme.titleSmall),
                        const Divider(),
                        _resultRow('Average Lux', calcVm.result!.average.toStringAsFixed(1)),
                        _resultRow('Min Lux', calcVm.result!.min.toStringAsFixed(1)),
                        _resultRow('Max Lux', calcVm.result!.max.toStringAsFixed(1)),
                        _resultRow('Uniformity (U₀)', calcVm.result!.uniformity.toStringAsFixed(3)),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 24),
                Text('Selection (${vm.selectedFixtures.length})', style: Theme.of(context).textTheme.titleSmall),
                if (vm.selectedFixtures.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _numericInput('Fixture Height (m)', vm.selectedFixtures.last.height, (val) => vm.updateSelectedHeight(val)),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () => vm.removeSelected(),
                    icon: const Icon(Icons.delete),
                    label: const Text('Remove Selected'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[50],
                      minimumSize: const Size(double.infinity, 32),
                    ),
                  ),
                ] else
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Text('No fixtures selected', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Model3D _buildFixture3D(LightFixture fixture, bool isSelected) {
    final pos = vector.Vector3(fixture.position.x, fixture.position.y, fixture.height);
    final color = isSelected ? Colors.yellow : Colors.blue;
    
    return Group3D([
      Cube3D(0.2, pos, color: color),
      Line3D(pos, pos + vector.Vector3(0, 0, -0.5), color: color.withOpacity(0.5)),
    ]);
  }

  Widget _numericInput(String label, double value, Function(double) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        decoration: InputDecoration(
          labelText: label,
          isDense: true,
          border: const OutlineInputBorder(),
        ),
        keyboardType: TextInputType.number,
        controller: TextEditingController(text: value.toString()),
        onSubmitted: (val) {
          final doubleValue = double.tryParse(val);
          if (doubleValue != null) onChanged(doubleValue);
        },
      ),
    );
  }

  Widget _resultRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }
}
