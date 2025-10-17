import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  final ApiService _apiService = ApiService();
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Bikomeye', 'Reba', 'Byiza'];

  DashboardData? _dashboardData;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Try to fetch both dashboard data and news
      final futures = await Future.wait([
        _apiService.getDashboardData(),
        _apiService.getNews().catchError(
            (e) => <NewsItem>[]), // Don't fail if news endpoint doesn't exist
      ]);

      final dashboardData = futures[0] as DashboardData;
      final news = futures[1] as List<NewsItem>;

      // Convert news items to AlertData format for display
      final newsAlerts = news
          .map((newsItem) => AlertData(
                id: newsItem.id,
                title: newsItem.title,
                message: newsItem.content,
                type: newsItem.level,
                timestamp: newsItem.timestamp,
              ))
          .toList();

      // Combine dashboard alerts with news
      final combinedAlerts = [...dashboardData.alerts, ...newsAlerts];

      // Create updated dashboard data with combined alerts
      final updatedDashboardData = DashboardData(
        price: dashboardData.price,
        weather: dashboardData.weather,
        alerts: combinedAlerts,
        recentEvents: dashboardData.recentEvents,
      );

      setState(() {
        _dashboardData = updatedDashboardData;
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
      appBar: AppBar(
        title: const Text('Amakuru n\'amabwiriza (News & Alerts)'),
        backgroundColor: AppTheme.coffeeBrown,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: Column(
        children: [
          _FilterChips(
            filters: _filters,
            selected: _selectedFilter,
            onSelected: (filter) => setState(() => _selectedFilter = filter),
          ),
          Expanded(
            child: _buildBody(),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.coffeeBrown),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'Ikibazo mu gufata amakuru',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadData,
                child: const Text('Ongera ugerageze'),
              ),
            ],
          ),
        ),
      );
    }

    if (_dashboardData != null) {
      final filteredAlerts = _filterAlerts(_dashboardData!.alerts);
      if (filteredAlerts.isEmpty) {
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.notifications_none, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'Nta makuru mashya',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
              Text(
                'Kuraguza kugira ngo urebe amakuru mashya',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: _loadData,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: filteredAlerts.length,
          itemBuilder: (context, index) =>
              _AlertCard(alert: filteredAlerts[index]),
        ),
      );
    }

    return const Center(
      child: Text('Kuraguza kugira ngo urebe amakuru'),
    );
  }

  List<AlertData> _filterAlerts(List<AlertData> alerts) {
    switch (_selectedFilter) {
      case 'Bikomeye': // Critical/Red
        return alerts.where((a) => a.type == 'critical').toList();
      case 'Reba': // Warning/Yellow
        return alerts.where((a) => a.type == 'warning').toList();
      case 'Byiza': // Info/Green
        return alerts.where((a) => a.type == 'ai_prediction' || a.type == 'info').toList();
      default:
        return alerts;
    }
  }
}

class _FilterChips extends StatelessWidget {
  final List<String> filters;
  final String selected;
  final Function(String) onSelected;

  const _FilterChips({
    required this.filters,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Wrap(
        spacing: 8,
        children: filters
            .map((filter) => FilterChip(
                  label: Text(filter),
                  selected: filter == selected,
                  onSelected: (_) => onSelected(filter),
                ))
            .toList(),
      ),
    );
  }
}

class _AlertCard extends StatelessWidget {
  final AlertData alert;

  const _AlertCard({required this.alert});

  Color _getAlertColor(String type) {
    switch (type) {
      case 'critical':
        return AppTheme.alertRed;
      case 'warning':
        return AppTheme.alertYellow;
      case 'ai_prediction':
      case 'info':
        return AppTheme.coffeeGreen;
      default:
        return Colors.grey;
    }
  }

  String _getAlertText(String type) {
    switch (type) {
      case 'critical':
        return 'BIKOMEYE';
      case 'warning':
        return 'REBA';
      case 'ai_prediction':
      case 'info':
        return 'BYIZA';
      default:
        return 'NTIBIZWI';
    }
  }

  IconData _getAlertIcon(String type) {
    switch (type) {
      case 'critical':
        return Icons.warning;
      case 'warning':
        return Icons.info;
      case 'ai_prediction':
      case 'info':
        return Icons.check_circle;
      default:
        return Icons.notifications;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getAlertIcon(alert.type),
                  color: _getAlertColor(alert.type),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getAlertColor(alert.type),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getAlertText(alert.type),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  _formatTime(alert.timestamp),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              alert.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              alert.message,
              style: const TextStyle(
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final diff = now.difference(timestamp);

    if (diff.inMinutes < 1) {
      return 'Ubu';
    } else if (diff.inHours < 1) {
      return '${diff.inMinutes} min';
    } else if (diff.inDays < 1) {
      return '${diff.inHours} h';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} d';
    } else {
      return '${(diff.inDays / 7).floor()} w';
    }
  }
}
