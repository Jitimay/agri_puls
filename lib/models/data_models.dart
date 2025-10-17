import 'package:hive/hive.dart';
import 'dart:convert';

part 'data_models.g.dart';

@HiveType(typeId: 0)
class PriceModel extends HiveObject {
  @HiveField(0)
  final double bifPerKg;
  
  @HiveField(1)
  final double usdPerLb;
  
  @HiveField(2)
  final double change24h;
  
  @HiveField(3)
  final double change7d;
  
  @HiveField(4)
  final String trend;
  
  @HiveField(5)
  final String lastUpdated;

  PriceModel({
    required this.bifPerKg,
    required this.usdPerLb,
    required this.change24h,
    required this.change7d,
    required this.trend,
    required this.lastUpdated,
  });

  factory PriceModel.fromJson(Map<String, dynamic> data) {
    return PriceModel(
      bifPerKg: (data['bif_per_kg'] as num).toDouble(),
      usdPerLb: (data['usd_per_lb'] as num).toDouble(),
      change24h: (data['change_24h'] as num).toDouble(),
      change7d: (data['change_7d'] as num).toDouble(),
      trend: data['market_trend'] as String,
      lastUpdated: data['last_updated'] as String,
    );
  }
}

@HiveType(typeId: 1)
class AIPredictionModel extends HiveObject {
  @HiveField(0)
  final String prediction;
  
  @HiveField(1)
  final String confidence;
  
  @HiveField(2)
  final String recommendation;
  
  @HiveField(3)
  final double predictedChange;
  
  @HiveField(4)
  final String reasoning;

  AIPredictionModel({
    required this.prediction,
    required this.confidence,
    required this.recommendation,
    required this.predictedChange,
    required this.reasoning,
  });

  factory AIPredictionModel.fromJson(String aiAnalysis) {
    try {
      final cleanJson = aiAnalysis.replaceAll('```json\n', '').replaceAll('\n```', '');
      final data = json.decode(cleanJson) as Map<String, dynamic>;
      
      return AIPredictionModel(
        prediction: data['prediction'] ?? 'No prediction',
        confidence: data['confidence'] ?? 'medium',
        recommendation: data['recommendation'] ?? 'hold',
        predictedChange: (data['predicted_change'] as num?)?.toDouble() ?? 0,
        reasoning: data['reasoning'] ?? '',
      );
    } catch (e) {
      return AIPredictionModel(
        prediction: aiAnalysis.length > 100 ? '${aiAnalysis.substring(0, 100)}...' : aiAnalysis,
        confidence: 'medium',
        recommendation: 'hold',
        predictedChange: 0,
        reasoning: 'Analysis in progress',
      );
    }
  }
}

@HiveType(typeId: 2)
class RegionModel extends HiveObject {
  @HiveField(0)
  final int id;
  
  @HiveField(1)
  final String name;
  
  @HiveField(2)
  final int farmers;
  
  @HiveField(3)
  final double priceBif;
  
  @HiveField(4)
  final String alertLevel;
  
  @HiveField(5)
  final double temp;
  
  @HiveField(6)
  final String conditions;
  
  @HiveField(7)
  final Map<String, double> coordinates;

  RegionModel({
    required this.id,
    required this.name,
    required this.farmers,
    required this.priceBif,
    required this.alertLevel,
    required this.temp,
    required this.conditions,
    required this.coordinates,
  });

  factory RegionModel.fromJson(Map<String, dynamic> data) {
    final weather = data['weather'] as Map<String, dynamic>;
    final coords = data['coordinates'] as Map<String, dynamic>;
    
    return RegionModel(
      id: data['id'] as int,
      name: data['name'] as String,
      farmers: data['farmers'] as int,
      priceBif: (data['price_bif'] as num).toDouble(),
      alertLevel: data['alert_level'] as String,
      temp: (weather['temp'] as num).toDouble(),
      conditions: weather['conditions'] as String,
      coordinates: {
        'lat': (coords['lat'] as num).toDouble(),
        'lng': (coords['lng'] as num).toDouble(),
      },
    );
  }
}

@HiveType(typeId: 3)
class DashboardModel extends HiveObject {
  @HiveField(0)
  final PriceModel price;
  
  @HiveField(1)
  final AIPredictionModel aiPrediction;
  
  @HiveField(2)
  final Map<String, dynamic> weather;
  
  @HiveField(3)
  final List<Map<String, dynamic>> recentEvents;
  
  @HiveField(4)
  final List<Map<String, dynamic>> alerts;
  
  @HiveField(5)
  final String timestamp;

  DashboardModel({
    required this.price,
    required this.aiPrediction,
    required this.weather,
    required this.recentEvents,
    required this.alerts,
    required this.timestamp,
  });

  factory DashboardModel.fromApiResponse(Map<String, dynamic> apiResponse) {
    final data = apiResponse['data'] as Map<String, dynamic>;
    
    return DashboardModel(
      price: PriceModel.fromJson(data['price']),
      aiPrediction: AIPredictionModel.fromJson(data['ai_analysis']),
      weather: data['weather']['kayanza'] as Map<String, dynamic>,
      recentEvents: (data['recent_events'] as List).cast<Map<String, dynamic>>(),
      alerts: (data['alerts'] as List).cast<Map<String, dynamic>>(),
      timestamp: apiResponse['timestamp'] as String,
    );
  }
}
