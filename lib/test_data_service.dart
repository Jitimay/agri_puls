import 'dart:developer' as developer;
import 'services/data_bridge_service.dart';

/// Simple test function to verify data services are working
Future<void> testDataServices() async {
  developer.log('Testing AgriPulse Data Services...', name: 'DataTest');
  
  try {
    // Test weather data
    developer.log('Fetching weather data...', name: 'DataTest');
    final weatherData = await DataBridgeService.fetchWeatherData();
    developer.log('Weather data: ${weatherData.length} regions', name: 'DataTest');
    for (final weather in weatherData) {
      developer.log('${weather['region']}: ${weather['temperature']}°C, ${weather['condition']}', name: 'DataTest');
    }
    
    // Test coffee price data
    developer.log('Fetching coffee price data...', name: 'DataTest');
    final priceData = await DataBridgeService.fetchCoffeePrice();
    developer.log('Coffee price: \$${priceData['current']}, change: ${priceData['changePercent']}', name: 'DataTest');
    
    // Test currency data
    developer.log('Fetching currency data...', name: 'DataTest');
    final currencyData = await DataBridgeService.fetchCurrencyRates();
    developer.log('USD/BIF: ${currencyData['usdToBif']}', name: 'DataTest');
    
    // Test news data
    developer.log('Fetching news data...', name: 'DataTest');
    final newsData = await DataBridgeService.fetchNewsData();
    developer.log('News articles: ${newsData.length}', name: 'DataTest');
    for (final news in newsData.take(2)) {
      developer.log('${news['title']} (${news['sentiment']})', name: 'DataTest');
    }
    
    developer.log('All data services working correctly!', name: 'DataTest');
    
  } catch (e) {
    developer.log('Data service test failed: $e', name: 'DataTest');
  }
}