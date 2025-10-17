import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;

/// API Service for AgriPulse backend integration
/// Handles all communication with the backend API
class ApiService {
  // Configuration options for different environments:
  static const String _physicalDeviceUrl =
      'http://192.168.138.127:5001/api'; // Your actual IP

  // Current configuration - change this based on your setup
  static const String _baseUrl = _physicalDeviceUrl; // Using your actual IP
  static const Duration _timeout = Duration(seconds: 30); // Increased timeout

  /// Singleton instance
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  /// Get current base URL for debugging
  String get currentBaseUrl => _baseUrl;

  /// HTTP client with timeout configuration
  final http.Client _client = http.Client();

  /// Generic GET request handler with error handling
  Future<Map<String, dynamic>> _get(String endpoint) async {
    try {
      developer.log('API Request: GET $_baseUrl$endpoint', name: 'ApiService');
      final startTime = DateTime.now();

      final response =
          await _client.get(Uri.parse('$_baseUrl$endpoint')).timeout(_timeout);

      final duration = DateTime.now().difference(startTime);
      developer.log(
          'API Response: ${response.statusCode} (${duration.inMilliseconds}ms)',
          name: 'ApiService');
      developer.log('Response body length: ${response.body.length} chars',
          name: 'ApiService');

      if (response.statusCode == 200) {
        try {
          final data = json.decode(response.body) as Map<String, dynamic>;
          developer.log('JSON parsed successfully. Keys: ${data.keys.toList()}',
              name: 'ApiService');

          // Handle different response formats
          if (data['success'] == true) {
            // Standard format: {"success": true, "data": {...}}
            return data;
          } else if (data.containsKey('data') && data['success'] != false) {
            // Format with data but no success field: {"data": {...}}
            return {'success': true, 'data': data['data']};
          } else if (!data.containsKey('success')) {
            // Direct data format: {...} (no wrapper)
            return {'success': true, 'data': data};
          } else {
            developer.log('API returned success: false. Data: $data',
                name: 'ApiService');
            throw ApiException('API returned success: false');
          }
        } catch (jsonError) {
          developer.log('JSON parsing error: $jsonError', name: 'ApiService');
          developer.log('Raw response body: ${response.body}',
              name: 'ApiService');
          throw ApiException('Invalid JSON response: $jsonError');
        }
      } else {
        developer.log('HTTP error response body: ${response.body}',
            name: 'ApiService');
        throw ApiException(
            'HTTP ${response.statusCode}: ${response.reasonPhrase}');
      }
    } catch (e) {
      developer.log('API Error: $e', name: 'ApiService');
      if (e is ApiException) rethrow;
      throw ApiException('Network error: $e');
    }
  }

  /// Fetch dashboard data including coffee prices, weather, and alerts
  /// Returns: {price: {bif_per_kg: 4800, change_24h: 2.3}, weather: {...}, alerts: [...]}
  Future<DashboardData> getDashboardData() async {
    try {
      final response = await _get('/dashboard');
      return DashboardData.fromJson(response['data']);
    } catch (e) {
      developer.log('Failed to fetch dashboard data: $e', name: 'ApiService');

      // Return mock data as fallback
      return _getMockDashboardData();
    }
  }

  /// Fetch all coffee regions with coordinates and current data
  /// Returns: List of regions with coordinates, farmers count, alert levels, etc.
  Future<List<RegionData>> getRegions() async {
    try {
      final response = await _get('/regions');
      final regionsJson = response['regions'] as List;
      final regions =
          regionsJson.map((json) => RegionData.fromJson(json)).toList();

      // Log the actual data received
      developer.log('Received ${regions.length} regions from API',
          name: 'ApiService');
      for (final region in regions) {
        developer.log('Region: ${region.name} at ${region.lat},${region.lng}',
            name: 'ApiService');
      }

      return regions;
    } catch (e) {
      developer.log('Failed to fetch regions: $e', name: 'ApiService');

      // Return mock data as fallback
      return _getMockRegions();
    }
  }

  /// Mock dashboard data for fallback
  DashboardData _getMockDashboardData() {
    return DashboardData(
      price: CoffeePriceData(
        bifPerKg: 4800,
        change24h: 120,
        change7d: -50,
        usdPerLb: 1.85,
        marketTrend: 'bullish',
        lastUpdated: DateTime.now(),
      ),
      weather: {
        'Kayanza':
            WeatherData(temp: 24, conditions: 'Partly Cloudy', humidity: 75),
        'Ngozi': WeatherData(temp: 22, conditions: 'Cloudy', humidity: 80),
        'Kirundo': WeatherData(temp: 26, conditions: 'Sunny', humidity: 65),
      },
      alerts: [
        AlertData(
          id: '1',
          title: 'Igiciro cy\'ikawa cyiyongereye',
          message:
              'Igiciro cy\'ikawa cyiyongereye ku ijana 5% mu minsi 3 ishize. Ni igihe cyiza cyo kugurisha.',
          type: 'ai_prediction',
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        ),
        AlertData(
          id: '2',
          title: 'Imvura ikomeye iteganywa',
          message:
              'Imvura ikomeye iteganywa mu turere twa Kayanza na Ngozi. Tegura ubusanzwe.',
          type: 'warning',
          timestamp: DateTime.now().subtract(const Duration(hours: 6)),
        ),
        AlertData(
          id: '3',
          title: 'Indwara y\'ikawa yagaragaye',
          message:
              'Indwara y\'ikawa (coffee rust) yagaragaye mu turere twa Kirundo. Saba ubufasha bw\'ubuhanga.',
          type: 'critical',
          timestamp: DateTime.now().subtract(const Duration(days: 1)),
        ),
      ],
      recentEvents: [
        {
          'event': 'price_update',
          'timestamp': DateTime.now().toIso8601String()
        },
        {
          'event': 'weather_update',
          'timestamp': DateTime.now().toIso8601String()
        },
      ],
    );
  }

  /// Mock regions data for fallback
  List<RegionData> _getMockRegions() {
    return [
      RegionData(
        id: 1,
        name: 'Kayanza',
        lat: -2.9217,
        lng: 29.6297,
        farmers: 120000,
        alertLevel: 'green',
        priceBif: 4800,
        weather:
            WeatherData(temp: 24, conditions: 'Partly Cloudy', humidity: 67),
      ),
      RegionData(
        id: 2,
        name: 'Ngozi',
        lat: -2.9083,
        lng: 29.8306,
        farmers: 95000,
        alertLevel: 'yellow',
        priceBif: 4750,
        weather: WeatherData(temp: 22, conditions: 'Cloudy', humidity: 72),
      ),
      RegionData(
        id: 3,
        name: 'Kirundo',
        lat: -2.5833,
        lng: 30.0833,
        farmers: 80000,
        alertLevel: 'red',
        priceBif: 4600,
        weather: WeatherData(temp: 26, conditions: 'Sunny', humidity: 45),
      ),
      RegionData(
        id: 4,
        name: 'Muyinga',
        lat: -2.8444,
        lng: 30.3417,
        farmers: 75000,
        alertLevel: 'green',
        priceBif: 4850,
        weather: WeatherData(temp: 25, conditions: 'Light Rain', humidity: 85),
      ),
      RegionData(
        id: 5,
        name: 'Gitega',
        lat: -3.4264,
        lng: 29.9306,
        farmers: 110000,
        alertLevel: 'yellow',
        priceBif: 4780,
        weather: WeatherData(temp: 23, conditions: 'Overcast', humidity: 78),
      ),
    ];
  }

  /// Ask AI a question in specified language
  /// [question] - The question to ask
  /// [language] - Language code ('rn' for Kirundi, 'en' for English, 'fr' for French)
  /// Returns: AI response text
  Future<String> askAI(String question, {String language = 'rn'}) async {
    try {
      final encodedQuestion = Uri.encodeComponent(question);
      final response = await _get('/ai/ask?q=$encodedQuestion&lang=$language');
      return response['answer'] as String;
    } catch (e) {
      developer.log('Failed to ask AI: $e', name: 'ApiService');
      rethrow;
    }
  }

  /// Fetch news/alerts data
  /// Returns: List of news articles and alerts
  Future<List<NewsItem>> getNews() async {
    try {
      final response = await _get('/news');
      final newsJson = response['news'] as List;
      return newsJson.map((json) => NewsItem.fromJson(json)).toList();
    } catch (e) {
      developer.log('Failed to fetch news: $e', name: 'ApiService');
      // Return empty list if news endpoint doesn't exist
      return [];
    }
  }

  /// Get raw response for debugging
  Future<String> getRawResponse(String endpoint) async {
    try {
      developer.log('Raw request: GET $_baseUrl$endpoint', name: 'ApiService');
      final startTime = DateTime.now();

      final response =
          await _client.get(Uri.parse('$_baseUrl$endpoint')).timeout(_timeout);

      final duration = DateTime.now().difference(startTime);
      final result = '''
URL: $_baseUrl$endpoint
Status: ${response.statusCode}
Duration: ${duration.inMilliseconds}ms
Headers: ${response.headers}
Body Length: ${response.body.length} chars
Body: ${response.body}
''';

      developer.log('Raw response received in ${duration.inMilliseconds}ms',
          name: 'ApiService');
      return result;
    } catch (e) {
      developer.log('Raw response error: $e', name: 'ApiService');
      return 'Error: $e\nURL: $_baseUrl$endpoint';
    }
  }

  /// Dispose resources
  void dispose() {
    _client.close();
  }
}

/// Custom exception for API errors
class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => 'ApiException: $message';
}

/// Dashboard data model
class DashboardData {
  final CoffeePriceData price;
  final Map<String, WeatherData> weather;
  final List<AlertData> alerts;
  final String? aiAnalysis;
  final List<Map<String, dynamic>> recentEvents;

  DashboardData({
    required this.price,
    required this.weather,
    required this.alerts,
    this.aiAnalysis,
    required this.recentEvents,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    final priceData = json['price'] as Map<String, dynamic>? ?? {};
    final weatherData = json['weather'] as Map<String, dynamic>? ?? {};

    return DashboardData(
      price: CoffeePriceData.fromJson(priceData),
      weather: weatherData.map(
        (key, value) => MapEntry(
          // Capitalize region names for consistency
          key.substring(0, 1).toUpperCase() + key.substring(1).toLowerCase(),
          WeatherData.fromJson(value as Map<String, dynamic>? ?? {}),
        ),
      ),
      alerts: (json['alerts'] as List? ?? [])
          .map((alert) =>
              AlertData.fromJson(alert as Map<String, dynamic>? ?? {}))
          .toList(),
      aiAnalysis: json['ai_analysis'] as String?,
      recentEvents: (json['recent_events'] as List? ?? [])
          .map((event) => event as Map<String, dynamic>)
          .toList(),
    );
  }
}

/// Coffee price data model
class CoffeePriceData {
  final double bifPerKg;
  final double change24h;
  final double change7d;
  final double usdPerLb;
  final String marketTrend;
  final DateTime lastUpdated;

  CoffeePriceData({
    required this.bifPerKg,
    required this.change24h,
    required this.change7d,
    required this.usdPerLb,
    required this.marketTrend,
    required this.lastUpdated,
  });

  factory CoffeePriceData.fromJson(Map<String, dynamic> json) {
    return CoffeePriceData(
      bifPerKg: (json['bif_per_kg'] as num? ?? 0).toDouble(),
      change24h: (json['change_24h'] as num? ?? 0).toDouble(),
      change7d: (json['change_7d'] as num? ?? 0).toDouble(),
      usdPerLb: (json['usd_per_lb'] as num? ?? 0).toDouble(),
      marketTrend: json['market_trend'] as String? ?? 'unknown',
      lastUpdated: json['last_updated'] != null
          ? DateTime.tryParse(json['last_updated'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  /// Get percentage change for 24h
  double get changePercent24h =>
      bifPerKg > 0 ? (change24h / bifPerKg) * 100 : 0;

  /// Get percentage change for 7d
  double get changePercent7d => bifPerKg > 0 ? (change7d / bifPerKg) * 100 : 0;

  /// Check if 24h price change is positive
  bool get isPositive24h => change24h >= 0;

  /// Check if 7d price change is positive
  bool get isPositive7d => change7d >= 0;
}

/// Weather data model
class WeatherData {
  final double temp;
  final String conditions;
  final int humidity;

  WeatherData({
    required this.temp,
    required this.conditions,
    required this.humidity,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      temp: (json['temp'] as num? ?? 0).toDouble(),
      conditions: json['conditions'] as String? ?? 'Unknown',
      humidity: json['humidity'] as int? ?? 0,
    );
  }
}

/// Alert data model
class AlertData {
  final String id;
  final String title;
  final String message;
  final String type;
  final DateTime timestamp;

  AlertData({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.timestamp,
  });

  factory AlertData.fromJson(Map<String, dynamic> jsonData) {
    // Handle potentially long messages that might be truncated
    String message = jsonData['message'] as String? ?? 'No message';

    // If message looks like JSON (starts with ```json), extract the prediction
    if (message.startsWith('```json')) {
      try {
        // Extract JSON content between ```json and ```
        final jsonStart = message.indexOf('{');
        final jsonEnd = message.lastIndexOf('}') + 1;
        if (jsonStart != -1 && jsonEnd > jsonStart) {
          final jsonStr = message.substring(jsonStart, jsonEnd);
          final parsed = json.decode(jsonStr) as Map<String, dynamic>;
          message = parsed['prediction'] as String? ??
              parsed['reasoning'] as String? ??
              message;
        }
      } catch (e) {
        // Keep original message if parsing fails
      }
    }

    return AlertData(
      id: (jsonData['id'] ?? 'unknown').toString(),
      title: jsonData['title'] as String? ?? 'No title',
      message: message,
      type: jsonData['type'] as String? ?? 'info',
      timestamp: jsonData['timestamp'] != null
          ? DateTime.tryParse(jsonData['timestamp'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  /// Convert type to level for UI compatibility
  String get level {
    switch (type) {
      case 'ai_prediction':
        return 'green';
      case 'warning':
        return 'yellow';
      case 'critical':
        return 'red';
      default:
        return 'green';
    }
  }

  /// Get description for UI compatibility
  String get description => message;
}

/// Region data model
class RegionData {
  final int id;
  final String name;
  final double lat;
  final double lng;
  final int farmers;
  final String alertLevel; // 'green', 'yellow', 'red'
  final double priceBif;
  final WeatherData weather;

  RegionData({
    required this.id,
    required this.name,
    required this.lat,
    required this.lng,
    required this.farmers,
    required this.alertLevel,
    required this.priceBif,
    required this.weather,
  });

  factory RegionData.fromJson(Map<String, dynamic> json) {
    final coordinates = json['coordinates'] as Map<String, dynamic>? ?? {};
    final weatherData = json['weather'] as Map<String, dynamic>? ?? {};

    return RegionData(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? 'Unknown Region',
      lat: (coordinates['lat'] as num? ?? 0).toDouble(),
      lng: (coordinates['lng'] as num? ?? 0).toDouble(),
      farmers: json['farmers'] as int? ?? 0,
      alertLevel: json['alert_level'] as String? ?? 'green',
      priceBif: (json['price_bif'] as num? ?? 0).toDouble(),
      weather: WeatherData.fromJson(weatherData),
    );
  }
}

/// News item data model
class NewsItem {
  final String id;
  final String title;
  final String content;
  final String category; // 'news', 'alert', 'weather', 'price'
  final String level; // 'green', 'yellow', 'red'
  final DateTime timestamp;
  final String? source;

  NewsItem({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    required this.level,
    required this.timestamp,
    this.source,
  });

  factory NewsItem.fromJson(Map<String, dynamic> json) {
    return NewsItem(
      id: (json['id'] ?? 'unknown').toString(),
      title: json['title'] as String? ?? 'No title',
      content: json['content'] as String? ?? 'No content',
      category: json['category'] as String? ?? 'news',
      level: json['level'] as String? ?? 'green',
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp'] as String) ?? DateTime.now()
          : DateTime.now(),
      source: json['source'] as String?,
    );
  }
}
