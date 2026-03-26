import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fluxmetric_engine/fluxmetric_engine.dart';
import '../viewmodels/simulation_viewmodel.dart';
import '../viewmodels/ies_visualizer_viewmodel.dart';

class GridPlacementDialog extends StatefulWidget {
  const GridPlacementDialog({super.key});

  @override
  State<GridPlacementDialog> createState() => _GridPlacementDialogState();
}

class _GridPlacementDialogState extends State<GridPlacementDialog> {
  late TextEditingController _rowsController;
  late TextEditingController _colsController;
  late TextEditingController _rowSpacingController;
  late TextEditingController _colSpacingController;
  late TextEditingController _heightController;
  late TextEditingController _startXController;
  late TextEditingController _startYController;
  
  bool _autoCenter = true;

  @override
  void initState() {
    super.initState();
    _rowsController = TextEditingController(text: '4');
    _colsController = TextEditingController(text: '4');
    _rowSpacingController = TextEditingController(text: '3.0');
    _colSpacingController = TextEditingController(text: '3.0');
    _heightController = TextEditingController(text: '5.0');
    _startXController = TextEditingController(text: '0.0');
    _startYController = TextEditingController(text: '0.0');
  }

  @override
  void dispose() {
    _rowsController.dispose();
    _colsController.dispose();
    _rowSpacingController.dispose();
    _colSpacingController.dispose();
    _heightController.dispose();
    _startXController.dispose();
    _startYController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final simVm = context.read<SimulationViewModel>();
    final iesVm = context.read<IesVisualizerViewModel>();

    return AlertDialog(
      title: const Text('Add Grid Array'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(child: _input('Rows (N)', _rowsController, true)),
                const SizedBox(width: 8),
                Expanded(child: _input('Cols (M)', _colsController, true)),
              ],
            ),
            Row(
              children: [
                Expanded(child: _input('Row Spacing (m)', _rowSpacingController, false)),
                const SizedBox(width: 8),
                Expanded(child: _input('Col Spacing (m)', _colSpacingController, false)),
              ],
            ),
            _input('Hanging Height (m)', _heightController, false),
            
            const Divider(),
            SwitchListTile(
              title: const Text('Auto-Center in Workspace', style: TextStyle(fontSize: 14)),
              value: _autoCenter,
              onChanged: (val) => setState(() => _autoCenter = val),
            ),
            
            if (!_autoCenter)
              Row(
                children: [
                  Expanded(child: _input('Start X', _startXController, false)),
                  const SizedBox(width: 8),
                  Expanded(child: _input('Start Y', _startYController, false)),
                ],
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final selectedIes = iesVm.selectedEntry?.data;
            if (selectedIes != null) {
              simVm.createGridArray(
                web: PhotometricWeb(selectedIes),
                rows: int.tryParse(_rowsController.text) ?? 4,
                cols: int.tryParse(_colsController.text) ?? 4,
                rowSpacing: double.tryParse(_rowSpacingController.text) ?? 3.0,
                colSpacing: double.tryParse(_colSpacingController.text) ?? 3.0,
                height: double.tryParse(_heightController.text) ?? 5.0,
                autoCenter: _autoCenter,
                startX: double.tryParse(_startXController.text) ?? 0.0,
                startY: double.tryParse(_startYController.text) ?? 0.0,
              );
              Navigator.of(context).pop();
            }
          },
          child: const Text('Add Grid'),
        ),
      ],
    );
  }

  Widget _input(String label, TextEditingController controller, bool isInt) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(labelText: label, isDense: true, border: const OutlineInputBorder()),
        keyboardType: isInt ? TextInputType.number : const TextInputType.numberWithOptions(decimal: true),
      ),
    );
  }
}
