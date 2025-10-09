part of 'dashboard_bloc.dart';

abstract class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object> get props => [];
}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardLoaded extends DashboardState {
  final CoffeePrice price;
  final List<Weather> weather;
  final List<Alert> alerts;

  const DashboardLoaded({
    required this.price,
    required this.weather,
    required this.alerts,
  });

  DashboardLoaded copyWith({
    CoffeePrice? price,
    List<Weather>? weather,
    List<Alert>? alerts,
  }) {
    return DashboardLoaded(
      price: price ?? this.price,
      weather: weather ?? this.weather,
      alerts: alerts ?? this.alerts,
    );
  }

  @override
  List<Object> get props => [price, weather, alerts];
}
