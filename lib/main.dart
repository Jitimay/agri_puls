import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/dashboard/dashboard_bloc.dart';
import 'screens/dashboard_screen_updated.dart';
import 'screens/visualization_3d_screen.dart';
import 'screens/voice_search_screen.dart';
import 'screens/alerts_screen.dart';
import 'screens/debug_screen.dart';
import 'services/hive_service.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive database
  await HiveService.init();
  
  runApp(const AgriPulseApp());
}

class AgriPulseApp extends StatelessWidget {
  const AgriPulseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AgriPulse',
      theme: AppTheme.theme,
      home: BlocProvider(
        create: (context) => DashboardBloc()..add(LoadDashboard()),
        child: const MainScreen(),
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const Visualization3DScreen(),
    const VoiceSearchScreen(),
    const AlertsScreen(),
    const DebugScreen(), // Temporary for testing
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        selectedItemColor: AppTheme.coffeeBrown,
        unselectedItemColor: Colors.grey,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.view_in_ar),
            label: '3D Echo',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.mic),
            label: 'Baza',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Alerts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bug_report),
            label: 'Debug',
          ),
        ],
      ),
    );
  }
}
