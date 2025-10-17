import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../services/api_service_updated.dart';
import '../services/hive_service.dart';
import '../models/data_models.dart';
import '../theme/app_theme.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ApiService _apiService = ApiService();
  DashboardModel? _dashboardData;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCachedData();
    _loadDashboardData();
  }

  void _loadCachedData() {
    final cached = HiveService.getLatestDashboard();
    if (cached != null) {
      setState(() {
        _dashboardData = cached;
      });
    }
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await _apiService.getDashboardData();
      setState(() {
        _dashboardData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('AgriPulse Dashboard'),
        backgroundColor: AppTheme.coffeeBrown,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDashboardData,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadDashboardData,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_error != null && _dashboardData == null) {
      return _buildErrorState();
    }

    if (_dashboardData == null) {
      return _buildLoadingState();
    }

    return _buildDashboardContent();
  }

  Widget _buildLoadingState() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildShimmerCard(height: 120),
        const SizedBox(height: 16),
        _buildShimmerCard(height: 100),
        const SizedBox(height: 16),
        _buildShimmerCard(height: 150),
      ],
    );
  }

  Widget _buildShimmerCard({required double height}) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
          const SizedBox(height: 16),
          Text(
            'Ikibazo mu gufata amakuru',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            _error ?? 'Unknown error',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadDashboardData,
            child: const Text('Ongera ugerageze'),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardContent() {
    final dashboard = _dashboardData!;
    
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildPriceCard(dashboard.price),
        const SizedBox(height: 16),
        _buildAIPredictionCard(dashboard.aiPrediction),
        const SizedBox(height: 16),
        _buildWeatherCard(dashboard.weather),
        const SizedBox(height: 16),
        _buildAlertsCard(dashboard.alerts),
        if (_isLoading) ...[
          const SizedBox(height: 16),
          const Center(child: CircularProgressIndicator()),
        ],
      ],
    );
  }

  Widget _buildPriceCard(PriceModel price) {
    final isPositive = price.change24h >= 0;
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.coffee, color: AppTheme.coffeeBrown, size: 24),
                const SizedBox(width: 8),
                Text(
                  'Igiciro cy\'ikawa',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${price.bifPerKg.toInt()} BIF/kg',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.coffeeBrown,
                      ),
                    ),
                    Text(
                      '\$${price.usdPerLb.toStringAsFixed(2)}/lb',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isPositive ? Colors.green[100] : Colors.red[100],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isPositive ? Icons.trending_up : Icons.trending_down,
                        color: isPositive ? Colors.green[700] : Colors.red[700],
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${price.change24h.toStringAsFixed(1)}%',
                        style: TextStyle(
                          color: isPositive ? Colors.green[700] : Colors.red[700],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAIPredictionCard(AIPredictionModel prediction) {
    Color confidenceColor;
    switch (prediction.confidence) {
      case 'high':
        confidenceColor = Colors.green;
        break;
      case 'low':
        confidenceColor = Colors.red;
        break;
      default:
        confidenceColor = Colors.orange;
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.psychology, color: Colors.blue[700], size: 24),
                const SizedBox(width: 8),
                Text(
                  'AI Ubushakashatsi',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: confidenceColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    prediction.confidence.toUpperCase(),
                    style: TextStyle(
                      color: confidenceColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              prediction.prediction,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.recommend, color: AppTheme.coffeeBrown, size: 16),
                const SizedBox(width: 4),
                Text(
                  'Icyifuzo: ${prediction.recommendation}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherCard(Map<String, dynamic> weather) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.wb_sunny, color: Colors.orange[700], size: 24),
                const SizedBox(width: 8),
                Text(
                  'Ikirere - Kayanza',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${weather['temp']}°C',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  weather['conditions'] ?? 'Unknown',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertsCard(List<Map<String, dynamic>> alerts) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.notifications, color: Colors.red[700], size: 24),
                const SizedBox(width: 8),
                Text(
                  'Amakuru y\'ibanze',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (alerts.isEmpty)
              Text(
                'Nta makuru y\'ibanze ubu',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              )
            else
              ...alerts.take(3).map((alert) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.only(top: 6, right: 8),
                      decoration: BoxDecoration(
                        color: _getAlertColor(alert['type']),
                        shape: BoxShape.circle,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        alert['title'] ?? 'No title',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              )),
          ],
        ),
      ),
    );
  }

  Color _getAlertColor(String? type) {
    switch (type) {
      case 'critical':
        return Colors.red;
      case 'warning':
        return Colors.orange;
      case 'ai_prediction':
        return Colors.blue;
      default:
        return Colors.green;
    }
  }
}
