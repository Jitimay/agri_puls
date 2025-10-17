import 'package:hive_flutter/hive_flutter.dart';
import '../models/data_models.dart';

class HiveService {
  static const String _dashboardBox = 'dashboard';
  static const String _regionsBox = 'regions';
  static const String _pricesBox = 'prices';

  static Future<void> init() async {
    await Hive.initFlutter();
    
    // Register adapters
    Hive.registerAdapter(PriceModelAdapter());
    Hive.registerAdapter(AIPredictionModelAdapter());
    Hive.registerAdapter(RegionModelAdapter());
    Hive.registerAdapter(DashboardModelAdapter());
    
    // Open boxes
    await Hive.openBox<DashboardModel>(_dashboardBox);
    await Hive.openBox<List<RegionModel>>(_regionsBox);
    await Hive.openBox<PriceModel>(_pricesBox);
  }

  // Dashboard operations
  static Future<void> saveDashboard(DashboardModel dashboard) async {
    final box = Hive.box<DashboardModel>(_dashboardBox);
    await box.put('latest', dashboard);
  }

  static DashboardModel? getLatestDashboard() {
    final box = Hive.box<DashboardModel>(_dashboardBox);
    return box.get('latest');
  }

  // Regions operations
  static Future<void> saveRegions(List<RegionModel> regions) async {
    final box = Hive.box<List<RegionModel>>(_regionsBox);
    await box.put('latest', regions);
  }

  static List<RegionModel>? getLatestRegions() {
    final box = Hive.box<List<RegionModel>>(_regionsBox);
    return box.get('latest');
  }

  // Price history
  static Future<void> savePriceHistory(PriceModel price) async {
    final box = Hive.box<PriceModel>(_pricesBox);
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    await box.put(timestamp, price);
    
    // Keep only last 100 entries
    if (box.length > 100) {
      final oldestKey = box.keys.first;
      await box.delete(oldestKey);
    }
  }

  static List<PriceModel> getPriceHistory() {
    final box = Hive.box<PriceModel>(_pricesBox);
    return box.values.toList();
  }

  static Future<void> clearAll() async {
    await Hive.box<DashboardModel>(_dashboardBox).clear();
    await Hive.box<List<RegionModel>>(_regionsBox).clear();
    await Hive.box<PriceModel>(_pricesBox).clear();
  }
}
