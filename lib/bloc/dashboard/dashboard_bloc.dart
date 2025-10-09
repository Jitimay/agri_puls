import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/models.dart';
import '../../data/mock_service.dart';

part 'dashboard_event.dart';
part 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final MockDataService _dataService = MockDataService();
  StreamSubscription? _priceSubscription;
  StreamSubscription? _weatherSubscription;
  StreamSubscription? _alertsSubscription;

  DashboardBloc() : super(DashboardInitial()) {
    on<LoadDashboard>(_onLoadDashboard);
    on<RefreshDashboard>(_onRefreshDashboard);
    on<UpdatePrice>(_onUpdatePrice);
    on<UpdateWeather>(_onUpdateWeather);
    on<UpdateAlerts>(_onUpdateAlerts);
  }

  void _onLoadDashboard(LoadDashboard event, Emitter<DashboardState> emit) {
    emit(DashboardLoading());
    _dataService.startUpdates();
    _subscribeToUpdates();
  }

  void _onRefreshDashboard(RefreshDashboard event, Emitter<DashboardState> emit) {
    _dataService.startUpdates();
  }

  void _onUpdatePrice(UpdatePrice event, Emitter<DashboardState> emit) {
    if (state is DashboardLoaded) {
      final currentState = state as DashboardLoaded;
      emit(currentState.copyWith(price: event.price));
    }
  }

  void _onUpdateWeather(UpdateWeather event, Emitter<DashboardState> emit) {
    if (state is DashboardLoaded) {
      final currentState = state as DashboardLoaded;
      emit(currentState.copyWith(weather: event.weather));
    } else {
      emit(DashboardLoaded(
        price: const CoffeePrice(current: 0, change24h: 0, history: []),
        weather: event.weather,
        alerts: const [],
      ));
    }
  }

  void _onUpdateAlerts(UpdateAlerts event, Emitter<DashboardState> emit) {
    if (state is DashboardLoaded) {
      final currentState = state as DashboardLoaded;
      emit(currentState.copyWith(alerts: event.alerts));
    }
  }

  void _subscribeToUpdates() {
    _priceSubscription = _dataService.priceStream.listen((price) {
      add(UpdatePrice(price));
    });

    _weatherSubscription = _dataService.weatherStream.listen((weather) {
      add(UpdateWeather(weather));
    });

    _alertsSubscription = _dataService.alertsStream.listen((alerts) {
      add(UpdateAlerts(alerts));
    });
  }

  @override
  Future<void> close() {
    _priceSubscription?.cancel();
    _weatherSubscription?.cancel();
    _alertsSubscription?.cancel();
    return super.close();
  }
}
