import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/calculation_viewmodel.dart';
import '../viewmodels/simulation_viewmodel.dart';

class Heatmap2DView extends StatelessWidget {
  const Heatmap2DView({super.key});

  @override
  Widget build(BuildContext context) {
    final calcVm = context.watch<CalculationViewModel>();
    final simVm = context.watch<SimulationViewModel>();

    if (calcVm.result == null) {
      return const Center(
        child: Text('Run calculation to see the 2D heatmap', style: TextStyle(color: Colors.grey)),
      );
    }

    final effectiveMax = calcVm.isDynamicScale ? calcVm.result!.max : calcVm.fixedMaxLux;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          color: Colors.white,
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Expanded(
                child: InteractiveViewer(
                  boundaryMargin: const EdgeInsets.all(100),
                  minScale: 0.1,
                  maxScale: 10.0,
                  child: Center(
                    child: AspectRatio(
                      aspectRatio: simVm.scene.width / simVm.scene.length,
                      child: CustomPaint(
                        painter: HeatmapPainter(
                          result: calcVm.result!,
                          width: simVm.scene.width,
                          length: simVm.scene.length,
                          maxLux: effectiveMax,
                        ),
                        size: Size.infinite,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildLegend(effectiveMax),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLegend(double maxLux) {
    return Container(
      height: 20,
      width: 300,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.blue, Colors.green, Colors.yellow, Colors.red],
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: const Text('0 lx', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text('${maxLux.toStringAsFixed(0)} lx', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black)),
          ),
        ],
      ),
    );
  }
}

class HeatmapPainter extends CustomPainter {
  final GridResult result;
  final double width;
  final double length;
  final double maxLux;

  HeatmapPainter({
    required this.result,
    required this.width,
    required this.length,
    required this.maxLux,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rows = result.values.length;
    final cols = result.values[0].length;
    
    final cellWidth = size.width / (cols - 1);
    final cellHeight = size.height / (rows - 1);

    final paint = Paint()..style = PaintingStyle.fill;

    for (int r = 0; r < rows - 1; r++) {
      for (int c = 0; c < cols - 1; c++) {
        final val = (result.values[r][c] + result.values[r][c+1] + 
                     result.values[r+1][c] + result.values[r+1][c+1]) / 4;
        
        paint.color = _luxToColor(val, maxLux);
        
        final rect = Rect.fromLTWH(
          c * cellWidth,
          (rows - 2 - r) * cellHeight,
          cellWidth + 0.5,
          cellHeight + 0.5,
        );
        
        canvas.drawRect(rect, paint);
      }
    }

    final gridPaint = Paint()
      ..color = Colors.black.withOpacity(0.1)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < cols; i++) {
      canvas.drawLine(Offset(i * cellWidth, 0), Offset(i * cellWidth, size.height), gridPaint);
    }
    for (int i = 0; i < rows; i++) {
      canvas.drawLine(Offset(0, i * cellHeight), Offset(size.width, i * cellHeight), gridPaint);
    }
  }

  Color _luxToColor(double lux, double maxLux) {
    if (maxLux <= 0) return Colors.blue;
    final double normalized = (lux / maxLux).clamp(0.0, 1.0);
    return HSVColor.fromAHSV(1.0, (1.0 - normalized) * 240.0, 1.0, 1.0).toColor();
  }

  @override
  bool shouldRepaint(covariant HeatmapPainter oldDelegate) => 
      oldDelegate.result != result || oldDelegate.maxLux != maxLux;
}
