import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ApiService _apiService = ApiService();
  DashboardData? _dashboardData;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      print('Dashboard: Starting to load data...');
      final data = await _apiService.getDashboardData();
      print('Dashboard: Data loaded successfully - Price: ${data.price.bifPerKg} BIF');
      setState(() {
        _dashboardData = data;
        _isLoading = false;
      });
    } catch (e) {
      print('Dashboard: Error loading data - $e');
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AgriPulse Dashboard'),
        backgroundColor: AppTheme.coffeeBrown,
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: _loadDashboardData,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const _LoadingView();
    } else if (_error != null) {
      return _ErrorView(
        error: _error!,
        onRetry: _loadDashboardData,
      );
    } else if (_dashboardData != null) {
      return _LoadedView(data: _dashboardData!);
    }
    return const Center(
      child: Text('Kuraguza amakuru... (Pull to refresh)'),
    );
  }
}

class _LoadedView extends StatelessWidget {
  final DashboardData data;

  const _LoadedView({required this.data});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _PriceCard(price: data.price),
          const SizedBox(height: 16),
          _WeatherSummary(weather: data.weather),
          const SizedBox(height: 16),
          _AlertCounter(alerts: data.alerts),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _ErrorView({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            const Text(
              'Ikibazo mu gufata amakuru',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Ongera ugerageze'),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PriceCard extends StatelessWidget {
  final CoffeePriceData price;

  const _PriceCard({required this.price});

  @override
  Widget build(BuildContext context) {
    final isPositive24h = price.isPositive24h;
    final isPositive7d = price.isPositive7d;
    
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              'Igiciro cy\'ikawa (BIF/kg)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Text(
              '${price.bifPerKg.toStringAsFixed(0)} BIF',
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppTheme.coffeeBrown,
              ),
            ),
            const SizedBox(height: 8),
            // Market trend indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: _getTrendColor(price.marketTrend).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _getTrendColor(price.marketTrend)),
              ),
              child: Text(
                _getTrendText(price.marketTrend),
                style: TextStyle(
                  color: _getTrendColor(price.marketTrend),
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 12),
            // 24h change
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isPositive24h ? Icons.trending_up : Icons.trending_down,
                  color: isPositive24h ? AppTheme.coffeeGreen : AppTheme.alertRed,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  '${isPositive24h ? '+' : ''}${price.changePercent24h.toStringAsFixed(1)}% (24h)',
                  style: TextStyle(
                    color: isPositive24h ? AppTheme.coffeeGreen : AppTheme.alertRed,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            // 7d change
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isPositive7d ? Icons.trending_up : Icons.trending_down,
                  color: isPositive7d ? AppTheme.coffeeGreen : AppTheme.alertRed,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  '${isPositive7d ? '+' : ''}${price.changePercent7d.toStringAsFixed(1)}% (7d)',
                  style: TextStyle(
                    color: isPositive7d ? AppTheme.coffeeGreen : AppTheme.alertRed,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'USD: \$${price.usdPerLb.toStringAsFixed(2)}/lb',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getTrendColor(String trend) {
    switch (trend.toLowerCase()) {
      case 'rising':
        return AppTheme.coffeeGreen;
      case 'falling':
        return AppTheme.alertRed;
      case 'stable':
        return AppTheme.alertYellow;
      default:
        return Colors.grey;
    }
  }

  String _getTrendText(String trend) {
    switch (trend.toLowerCase()) {
      case 'rising':
        return 'KUZAMUKA';
      case 'falling':
        return 'KUGABANUKA';
      case 'stable':
        return 'GUHAGAZE';
      default:
        return 'NTIBIZWI';
    }
  }
}

class _WeatherSummary extends StatelessWidget {
  final Map<String, WeatherData> weather;

  const _WeatherSummary({required this.weather});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ikirere (Weather)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...weather.entries.map((entry) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        entry.key,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${entry.value.temp.toStringAsFixed(1)}°C - ${entry.value.conditions}',
                          ),
                          Text(
                            'Ubushuhe: ${entry.value.humidity}%',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

class _AlertCounter extends StatelessWidget {
  final List<AlertData> alerts;

  const _AlertCounter({required this.alerts});

  @override
  Widget build(BuildContext context) {
    final red = alerts.where((a) => a.level == 'red').length;
    final yellow = alerts.where((a) => a.level == 'yellow').length;
    final green = alerts.where((a) => a.level == 'green').length;

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Amakuru y\'ubwoba (Alerts)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _AlertBadge(
                    count: red, color: AppTheme.alertRed, label: 'Bikomeye'),
                _AlertBadge(
                    count: yellow, color: AppTheme.alertYellow, label: 'Reba'),
                _AlertBadge(
                    count: green, color: AppTheme.coffeeGreen, label: 'Byiza'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AlertBadge extends StatelessWidget {
  final int count;
  final Color color;
  final String label;

  const _AlertBadge(
      {required this.count, required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              count.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
