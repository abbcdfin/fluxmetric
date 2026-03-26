import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ditredi/ditredi.dart';
import 'package:vector_math/vector_math_64.dart' as vector;
import 'package:fluxmetric_engine/fluxmetric_engine.dart';
import '../viewmodels/ies_visualizer_viewmodel.dart';
import '../viewmodels/simulation_viewmodel.dart';

class Ies3DView extends StatefulWidget {
  const Ies3DView({super.key});

  @override
  State<Ies3DView> createState() => _Ies3DViewState();
}

class _Ies3DViewState extends State<Ies3DView> {
  final _controller = DiTreDiController(
    rotationX: -20,
    rotationY: 30,
    light: vector.Vector3(-1, -1, -1),
    maxUserScale: 5.0,
    minUserScale: 0.1,
  );

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<IesVisualizerViewModel>();
    final simVm = context.read<SimulationViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('FluxMetric - IES Library'),
        actions: [
          if (vm.iesData != null) ...[
            ElevatedButton.icon(
              onPressed: () {
                simVm.addFixture(LightFixture(
                  id: 'f_${DateTime.now().millisecondsSinceEpoch}',
                  position: const math.Point(0, 0),
                  height: 5.0,
                  web: PhotometricWeb(vm.iesData!),
                ));
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Added fixture to Workspace')));
              },
              icon: const Icon(Icons.add),
              label: const Text('Add to Workspace'),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: () {
                simVm.createGridArray(
                  web: PhotometricWeb(vm.iesData!),
                  rows: 5,
                  cols: 5,
                  rowSpacing: 3.0,
                  colSpacing: 3.0,
                  height: 6.0,
                );
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Added 5x5 grid to Workspace')));
              },
              icon: const Icon(Icons.grid_view),
              label: const Text('Add 5x5 Grid'),
            ),
            const SizedBox(width: 16),
          ],
          IconButton(
            icon: const Icon(Icons.file_open),
            onPressed: () => vm.pickIesFile(),
            tooltip: 'Open IES File',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Row(
        children: [
          Expanded(
            flex: 3,
            child: Container(
              color: Colors.black87,
              child: vm.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : vm.webLines.isEmpty
                      ? const Center(
                          child: Text(
                            'Load an IES file to see the 3D web',
                            style: TextStyle(color: Colors.white70),
                          ),
                        )
                      : DiTreDiDraggable(
                          controller: _controller,
                          child: DiTreDi(
                            figures: [
                              ...vm.webLines,
                              Point3D(vector.Vector3(0, 0, 0), color: Colors.red),
                              Line3D(vector.Vector3(0,0,0), vector.Vector3(1,0,0), color: Colors.red), // X
                              Line3D(vector.Vector3(0,0,0), vector.Vector3(0,1,0), color: Colors.green), // Y
                              Line3D(vector.Vector3(0,0,0), vector.Vector3(0,0,1), color: Colors.blue), // Z
                            ],
                            controller: _controller,
                          ),
                        ),
            ),
          ),
          
          if (vm.iesData != null)
            Container(
              width: 300,
              color: Colors.grey[200],
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('IES Metadata', style: Theme.of(context).textTheme.titleLarge),
                    const Divider(),
                    ...vm.iesData!.keywords.entries.map((e) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(e.key, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                          Text(e.value, style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                    )),
                    const SizedBox(height: 16),
                    Text('Technical Data', style: Theme.of(context).textTheme.titleMedium),
                    const Divider(),
                    _techRow('Lamps', vm.iesData!.numberOfLamps.toString()),
                    _techRow('Lumens/Lamp', vm.iesData!.lumensPerLamp.toString()),
                    _techRow('Multiplier', vm.iesData!.candelaMultiplier.toString()),
                    _techRow('Vertical Angles', vm.iesData!.numberOfVerticalAngles.toString()),
                    _techRow('Horizontal Angles', vm.iesData!.numberOfHorizontalAngles.toString()),
                    _techRow('Input Watts', vm.iesData!.inputWatts.toString()),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _techRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        ],
      ),
    );
  }
}
