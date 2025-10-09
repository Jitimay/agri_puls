import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;

class DataBridgeService {
  static const String _openWeatherApiKey = 'YOUR_OPENWEATHER_API_KEY';
  static const String _newsApiKey = 'YOUR_NEWS_API_KEY';
  
  // Burundi coffee regions coordinates
  static const List<Map<String, dynamic>> _regions = [
    {'name': 'Kayanza', 'lat': -2.9, 'lon': 29.6},
    {'name': 'Ngozi', 'lat': -2.9, 'lon': 29.8},
    {'name': 'Muyinga', 'lat': -2.8, 'lon': 30.3},
  ];

  /// Fetch real weather data for Burundi coffee regions
  static Future<List<Map<String, dynamic>>> fetchWeatherData() async {
    try {
      final List<Map<String, dynamic>> weatherData = [];
      
      for (final region in _regions) {
        final url = 'https://api.openweathermap.org/data/2.5/weather'
            '?lat=${region['lat']}&lon=${region['lon']}'
            '&appid=$_openWeatherApiKey&units=metric';
        
        final response = await http.get(Uri.parse(url));
        
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          weatherData.add({
            'region': region['name'],
            'temperature': data['main']['temp'],
            'condition': data['weather'][0]['description'],
            'humidity': data['main']['humidity'],
            'windSpeed': data['wind']['speed'],
            'pressure': data['main']['pressure'],
          });
        }
      }
      
      return weatherData.isNotEmpty ? weatherData : _getMockWeatherData();
    } catch (e) {
      developer.log('Weather API failed: $e', name: 'DataBridge');
      return _getMockWeatherData();
    }
  }

  /// Fetch coffee price data (using a free commodity API)
  static Future<Map<String, dynamic>> fetchCoffeePrice() async {
    try {
      // Using Alpha Vantage free API for commodity data
      const url = 'https://www.alphavantage.co/query'
          '?function=GLOBAL_QUOTE&symbol=KC=F&apikey=YOUR_ALPHA_VANTAGE_KEY';
      
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final quote = data['Global Quote'];
        
        return {
          'current': double.parse(quote['05. price']),
          'change24h': double.parse(quote['09. change']),
          'changePercent': quote['10. change percent'],
          'timestamp': DateTime.now().toIso8601String(),
        };
      }
    } catch (e) {
      developer.log('Coffee price API failed: $e', name: 'DataBridge');
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

  /// Fetch news related to coffee and agriculture
  static Future<List<Map<String, dynamic>>> fetchNewsData() async {
    try {
      const query = 'coffee OR agriculture OR Burundi';
      final url = 'https://newsapi.org/v2/everything'
          '?q=$query&apiKey=$_newsApiKey&pageSize=5&sortBy=publishedAt';
      
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final articles = data['articles'] as List;
        
        return articles.map((article) => {
          'title': article['title'],
          'description': article['description'],
          'source': article['source']['name'],
          'publishedAt': article['publishedAt'],
          'sentiment': _analyzeSentiment(
            '${article['title']} ${article['description']}'
          ),
        }).toList();
      }
    } catch (e) {
      developer.log('News API failed: $e', name: 'DataBridge');
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

  // Mock data fallbacks
  static List<Map<String, dynamic>> _getMockWeatherData() {
    return [
      {
        'region': 'Kayanza',
        'temperature': 22 + (DateTime.now().millisecond % 8),
        'condition': 'partly cloudy',
        'humidity': 65 + (DateTime.now().millisecond % 20),
      },
      {
        'region': 'Ngozi',
        'temperature': 20 + (DateTime.now().millisecond % 8),
        'condition': 'sunny',
        'humidity': 60 + (DateTime.now().millisecond % 20),
      },
      {
        'region': 'Muyinga',
        'temperature': 24 + (DateTime.now().millisecond % 8),
        'condition': 'cloudy',
        'humidity': 70 + (DateTime.now().millisecond % 20),
      },
    ];
  }

  static Map<String, dynamic> _getMockCoffeePrice() {
    final random = DateTime.now().millisecond / 1000;
    return {
      'current': 1.20 + random * 0.5,
      'change24h': (random - 0.5) * 0.1,
      'changePercent': '${((random - 0.5) * 10).toStringAsFixed(2)}%',
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  static Map<String, dynamic> _getMockCurrencyData() {
    final random = DateTime.now().millisecond / 1000;
    return {
      'usdToBif': 2000 + random * 100,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  static List<Map<String, dynamic>> _getMockNewsData() {
    final mockNews = [
      {
        'title': 'Coffee prices surge on supply concerns',
        'sentiment': 'opportunity'
      },
      {
        'title': 'Weather patterns favor coffee harvest',
        'sentiment': 'opportunity'
      },
      {
        'title': 'Disease outbreak threatens crops',
        'sentiment': 'threat'
      },
      {
        'title': 'New export agreements signed',
        'sentiment': 'opportunity'
      },
      {
        'title': 'Market volatility continues',
        'sentiment': 'watch'
      },
    ];

    return mockNews.map((news) => {
      ...news,
      'description': 'Latest developments in ${news['title']?.toLowerCase()}',
      'source': 'AgriNews',
      'publishedAt': DateTime.now().toIso8601String(),
    }).toList();
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