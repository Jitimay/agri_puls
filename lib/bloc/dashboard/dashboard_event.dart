part of 'dashboard_bloc.dart';

abstract class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object> get props => [];
}

class LoadDashboard extends DashboardEvent {}

class RefreshDashboard extends DashboardEvent {}

class UpdatePrice extends DashboardEvent {
  final CoffeePrice price;

  const UpdatePrice(this.price);

  @override
  List<Object> get props => [price];
}

class UpdateWeather extends DashboardEvent {
  final List<Weather> weather;

  const UpdateWeather(this.weather);

  @override
  List<Object> get props => [weather];
}

class UpdateAlerts extends DashboardEvent {
  final List<Alert> alerts;

  const UpdateAlerts(this.alerts);

  @override
  List<Object> get props => [alerts];
}
