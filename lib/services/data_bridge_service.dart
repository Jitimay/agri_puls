import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;

class DataBridgeService {
  // Real API keys
  static const String _alphaVantageApiKey = 'Z03KD4O08O3I2WN7';
  static const String _newsApiKey = 'pub_1860c0e6ca6649e48931e2ca33c8f7ce';
  
  // Open Meteo API endpoint (no API key needed - free service)
  static const String _openMeteoBaseUrl = 'https://api.open-meteo.com/v1/forecast';
  
  // Burundi coffee regions coordinates
  static const List<Map<String, dynamic>> _regions = [
    {'name': 'Kayanza', 'lat': -2.9, 'lon': 29.6},
    {'name': 'Ngozi', 'lat': -2.9, 'lon': 29.8},
    {'name': 'Muyinga', 'lat': -2.8, 'lon': 30.3},
  ];

  /// Fetch real weather data for Burundi coffee regions using Open Meteo
  static Future<List<Map<String, dynamic>>> fetchWeatherData() async {
    try {
      final List<Map<String, dynamic>> weatherData = [];
      
      for (final region in _regions) {
        final url = '$_openMeteoBaseUrl'
            '?latitude=${region['lat']}'
            '&longitude=${region['lon']}'
            '&current=temperature_2m,relative_humidity_2m,wind_speed_10m,weather_code,surface_pressure'
            '&timezone=Africa/Bujumbura';
        
        final response = await http.get(Uri.parse(url));
        
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final current = data['current'];
          
          if (current != null) {
            weatherData.add({
              'region': region['name'],
              'temperature': current['temperature_2m']?.toDouble() ?? 0.0,
              'condition': _getWeatherCondition(current['weather_code']?.toInt() ?? 0),
              'humidity': current['relative_humidity_2m']?.toDouble() ?? 0.0,
              'windSpeed': current['wind_speed_10m']?.toDouble() ?? 0.0,
              'pressure': current['surface_pressure']?.toDouble() ?? 0.0,
              'timestamp': DateTime.now().toIso8601String(),
            });
          }
        }
      }
      
      return weatherData.isNotEmpty ? weatherData : _getMockWeatherData();
    } catch (e) {
      developer.log('Open Meteo API failed: $e', name: 'DataBridge');
      return _getMockWeatherData();
    }
  }
  
  /// Convert weather code to human-readable condition
  static String _getWeatherCondition(int code) {
    switch (code) {
      case 0:
        return 'Clear sky';
      case 1:
      case 2:
      case 3:
        return 'Partly cloudy';
      case 45:
      case 48:
        return 'Foggy';
      case 51:
      case 53:
      case 55:
        return 'Light rain';
      case 61:
      case 63:
      case 65:
        return 'Rain';
      case 71:
      case 73:
      case 75:
        return 'Snow';
      case 80:
      case 81:
      case 82:
        return 'Rain showers';
      case 95:
        return 'Thunderstorm';
      case 96:
      case 99:
        return 'Thunderstorm with hail';
      default:
        return 'Unknown';
    }
  }

  /// Fetch coffee price data using Alpha Vantage API
  static Future<Map<String, dynamic>> fetchCoffeePrice() async {
    try {
      // Using Alpha Vantage API for coffee futures (KC=F)
      final url = 'https://www.alphavantage.co/query'
          '?function=GLOBAL_QUOTE&symbol=KC=F&apikey=$_alphaVantageApiKey';
      
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // Check if we have valid data
        if (data.containsKey('Global Quote') && data['Global Quote'].isNotEmpty) {
          final quote = data['Global Quote'];
          
          return {
            'current': double.tryParse(quote['05. price'] ?? '0') ?? 0.0,
            'change24h': double.tryParse(quote['09. change'] ?? '0') ?? 0.0,
            'changePercent': quote['10. change percent'] ?? '0%',
            'volume': int.tryParse(quote['06. volume'] ?? '0') ?? 0,
            'timestamp': DateTime.now().toIso8601String(),
          };
        } else {
          developer.log('Alpha Vantage returned empty data, using fallback', name: 'DataBridge');
        }
      }
    } catch (e) {
      developer.log('Alpha Vantage API failed: $e', name: 'DataBridge');
    }
    
    return _getMockCoffeePrice();
  }

  /// Fetch currency exchange rates
  static Future<Map<String, dynamic>> fetchCurrencyRates() async {
    try {
      const url = 'https://api.exchangerate-api.com/v4/latest/USD';
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        return {
          'usdToBif': data['rates']['BIF'] ?? 2000,
          'timestamp': DateTime.now().toIso8601String(),
        };
      }
    } catch (e) {
      developer.log('Currency API failed: $e', name: 'DataBridge');
    }
    
    return _getMockCurrencyData();
  }

  /// Fetch news related to coffee and agriculture using NewsData.io
  static Future<List<Map<String, dynamic>>> fetchNewsData() async {
    try {
      // Using NewsData.io API (more reliable than NewsAPI for free tier)
      const query = 'coffee,agriculture,Burundi';
      final url = 'https://newsdata.io/api/1/news'
          '?apikey=$_newsApiKey&q=$query&language=en&size=5';
      
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['status'] == 'success' && data['results'] != null) {
          final articles = data['results'] as List;
          
          return articles.map((article) => {
            'title': article['title'] ?? 'No title',
            'description': article['description'] ?? article['content'] ?? 'No description',
            'source': article['source_id'] ?? 'Unknown',
            'publishedAt': article['pubDate'] ?? DateTime.now().toIso8601String(),
            'sentiment': _analyzeSentiment(
              '${article['title'] ?? ''} ${article['description'] ?? article['content'] ?? ''}'
            ),
          }).toList();
        }
      }
    } catch (e) {
      developer.log('NewsData API failed: $e', name: 'DataBridge');
    }
    
    return _getMockNewsData();
  }

  /// Simple sentiment analysis
  static String _analyzeSentiment(String text) {
    const positiveWords = [
      'good', 'increase', 'growth', 'profit', 'success', 'opportunity',
      'rise', 'boost', 'improve', 'strong', 'positive', 'gain'
    ];
    const negativeWords = [
      'bad', 'decrease', 'loss', 'crisis', 'threat', 'problem',
      'fall', 'drop', 'decline', 'weak', 'negative', 'risk'
    ];
    
    final lowerText = text.toLowerCase();
    final positiveCount = positiveWords
        .where((word) => lowerText.contains(word))
        .length;
    final negativeCount = negativeWords
        .where((word) => lowerText.contains(word))
        .length;
    
    if (positiveCount > negativeCount) return 'opportunity';
    if (negativeCount > positiveCount) return 'threat';
    return 'watch';
  }

  // Mock data fallbacks with realistic Burundi weather patterns
  static List<Map<String, dynamic>> _getMockWeatherData() {
    final now = DateTime.now();
    final random = now.millisecond / 1000;
    
    // Burundi has two rainy seasons: Oct-Dec and Mar-May
    final isRainySeason = (now.month >= 10 && now.month <= 12) || 
                         (now.month >= 3 && now.month <= 5);
    
    final conditions = isRainySeason 
        ? ['Rain showers', 'Partly cloudy', 'Thunderstorm', 'Light rain']
        : ['Clear sky', 'Partly cloudy', 'Sunny', 'Light clouds'];
    
    return [
      {
        'region': 'Kayanza',
        'temperature': 18 + random * 8, // 18-26°C typical for Kayanza
        'condition': conditions[(now.second % conditions.length)],
        'humidity': isRainySeason ? 75 + random * 20 : 55 + random * 20,
        'windSpeed': 2 + random * 8,
        'pressure': 1010 + random * 20,
        'timestamp': now.toIso8601String(),
      },
      {
        'region': 'Ngozi',
        'temperature': 16 + random * 8, // Slightly cooler, higher altitude
        'condition': conditions[((now.second + 1) % conditions.length)],
        'humidity': isRainySeason ? 80 + random * 15 : 60 + random * 20,
        'windSpeed': 3 + random * 7,
        'pressure': 1005 + random * 25,
        'timestamp': now.toIso8601String(),
      },
      {
        'region': 'Muyinga',
        'temperature': 20 + random * 8, // Warmer, lower altitude
        'condition': conditions[((now.second + 2) % conditions.length)],
        'humidity': isRainySeason ? 70 + random * 25 : 50 + random * 25,
        'windSpeed': 1 + random * 6,
        'pressure': 1015 + random * 15,
        'timestamp': now.toIso8601String(),
      },
    ];
  }

  static Map<String, dynamic> _getMockCoffeePrice() {
    final now = DateTime.now();
    final random = now.millisecond / 1000;
    
    // Realistic coffee futures price range (KC=F typically 100-200 cents/lb)
    final basePrice = 150 + (now.day % 30) * 2; // Varies by day
    final dailyVariation = (random - 0.5) * 10; // ±5 cents variation
    final currentPrice = basePrice + dailyVariation;
    
    return {
      'current': currentPrice / 100, // Convert cents to dollars
      'change24h': dailyVariation / 100,
      'changePercent': '${(dailyVariation / basePrice * 100).toStringAsFixed(2)}%',
      'volume': 5000 + (random * 10000).round(),
      'timestamp': now.toIso8601String(),
    };
  }

  static Map<String, dynamic> _getMockCurrencyData() {
    final now = DateTime.now();
    final random = now.millisecond / 1000;
    
    // Realistic BIF exchange rate (typically 1800-2200 BIF per USD)
    final baseRate = 2000 + (now.day % 15) * 10; // Varies by day
    final dailyChange = (random - 0.5) * 50; // ±25 BIF variation
    
    return {
      'usdToBif': baseRate + dailyChange,
      'change24h': dailyChange,
      'changePercent': '${(dailyChange / baseRate * 100).toStringAsFixed(2)}%',
      'timestamp': now.toIso8601String(),
    };
  }

  static List<Map<String, dynamic>> _getMockNewsData() {
    final now = DateTime.now();
    final newsItems = [
      {
        'title': 'Burundi coffee exports reach record high in Q${(now.month / 3).ceil()}',
        'description': 'Coffee cooperatives report 25% increase in premium grade exports to European markets',
        'sentiment': 'opportunity',
        'source': 'Burundi Coffee Board'
      },
      {
        'title': 'Climate-resistant coffee varieties show promise in Kayanza',
        'description': 'New arabica strains demonstrate 30% better yield under changing weather conditions',
        'sentiment': 'opportunity',
        'source': 'ISABU Research'
      },
      {
        'title': 'Coffee leaf rust detected in ${_regions[now.day % 3]['name']} province',
        'description': 'Agricultural extension services mobilize to contain fungal outbreak affecting local farms',
        'sentiment': 'threat',
        'source': 'Ministry of Agriculture'
      },
      {
        'title': 'International coffee prices volatile amid Brazil drought concerns',
        'description': 'Arabica futures fluctuate as weather patterns threaten South American harvest',
        'sentiment': 'watch',
        'source': 'ICO Market Report'
      },
      {
        'title': 'Digital payment systems boost farmer income in rural cooperatives',
        'description': 'Mobile money integration reduces transaction costs by 15% for coffee farmers',
        'sentiment': 'opportunity',
        'source': 'FinTech Burundi'
      },
    ];

    // Return 3-4 random news items
    final selectedNews = <Map<String, dynamic>>[];
    final indices = List.generate(newsItems.length, (i) => i)..shuffle();
    
    for (int i = 0; i < (3 + now.second % 2); i++) {
      final news = newsItems[indices[i]];
      selectedNews.add({
        ...news,
        'publishedAt': now.subtract(Duration(hours: i * 2)).toIso8601String(),
      });
    }

    return selectedNews;
  }

  /// Generate JavaScript code to update the 3D visualization
  static String generateUpdateScript(Map<String, dynamic> data) {
    return '''
      if (window.agriPulse3D && window.agriPulse3D.dataService) {
        const data = ${json.encode(data)};
        
        // Update weather data
        if (data.weather) {
          window.agriPulse3D.processWeatherData(data.weather);
        }
        
        // Update coffee price data
        if (data.coffeePrice) {
          window.agriPulse3D.processPriceData(data.coffeePrice);
        }
        
        // Update currency data
        if (data.currency) {
          window.agriPulse3D.processCurrencyData(data.currency);
        }
        
        // Update news data
        if (data.news) {
          window.agriPulse3D.processNewsData(data.news);
        }
        
        // Trigger intelligence burst for dramatic effect
        window.agriPulse3D.triggerIntelligenceBurst();
      }
    ''';
  }
}