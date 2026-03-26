import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ditredi/ditredi.dart';
import 'package:vector_math/vector_math_64.dart' as vector;
import 'package:fluxmetric_engine/fluxmetric_engine.dart';
import '../viewmodels/simulation_viewmodel.dart';
import '../viewmodels/calculation_viewmodel.dart';
import '../widgets/grid_placement_dialog.dart';
import '../viewmodels/ies_visualizer_viewmodel.dart';
import 'heatmap_2d_view.dart';

class Simulation3DView extends StatefulWidget {
  const Simulation3DView({super.key});

  @override
  State<Simulation3DView> createState() => _Simulation3DViewState();
}

class _Simulation3DViewState extends State<Simulation3DView> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _controller = DiTreDiController(
    rotationX: -20,
    rotationY: 30,
    light: vector.Vector3(-1, -1, -1),
    maxUserScale: 5.0,
    minUserScale: 0.1,
  );

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  void _resetToTopView() {
    setState(() {
      _controller.rotationX = 0;
      _controller.rotationY = 0;
      _controller.userScale = 1.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SimulationViewModel>();
    final calcVm = context.watch<CalculationViewModel>();
    final iesVm = context.watch<IesVisualizerViewModel>();

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '3D View', icon: Icon(Icons.view_in_ar)),
            Tab(text: '2D Technical Heatmap', icon: Icon(Icons.map)),
          ],
        ),
      ),
      body: Row(
        children: [
          Expanded(
            flex: 4,
            child: TabBarView(
              controller: _tabController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                Container(
                  color: Colors.black87,
                  child: Stack(
                    children: [
                      DiTreDiDraggable(
                        controller: _controller,
                        child: DiTreDi(
                          figures: [
                            for (int i = -10; i <= 10; i++) ...[
                              Line3D(vector.Vector3(i.toDouble(), -10, 0), vector.Vector3(i.toDouble(), 10, 0), color: Colors.white10),
                              Line3D(vector.Vector3(-10, i.toDouble(), 0), vector.Vector3(10, i.toDouble(), 0), color: Colors.white10),
                            ],
                            Plane3D(
                              vm.scene.width > vm.scene.length ? vm.scene.width : vm.scene.length,
                              Axis3D.z,
                              false,
                              vector.Vector3(0, 0, 0),
                              color: Colors.white.withOpacity(0.05),
                            ),
                            Plane3D(
                              vm.scene.width > vm.scene.length ? vm.scene.width : vm.scene.length,
                              Axis3D.z,
                              false,
                              vector.Vector3(0, 0, vm.scene.workPlaneHeight),
                              color: Colors.blue.withOpacity(0.05),
                            ),
                            if (calcVm.heatmapFaces.isNotEmpty)
                              ...calcVm.heatmapFaces.map((f) => Face3D(
                                vector.Triangle.points(
                                  f.triangle.point0,
                                  f.triangle.point1,
                                  f.triangle.point2,
                                ),
                                color: f.color,
                              )),
                            for (var fixture in vm.scene.fixtures)
                              _buildFixture3D(fixture, vm.isSelected(fixture.id)),
                            if (vm.selectedFixtures.length == 1)
                              ..._buildWebOverlay(vm.selectedFixtures.first, iesVm.webLines),
                            Point3D(vector.Vector3(0, 0, 0), color: Colors.red),
                            Line3D(vector.Vector3(0,0,0), vector.Vector3(1,0,0), color: Colors.red),
                            Line3D(vector.Vector3(0,0,0), vector.Vector3(0,1,0), color: Colors.green),
                            Line3D(vector.Vector3(0,0,0), vector.Vector3(0,0,1), color: Colors.blue),
                          ],
                          controller: _controller,
                        ),
                      ),
                      Positioned(
                        top: 16,
                        right: 16,
                        child: FloatingActionButton.small(
                          onPressed: _resetToTopView,
                          tooltip: 'Reset Top View',
                          child: const Icon(Icons.vertical_align_bottom),
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
                const Heatmap2DView(),
              ],
            ),
          ),

          // Sidebar
          Container(
            width: 350,
            color: Colors.grey[100],
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Simulation Workspace', style: Theme.of(context).textTheme.titleLarge),
                        const Divider(),
                        
                        Text('Workspace Size (m)', style: Theme.of(context).textTheme.titleSmall),
                        Row(
                          children: [
                            Expanded(child: TechnicalInput(label: 'Width', value: vm.scene.width, onChanged: (val) => vm.setWorkspaceSize(val, vm.scene.length))),
                            const SizedBox(width: 8),
                            Expanded(child: TechnicalInput(label: 'Length', value: vm.scene.length, onChanged: (val) => vm.setWorkspaceSize(vm.scene.width, val))),
                          ],
                        ),
                        TechnicalInput(label: 'Work Plane Height (m)', value: vm.scene.workPlaneHeight, onChanged: (val) => vm.setWorkPlaneHeight(val)),
                        
                        const SizedBox(height: 16),
                        Text('Heatmap Scale', style: Theme.of(context).textTheme.titleSmall),
                        SwitchListTile(
                          title: const Text('Dynamic Scale', style: TextStyle(fontSize: 12)),
                          value: calcVm.isDynamicScale,
                          dense: true,
                          onChanged: (val) => calcVm.setScaleSettings(val, calcVm.fixedMaxLux),
                        ),
                        if (!calcVm.isDynamicScale)
                          TechnicalInput(label: 'Fixed Max Lux', value: calcVm.fixedMaxLux, onChanged: (val) => calcVm.setScaleSettings(false, val)),

                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: vm.scene.fixtures.isEmpty || calcVm.isCalculating
                                    ? null
                                    : () => calcVm.runCalculation(
                                          fixtures: vm.scene.fixtures,
                                          workPlaneHeight: vm.scene.workPlaneHeight,
                                          width: vm.scene.width,
                                          length: vm.scene.length,
                                          resolution: 0.5,
                                        ),
                                icon: const Icon(Icons.play_arrow),
                                label: const Text('Calculate'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              onPressed: iesVm.iesData == null ? null : () => _showGridPlacementDialog(context),
                              icon: const Icon(Icons.grid_on),
                              tooltip: 'Add Grid Array',
                            ),
                          ],
                        ),

                        if (calcVm.result != null) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: Colors.blue[100]!),
                            ),
                            child: Column(
                              children: [
                                _resultRow('Avg Lux', calcVm.result!.average.toStringAsFixed(1)),
                                _resultRow('Uniformity', calcVm.result!.uniformity.toStringAsFixed(3)),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Fixtures (${vm.scene.fixtures.length})', style: Theme.of(context).textTheme.titleSmall),
                        Row(
                          children: [
                            TextButton(onPressed: () => vm.selectAll(), child: const Text('All', style: TextStyle(fontSize: 10))),
                            TextButton(onPressed: () => vm.clearSelection(), child: const Text('None', style: TextStyle(fontSize: 10))),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(
                    height: 200,
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: vm.scene.fixtures.length,
                      itemBuilder: (context, index) {
                        final f = vm.scene.fixtures[index];
                        final isSelected = vm.isSelected(f.id);
                        return ListTile(
                          dense: true,
                          selected: isSelected,
                          selectedTileColor: Colors.blue[50],
                          title: Text('Fixture ${index + 1}', style: const TextStyle(fontSize: 12)),
                          subtitle: Text('Pos: (${f.position.x}, ${f.position.y}) | H: ${f.height}m', style: const TextStyle(fontSize: 10)),
                          onTap: () => vm.toggleSelection(f.id, multi: false),
                          trailing: isSelected ? const Icon(Icons.check_circle, size: 16, color: Colors.blue) : null,
                        );
                      },
                    ),
                  ),

                  if (vm.selectedFixtures.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, -2))],
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(child: TechnicalInput(label: 'X', value: vm.selectedFixtures.last.position.x, onChanged: (val) => vm.updateSelectedPosition(val, null))),
                              const SizedBox(width: 8),
                              Expanded(child: TechnicalInput(label: 'Y', value: vm.selectedFixtures.last.position.y, onChanged: (val) => vm.updateSelectedPosition(null, val))),
                              const SizedBox(width: 8),
                              Expanded(child: TechnicalInput(label: 'H', value: vm.selectedFixtures.last.height, onChanged: (val) => vm.updateSelectedHeight(val))),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(child: TechnicalInput(label: 'Tilt (X)', value: vm.selectedFixtures.last.tilt, onChanged: (val) => vm.updateSelectedRotation(val, null))),
                              const SizedBox(width: 8),
                              Expanded(child: TechnicalInput(label: 'Pan (Z)', value: vm.selectedFixtures.last.rotation, onChanged: (val) => vm.updateSelectedRotation(null, val))),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton.icon(
                            onPressed: () => vm.removeSelected(),
                            icon: const Icon(Icons.delete),
                            label: const Text('Remove Selected'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red[50],
                              foregroundColor: Colors.red,
                              minimumSize: const Size(double.infinity, 32),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showGridPlacementDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const GridPlacementDialog(),
    );
  }

  Model3D _buildFixture3D(LightFixture fixture, bool isSelected) {
    final pos = vector.Vector3(fixture.position.x, fixture.position.y, fixture.height);
    final color = isSelected ? Colors.yellow : Colors.blue;
    
    final matrix = vector.Matrix4.identity()
      ..translate(pos)
      ..rotateZ(fixture.rotation * math.pi / 180.0)
      ..rotateX(fixture.tilt * math.pi / 180.0);
    
    return TransformModifier3D(
      Group3D([
        Cube3D(0.2, vector.Vector3(0, 0, 0), color: color),
        Line3D(vector.Vector3(0, 0, 0), vector.Vector3(0, 0, -0.5), color: color.withOpacity(0.5)),
      ]),
      matrix,
    );
  }

  List<Model3D> _buildWebOverlay(LightFixture fixture, List<Line3D> webLines) {
    final pos = vector.Vector3(fixture.position.x, fixture.position.y, fixture.height);
    
    final matrix = vector.Matrix4.identity()
      ..translate(pos)
      ..rotateZ(fixture.rotation * math.pi / 180.0)
      ..rotateX(fixture.tilt * math.pi / 180.0);

    return [
      TransformModifier3D(
        Group3D(webLines.map((l) => Line3D(l.a, l.b, color: Colors.yellow.withOpacity(0.2))).toList()),
        matrix,
      )
    ];
  }

  Widget _resultRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 11)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        ],
      ),
    );
  }
}

/// A robust input widget for technical values that doesn't reset focus on every rebuild.
class TechnicalInput extends StatefulWidget {
  final String label;
  final double value;
  final Function(double) onChanged;

  const TechnicalInput({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  State<TechnicalInput> createState() => _TechnicalInputState();
}

class _TechnicalInputState extends State<TechnicalInput> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value.toString());
  }

  @override
  void didUpdateWidget(TechnicalInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only update text if the value actually changed from the outside (not from user typing)
    if (widget.value != double.tryParse(_controller.text)) {
      _controller.text = widget.value.toString();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: TextField(
        controller: _controller,
        decoration: InputDecoration(
          labelText: widget.label,
          isDense: true,
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        ),
        style: const TextStyle(fontSize: 12),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        onSubmitted: (val) {
          final doubleValue = double.tryParse(val);
          if (doubleValue != null) widget.onChanged(doubleValue);
        },
      ),
    );
  }
}
