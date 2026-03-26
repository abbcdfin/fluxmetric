import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'viewmodels/ies_visualizer_viewmodel.dart';
import 'viewmodels/simulation_viewmodel.dart';
import 'viewmodels/calculation_viewmodel.dart';
import 'views/ies_3d_view.dart';
import 'views/simulation_3d_view.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => IesVisualizerViewModel()),
        ChangeNotifierProvider(create: (_) => SimulationViewModel()),
        ChangeNotifierProvider(create: (_) => CalculationViewModel()),
      ],
      child: const FluxMetricApp(),
    ),
  );
}

class FluxMetricApp extends StatelessWidget {
  const FluxMetricApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FluxMetric',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MainNavigationFrame(),
    );
  }
}

class MainNavigationFrame extends StatefulWidget {
  const MainNavigationFrame({super.key});

  @override
  State<MainNavigationFrame> createState() => _MainNavigationFrameState();
}

class _MainNavigationFrameState extends State<MainNavigationFrame> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const Ies3DView(),
    const Simulation3DView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            labelType: NavigationRailLabelType.all,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.library_books),
                label: Text('IES Library'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.architecture),
                label: Text('Workspace'),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(child: _pages[_selectedIndex]),
        ],
      ),
    );
  }
}
