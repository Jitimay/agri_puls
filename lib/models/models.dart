class CoffeePrice {
  final double current;
  final double change24h;
  final List<PricePoint> history;

  CoffeePrice({required this.current, required this.change24h, required this.history});
}

class PricePoint {
  final DateTime date;
  final double price;

  PricePoint({required this.date, required this.price});
}

class Weather {
  final String region;
  final double temperature;
  final String condition;
  final int humidity;

  Weather({required this.region, required this.temperature, required this.condition, required this.humidity});
}

class Alert {
  final String id;
  final String title;
  final String description;
  final String region;
  final AlertType type;
  final AlertPriority priority;
  final DateTime timestamp;

  Alert({
    required this.id,
    required this.title,
    required this.description,
    required this.region,
    required this.type,
    required this.priority,
    required this.timestamp,
  });
}

enum AlertType { weather, price, disease }
enum AlertPriority { critical, warning, info }

class Region {
  final String name;
  final double lat;
  final double lng;
  final AlertPriority status;

  Region({required this.name, required this.lat, required this.lng, required this.status});
}
