import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

/// Debug screen to test API responses and see what data is being received
class DebugScreen extends StatefulWidget {
  const DebugScreen({super.key});

  @override
  State<DebugScreen> createState() => _DebugScreenState();
}

class _DebugScreenState extends State<DebugScreen> {
  final ApiService _apiService = ApiService();
  String _debugInfo = 'Tap buttons to test API endpoints...';
  bool _isLoading = false;

  Future<void> _testDashboard() async {
    setState(() {
      _isLoading = true;
      _debugInfo = 'Testing dashboard endpoint...';
    });

    try {
      // Test the sophisticated backend
      final data = await _apiService.getDashboardData();
      setState(() {
        _debugInfo = '''
🚀 AGRIPULSE BACKEND TEST SUCCESS!

💰 DYNAMIC COFFEE PRICES:
- Current Price: ${data.price.bifPerKg} BIF/kg
- 24h Change: ${data.price.change24h >= 0 ? '+' : ''}${data.price.change24h} BIF (${data.price.changePercent24h.toStringAsFixed(2)}%)
- 7d Change: ${data.price.change7d >= 0 ? '+' : ''}${data.price.change7d} BIF (${data.price.changePercent7d.toStringAsFixed(2)}%)
- USD Price: \$${data.price.usdPerLb}/lb
- Market Trend: ${data.price.marketTrend.toUpperCase()}
- Last Updated: ${data.price.lastUpdated}

🌤️ REAL-TIME WEATHER (${data.weather.length} regions):
${data.weather.entries.map((e) => '- ${e.key}: ${e.value.temp}°C, ${e.value.conditions}, ${e.value.humidity}% humidity').join('\n')}

🤖 AI ANALYSIS & ALERTS (${data.alerts.length} items):
${data.alerts.map((alert) => '- [${alert.type.toUpperCase()}] ${alert.title}\n  ${alert.message.length > 100 ? alert.message.substring(0, 100) + '...' : alert.message}').join('\n\n')}

📊 MARKET EVENTS (${data.recentEvents.length} items):
${data.recentEvents.map((event) => '- ${event.toString()}').join('\n')}

${data.aiAnalysis != null ? '\n🧠 AI MARKET ANALYSIS:\n${data.aiAnalysis!.length > 200 ? data.aiAnalysis!.substring(0, 200) + '...' : data.aiAnalysis!}' : ''}
        ''';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _debugInfo = '''
❌ DASHBOARD ERROR:
$e

This might indicate:
- Backend not running on ${_apiService.currentBaseUrl}
- Network connectivity issues
- Response format mismatch
        ''';
        _isLoading = false;
      });
    }
  }

  Future<void> _testRegions() async {
    setState(() {
      _isLoading = true;
      _debugInfo = 'Testing regions endpoint...';
    });

    try {
      final regions = await _apiService.getRegions();
      setState(() {
        _debugInfo = '''
REGIONS DATA SUCCESS (${regions.length} regions):

${regions.map((region) => '''
${region.name}:
- ID: ${region.id}
- Coordinates: ${region.lat}, ${region.lng}
- Farmers: ${region.farmers}
- Alert Level: ${region.alertLevel}
- Price: ${region.priceBif} BIF/kg
- Weather: ${region.weather.temp}°C, ${region.weather.conditions}
''').join('\n')}
        ''';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _debugInfo = 'REGIONS ERROR:\n$e';
        _isLoading = false;
      });
    }
  }

  Future<void> _testNews() async {
    setState(() {
      _isLoading = true;
      _debugInfo = 'Testing news endpoint...';
    });

    try {
      final news = await _apiService.getNews();
      setState(() {
        _debugInfo = '''
NEWS DATA SUCCESS (${news.length} items):

${news.map((item) => '''
[${item.level.toUpperCase()}] ${item.title}
Category: ${item.category}
Content: ${item.content.length > 100 ? '${item.content.substring(0, 100)}...' : item.content}
Time: ${item.timestamp}
---
''').join('\n')}
        ''';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _debugInfo =
            'NEWS ERROR:\n$e\n\nThis is normal if /news endpoint doesn\'t exist.';
        _isLoading = false;
      });
    }
  }

  Future<void> _testAI() async {
    setState(() {
      _isLoading = true;
      _debugInfo = 'Testing AI endpoint...';
    });

    try {
      final response = await _apiService.askAI('Igiciro cy\'ikawa ni angahe?',
          language: 'rn');
      setState(() {
        _debugInfo = '''
AI RESPONSE SUCCESS:

Question: "Igiciro cy'ikawa ni angahe?" (Kirundi)
Answer: $response
        ''';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _debugInfo = 'AI ERROR:\n$e';
        _isLoading = false;
      });
    }
  }

  Future<void> _testRawResponses() async {
    setState(() {
      _isLoading = true;
      _debugInfo = 'Testing all raw endpoints...';
    });

    try {
      // Test endpoints one by one to isolate issues
      setState(() {
        _debugInfo = 'Testing dashboard endpoint...';
      });
      final dashboardResponse = await _apiService.getRawResponse('/dashboard');

      setState(() {
        _debugInfo = 'Dashboard OK. Testing regions endpoint...';
      });
      final regionsResponse = await _apiService.getRawResponse('/regions');

      setState(() {
        _debugInfo = 'Regions OK. Testing news endpoint...';
      });
      final newsResponse = await _apiService.getRawResponse('/news');

      setState(() {
        _debugInfo = '''
RAW API RESPONSES:

=== DASHBOARD ===
${dashboardResponse}

=== REGIONS ===
${regionsResponse}

=== NEWS ===
${newsResponse}
        ''';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _debugInfo = 'RAW RESPONSES ERROR:\n$e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('API Debug'),
        backgroundColor: AppTheme.coffeeBrown,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Configuration info
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Current API Configuration:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Base URL: ${_apiService.currentBaseUrl}',
                    style:
                        const TextStyle(fontFamily: 'monospace', fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Connection Troubleshooting:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                  const Text(
                    '• Android Emulator: Use 10.0.2.2:5001\n'
                    '• iOS Simulator: Use localhost:5001\n'
                    '• Physical Device: Use your computer\'s IP (e.g., 192.168.1.100:5001)',
                    style: TextStyle(fontSize: 11),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Test your backend API endpoints:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton(
                  onPressed: _isLoading ? null : _testDashboard,
                  child: const Text('Test Dashboard'),
                ),
                ElevatedButton(
                  onPressed: _isLoading ? null : _testRegions,
                  child: const Text('Test Regions'),
                ),
                ElevatedButton(
                  onPressed: _isLoading ? null : _testNews,
                  child: const Text('Test News'),
                ),
                ElevatedButton(
                  onPressed: _isLoading ? null : _testAI,
                  child: const Text('Test AI'),
                ),
                ElevatedButton(
                  onPressed: _isLoading ? null : _testRawResponses,
                  child: const Text('Raw Responses'),
                ),
  
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: SingleChildScrollView(
                  child: _isLoading
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(
                                  color: AppTheme.coffeeBrown),
                              SizedBox(height: 16),
                              Text('Loading...'),
                            ],
                          ),
                        )
                      : Text(
                          _debugInfo,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
