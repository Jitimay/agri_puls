import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shimmer/shimmer.dart';
import '../bloc/dashboard/dashboard_bloc.dart';
import '../data/models.dart';
import '../theme/app_theme.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AgriPulse Dashboard')),
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<DashboardBloc>().add(RefreshDashboard());
        },
        child: BlocBuilder<DashboardBloc, DashboardState>(
          builder: (context, state) {
            if (state is DashboardLoading) {
              return const _LoadingView();
            } else if (state is DashboardLoaded) {
              return _LoadedView(state: state);
            }
            return const Center(child: Text('Pull to refresh'));
          },
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

class _LoadedView extends StatelessWidget {
  final DashboardLoaded state;

  const _LoadedView({required this.state});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _PriceCard(price: state.price),
          const SizedBox(height: 16),
          _WeatherSummary(weather: state.weather),
          const SizedBox(height: 16),
          _AlertCounter(alerts: state.alerts),
          const SizedBox(height: 16),
          _PriceChart(history: state.price.history),
        ],
      ),
    );
  }
}

class _PriceCard extends StatelessWidget {
  final CoffeePrice price;

  const _PriceCard({required this.price});

  @override
  Widget build(BuildContext context) {
    final isPositive = price.change24h >= 0;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text('Coffee Price (USD/lb)', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text(
              '\$${price.current.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                  color: isPositive ? AppTheme.coffeeGreen : AppTheme.alertRed,
                  size: 16,
                ),
                Text(
                  '${isPositive ? '+' : ''}\$${price.change24h.toStringAsFixed(3)}',
                  style: TextStyle(
                    color: isPositive ? AppTheme.coffeeGreen : AppTheme.alertRed,
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
}

class _WeatherSummary extends StatelessWidget {
  final List<Weather> weather;

  const _WeatherSummary({required this.weather});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Weather Summary', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ...weather.map((w) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(w.region, style: const TextStyle(fontWeight: FontWeight.w500)),
                  Text('${w.temperature.toStringAsFixed(1)}°C - ${w.condition}'),
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
  final List<Alert> alerts;

  const _AlertCounter({required this.alerts});

  @override
  Widget build(BuildContext context) {
    final critical = alerts.where((a) => a.priority == AlertPriority.critical).length;
    final warning = alerts.where((a) => a.priority == AlertPriority.warning).length;
    final info = alerts.where((a) => a.priority == AlertPriority.info).length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _AlertBadge(count: critical, color: AppTheme.alertRed, label: 'Critical'),
            _AlertBadge(count: warning, color: AppTheme.alertYellow, label: 'Warning'),
            _AlertBadge(count: info, color: AppTheme.coffeeGreen, label: 'Info'),
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

  const _AlertBadge({required this.count, required this.color, required this.label});

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
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

class _PriceChart extends StatelessWidget {
  final List<PricePoint> history;

  const _PriceChart({required this.history});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('30-Day Price Trend', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: const FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: history.asMap().entries.map((e) => 
                        FlSpot(e.key.toDouble(), e.value.price)
                      ).toList(),
                      isCurved: true,
                      color: AppTheme.coffeeBrown,
                      barWidth: 3,
                      dotData: const FlDotData(show: false),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
