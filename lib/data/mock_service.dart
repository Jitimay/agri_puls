import 'dart:async';
import 'dart:math';
import 'models.dart';

class MockDataService {
  static final MockDataService _instance = MockDataService._internal();
  factory MockDataService() => _instance;
  MockDataService._internal();

  final Random _random = Random();
  Timer? _timer;

  final StreamController<CoffeePrice> _priceController = StreamController<CoffeePrice>.broadcast();
  final StreamController<List<Weather>> _weatherController = StreamController<List<Weather>>.broadcast();
  final StreamController<List<Alert>> _alertsController = StreamController<List<Alert>>.broadcast();

  Stream<CoffeePrice> get priceStream => _priceController.stream;
  Stream<List<Weather>> get weatherStream => _weatherController.stream;
  Stream<List<Alert>> get alertsStream => _alertsController.stream;

  double _currentPrice = 2.45;

  void startUpdates() {
    _timer = Timer.periodic(const Duration(seconds: 30), (_) => _updateData());
    _updateData();
  }

  void _updateData() {
    _updatePrice();
    _updateWeather();
    _updateAlerts();
  }

  void _updatePrice() {
    final change = (_random.nextDouble() - 0.5) * 0.1;
    final oldPrice = _currentPrice;
    _currentPrice = (_currentPrice + change).clamp(1.5, 4.0);
    
    final history = List.generate(30, (i) => PricePoint(
      date: DateTime.now().subtract(Duration(days: 29 - i)),
      price: 2.0 + _random.nextDouble() * 1.5,
    ));

    _priceController.add(CoffeePrice(
      current: _currentPrice,
      change24h: _currentPrice - oldPrice,
      history: history,
    ));
  }

  void _updateWeather() {
    final regions = ['Kayanza', 'Ngozi', 'Muyinga'];
    final conditions = ['Sunny', 'Cloudy', 'Rainy', 'Partly Cloudy'];
    
    final weather = regions.map((region) => Weather(
      region: region,
      temperature: 18 + _random.nextDouble() * 12,
      condition: conditions[_random.nextInt(conditions.length)],
      humidity: 40 + _random.nextInt(40),
    )).toList();

    _weatherController.add(weather);
  }

  void _updateAlerts() {
    final alerts = [
      Alert(
        id: '1',
        title: 'Price Drop Alert',
        description: 'Coffee prices dropped 8% in the last 24 hours',
        region: 'Kayanza',
        type: AlertType.price,
        priority: AlertPriority.warning,
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      Alert(
        id: '2',
        title: 'Heavy Rain Warning',
        description: 'Heavy rainfall expected in the next 48 hours',
        region: 'Ngozi',
        type: AlertType.weather,
        priority: AlertPriority.critical,
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      Alert(
        id: '3',
        title: 'Coffee Rust Detected',
        description: 'Coffee leaf rust spotted in several farms',
        region: 'Muyinga',
        type: AlertType.disease,
        priority: AlertPriority.critical,
        timestamp: DateTime.now().subtract(const Duration(hours: 6)),
      ),
    ];

    _alertsController.add(alerts);
  }

  List<Region> getRegions() {
    return const [
      Region(name: 'Kayanza', lat: -2.9, lng: 29.6, status: AlertPriority.warning),
      Region(name: 'Ngozi', lat: -2.9, lng: 29.8, status: AlertPriority.critical),
      Region(name: 'Muyinga', lat: -2.8, lng: 30.3, status: AlertPriority.info),
    ];
  }

  void dispose() {
    _timer?.cancel();
    _priceController.close();
    _weatherController.close();
    _alertsController.close();
  }
}
