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
                    Text(vm.selectedEntry?.displayName ?? 'IES Library', style: Theme.of(context).textTheme.titleMedium),
                    const Spacer(),
                    if (vm.selectedEntry != null) ...[
                      ElevatedButton.icon(
                        onPressed: () {
                          simVm.addFixture(LightFixture(
                            id: 'f_${DateTime.now().millisecondsSinceEpoch}',
                            position: const math.Point(0, 0),
                            height: 5.0,
                            web: PhotometricWeb(vm.selectedEntry!.data),
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
                      tooltip: 'Import IES Files',
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
                                'Import IES files to populate your library',
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
        
        // Column 3: Library & Metadata
        Container(
          width: 350,
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
                    Text('Manage Library', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                    Text('${vm.library.length} files imported', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
              const Divider(height: 1),
              
              // Library List
              SizedBox(
                height: 250,
                child: ListView.builder(
                  itemCount: vm.library.length,
                  itemBuilder: (context, index) {
                    final entry = vm.library[index];
                    final isSelected = vm.selectedIndex == index;
                    return ListTile(
                      dense: true,
                      selected: isSelected,
                      selectedTileColor: Colors.blue[50],
                      leading: const Icon(Icons.lightbulb_outline),
                      title: Text(entry.displayName, style: const TextStyle(fontSize: 12, overflow: TextOverflow.ellipsis)),
                      subtitle: Text(entry.fileName, style: const TextStyle(fontSize: 9, color: Colors.grey)),
                      onTap: () => vm.selectEntry(index),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_note, size: 18),
                            onPressed: () => _editNameDialog(context, vm, index, entry.displayName),
                            tooltip: 'Rename',
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, size: 18),
                            onPressed: () => vm.removeEntry(index),
                            tooltip: 'Remove',
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text('Selected Metadata', style: Theme.of(context).textTheme.titleSmall),
              ),

              if (vm.iesData != null)
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
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
                        Text('Technical Data', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        const Divider(),
                        _techRow('Lamps', vm.iesData!.numberOfLamps.toString()),
                        _techRow('Lumens/Lamp', vm.iesData!.lumensPerLamp.toString()),
                        _techRow('Multiplier', vm.iesData!.candelaMultiplier.toString()),
                        _techRow('Vertical Angles', vm.iesData!.numberOfVerticalAngles.toString()),
                        _techRow('Horizontal Angles', vm.iesData!.numberOfHorizontalAngles.toString()),
                        _techRow('Input Watts', vm.iesData!.inputWatts.toString()),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                )
              else
                const Expanded(
                  child: Center(
                    child: Text('Select a file to view data', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  void _editNameDialog(BuildContext context, IesVisualizerViewModel vm, int index, String currentName) {
    final controller = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename Library Entry'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Display Name'),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              vm.renameEntry(index, controller.text);
              Navigator.pop(context);
            },
            child: const Text('Rename'),
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
          Text(label, style: const TextStyle(fontSize: 11)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
        ],
      ),
    );
  }
}
