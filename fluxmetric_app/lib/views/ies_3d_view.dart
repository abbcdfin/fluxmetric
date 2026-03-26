import 'dart:io';
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

    return Row(
      children: [
        // Column 2: View Area
        Expanded(
          flex: 3,
          child: Column(
            children: [
              // Local Header for Viewport
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: Theme.of(context).colorScheme.surface,
                child: Row(
                  children: [
                    const Icon(Icons.library_books, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text('IES Library', style: Theme.of(context).textTheme.titleMedium),
                    const Spacer(),
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
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Add to Workspace'),
                        style: ElevatedButton.styleFrom(visualDensity: VisualDensity.compact),
                      ),
                      const SizedBox(width: 8),
                    ],
                    IconButton(
                      icon: const Icon(Icons.file_open),
                      onPressed: () => vm.pickIesFile(),
                      tooltip: 'Open IES File',
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              
              // 3D Viewport
              Expanded(
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
                                  Line3D(vector.Vector3(0,0,0), vector.Vector3(1,0,0), color: Colors.red),
                                  Line3D(vector.Vector3(0,0,0), vector.Vector3(0,1,0), color: Colors.green),
                                  Line3D(vector.Vector3(0,0,0), vector.Vector3(0,0,1), color: Colors.blue),
                                ],
                                controller: _controller,
                              ),
                            ),
                ),
              ),
            ],
          ),
        ),
        
        // Column 3: Operation Panel (Metadata)
        Container(
          width: 300,
          decoration: BoxDecoration(
            color: Colors.grey[50],
            border: const Border(left: BorderSide(color: Colors.grey, width: 0.5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('IES Metadata', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                    const Text('Technical specifications', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
              const Divider(height: 1),
              
              if (vm.iesData != null)
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ...vm.iesData!.keywords.entries.map((e) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(e.key, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                              Text(e.value, style: const TextStyle(fontSize: 11)),
                            ],
                          ),
                        )),
                        const SizedBox(height: 16),
                        Text('Technical Data', style: Theme.of(context).textTheme.titleSmall),
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
                )
              else
                const Expanded(
                  child: Center(
                    child: Text('No data loaded', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _techRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 11)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
        ],
      ),
    );
  }
}
