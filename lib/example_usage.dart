import 'package:flutter/material.dart';
import 'services/api_service_updated.dart';
import 'services/hive_service.dart';
import 'models/data_models.dart';

/// Example showing complete data flow:
/// API → Models → Hive Storage → UI Display
class ExampleUsage extends StatefulWidget {
  const ExampleUsage({super.key});

  @override
  State<ExampleUsage> createState() => _ExampleUsageState();
}

class _ExampleUsageState extends State<ExampleUsage> {
  final ApiService _apiService = ApiService();
  DashboardModel? _dashboard;
  List<RegionModel>? _regions;
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AgriPulse Data Flow Example')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: _loading ? null : _fetchAndStoreData,
              child: _loading 
                ? const CircularProgressIndicator()
                : const Text('Fetch Data from API'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadFromHive,
              child: const Text('Load from Hive Cache'),
            ),
            const SizedBox(height: 20),
            if (_dashboard != null) ...[
              Text('📊 Dashboard Data:', style: Theme.of(context).textTheme.titleLarge),
              Text('Price: ${_dashboard!.price.bifPerKg} BIF/kg'),
              Text('Change: ${_dashboard!.price.change24h}%'),
              Text('AI Prediction: ${_dashboard!.aiPrediction.prediction}'),
              Text('Confidence: ${_dashboard!.aiPrediction.confidence}'),
              const SizedBox(height: 16),
            ],
            if (_regions != null) ...[
              Text('🗺️ Regions Data:', style: Theme.of(context).textTheme.titleLarge),
              ..._regions!.map((region) => Text(
                '${region.name}: ${region.priceBif} BIF (${region.alertLevel})'
              )),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _fetchAndStoreData() async {
    setState(() => _loading = true);
    
    try {
      // 1. Fetch from API (automatically stores in Hive)
      final dashboard = await _apiService.getDashboardData();
      final regions = await _apiService.getRegions();
      
      setState(() {
        _dashboard = dashboard;
        _regions = regions;
      });
      
      print('✅ Data fetched and stored in Hive');
    } catch (e) {
      print('❌ Error: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  void _loadFromHive() {
    // 2. Load from Hive cache
    final cachedDashboard = HiveService.getLatestDashboard();
    final cachedRegions = HiveService.getLatestRegions();
    
    setState(() {
      _dashboard = cachedDashboard;
      _regions = cachedRegions;
    });
    
    print('✅ Data loaded from Hive cache');
  }
}
