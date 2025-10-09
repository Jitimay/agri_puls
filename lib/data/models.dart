import 'package:equatable/equatable.dart';

class CoffeePrice extends Equatable {
  final double current;
  final double change24h;
  final List<PricePoint> history;

  const CoffeePrice({required this.current, required this.change24h, required this.history});

  @override
  List<Object> get props => [current, change24h, history];
}

class PricePoint extends Equatable {
  final DateTime date;
  final double price;

  const PricePoint({required this.date, required this.price});

  @override
  List<Object> get props => [date, price];
}

class Weather extends Equatable {
  final String region;
  final double temperature;
  final String condition;
  final int humidity;

  const Weather({required this.region, required this.temperature, required this.condition, required this.humidity});

  @override
  List<Object> get props => [region, temperature, condition, humidity];
}

class Alert extends Equatable {
  final String id;
  final String title;
  final String description;
  final String region;
  final AlertType type;
  final AlertPriority priority;
  final DateTime timestamp;

  const Alert({
    required this.id,
    required this.title,
    required this.description,
    required this.region,
    required this.type,
    required this.priority,
    required this.timestamp,
  });

  @override
  List<Object> get props => [id, title, description, region, type, priority, timestamp];
}

enum AlertType { weather, price, disease }
enum AlertPriority { critical, warning, info }

class Region extends Equatable {
  final String name;
  final double lat;
  final double lng;
  final AlertPriority status;

  const Region({required this.name, required this.lat, required this.lng, required this.status});

  @override
  List<Object> get props => [name, lat, lng, status];
}
