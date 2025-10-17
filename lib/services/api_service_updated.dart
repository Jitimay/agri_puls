import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import '../models/data_models.dart';
import 'hive_service.dart';

class ApiService {
  static const String _baseUrl = 'http://192.168.138.127:5001/api';
  static const Duration _timeout = Duration(seconds: 10);
  
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final http.Client _client = http.Client();

  Future<Map<String, dynamic>> _get(String endpoint) async {
    try {
      developer.log('API Request: GET $_baseUrl$endpoint', name: 'ApiService');
      
      final response = await _client
          .get(Uri.parse('$_baseUrl$endpoint'))
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        
        if (data['success'] == true) {
          return data;
        } else {
          throw ApiException('API returned success: false');
        }
      } else {
        throw ApiException('HTTP ${response.statusCode}: ${response.reasonPhrase}');
      }
    } catch (e) {
      developer.log('API Error: $e', name: 'ApiService');
      if (e is ApiException) rethrow;
      throw ApiException('Network error: $e');
    }
  }

  Future<DashboardModel> getDashboardData() async {
    try {
      final response = await _get('/dashboard');
      final dashboard = DashboardModel.fromApiResponse(response);
      
      // Save to Hive
      await HiveService.saveDashboard(dashboard);
      await HiveService.savePriceHistory(dashboard.price);
      
      return dashboard;
    } catch (e) {
      developer.log('Failed to fetch dashboard data: $e', name: 'ApiService');
      
      // Try to get from Hive cache
      final cached = HiveService.getLatestDashboard();
      if (cached != null) {
        developer.log('Using cached dashboard data', name: 'ApiService');
        return cached;
      }
      
      // Return mock data as last resort
      return _getMockDashboard();
    }
  }

  Future<List<RegionModel>> getRegions() async {
    try {
      final response = await _get('/regions');
      final regionsJson = response['regions'] as List;
      final regions = regionsJson
          .map((json) => RegionModel.fromJson(json))
          .toList();

      // Save to Hive
      await HiveService.saveRegions(regions);
      
      return regions;
    } catch (e) {
      developer.log('Failed to fetch regions: $e', name: 'ApiService');
      
      // Try to get from Hive cache
      final cached = HiveService.getLatestRegions();
      if (cached != null) {
        developer.log('Using cached regions data', name: 'ApiService');
        return cached;
      }
      
      // Return mock data as last resort
      return _getMockRegions();
    }
  }

  Future<String> askAI(String question, {String language = 'rn'}) async {
    try {
      final encodedQuestion = Uri.encodeComponent(question);
      final response = await _get('/ai/ask?q=$encodedQuestion&lang=$language');
      return response['answer'] as String;
    } catch (e) {
      developer.log('Failed to ask AI: $e', name: 'ApiService');
      
      // Fallback response based on language
      if (language == 'rn') {
        return 'Ikibazo cyawe cyakiriwe. Komeza gukurikirana amakuru.';
      } else {
        return 'Your question has been received. Please check back for updates.';
      }
    }
  }

  DashboardModel _getMockDashboard() {
    final mockResponse = {
      'data': {
        'price': {
          'bif_per_kg': 4800,
          'usd_per_lb': 2.45,
          'change_24h': 2.3,
          'change_7d': -1.2,
          'market_trend': 'stable',
          'last_updated': DateTime.now().toIso8601String(),
        },
        'ai_analysis': json.encode({
          'prediction': 'Igiciro cy\'ikawa gishobora kwiyongera gato mu minsi 2-3 bizaza.',
          'confidence': 'medium',
          'recommendation': 'hold',
          'predicted_change': 1.5,
          'reasoning': 'Market conditions are stable with slight upward pressure.'
        }),
        'weather': {
          'kayanza': {
            'temp': 24,
            'conditions': 'Partly Cloudy',
            'humidity': 67
          }
        },
        'recent_events': [],
        'alerts': [
          {
            'id': '1',
            'type': 'info',
            'title': 'Offline Mode',
            'message': 'Using cached data. Connect to internet for latest updates.',
            'timestamp': DateTime.now().toIso8601String()
          }
        ]
      },
      'timestamp': DateTime.now().toIso8601String()
    };
    
    return DashboardModel.fromApiResponse(mockResponse);
  }

  List<RegionModel> _getMockRegions() {
    final mockRegions = [
      {
        'id': 1,
        'name': 'Kayanza',
        'coordinates': {'lat': -2.9217, 'lng': 29.6297},
        'farmers': 120000,
        'alert_level': 'green',
        'price_bif': 4800,
        'weather': {'temp': 24, 'conditions': 'Partly Cloudy'}
      },
      {
        'id': 2,
        'name': 'Ngozi',
        'coordinates': {'lat': -2.9078, 'lng': 29.8306},
        'farmers': 98000,
        'alert_level': 'yellow',
        'price_bif': 4750,
        'weather': {'temp': 22, 'conditions': 'Cloudy'}
      },
      {
        'id': 3,
        'name': 'Kirundo',
        'coordinates': {'lat': -2.5847, 'lng': 30.0953},
        'farmers': 85000,
        'alert_level': 'green',
        'price_bif': 4850,
        'weather': {'temp': 26, 'conditions': 'Sunny'}
      }
    ];
    
    return mockRegions.map((json) => RegionModel.fromJson(json)).toList();
  }

  void dispose() {
    _client.close();
  }
}

class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  
  @override
  String toString() => 'ApiException: $message';
}
