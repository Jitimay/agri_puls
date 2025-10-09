# AgriPulse - Coffee Crisis Early Warning System

## Overview
AgriPulse is a revolutionary Flutter app that provides Burundian coffee farmers with real-time intelligence through an innovative 3D visualization system called "Echo".

## Key Features

### 🌍 3D Echo Visualization
- **Realistic Terrain**: 3D heightmap-based representation of Burundi's mountainous coffee regions
- **Atmospheric Effects**: Glowing atmosphere with shader-based lighting
- **Orbiting Satellites**: Six realistic satellite models with solar panels and communication dishes:
  - ☕ **Coffee Prices**: Real-time ICO and commodity futures data
  - 🌦️ **Weather Data**: OpenWeatherMap API for all three regions
  - 🦠 **Disease Reports**: Agricultural monitoring and FAO alerts
  - 📈 **Market Data**: Bujumbura market prices and export data
  - 📰 **News Intelligence**: Real-time news analysis with sentiment detection
  - 💱 **Currency Rates**: Live USD/BIF exchange rates

### 🎯 Intelligent Correlations
- **AI-Powered Analysis**: Detects correlations between data streams
- **Visual Pulses**: When intelligence arrives, it pulses through the network
- **Color Coding**: 
  - 🟢 Green (Opportunity)
  - 🟡 Yellow (Watch)
  - 🔴 Red (Threat)

### 🔍 Interactive Features
- **Click Regions**: Get detailed information about specific coffee-growing areas
- **Click Satellites**: View real-time data stream details with actual API data
- **Hover Effects**: Dynamic scaling and cursor changes for interactive elements
- **Real-time Updates**: Live correlation detection and alerts every 5 minutes
- **Intelligence Bursts**: Rapid-fire analysis showing AI pattern recognition
- **Postprocessing Effects**: Bloom and glow effects that respond to data activity

### 📱 Mobile-First Design
- **Flutter Framework**: Cross-platform compatibility
- **WebView Integration**: Seamless 3D visualization in mobile app
- **Responsive UI**: Works on phones, tablets, and desktop
- **Offline Capability**: Core features work without internet

## Technical Architecture

### Frontend
- **Flutter/Dart**: Mobile app framework with real-time data integration
- **Three.js**: Advanced 3D visualization with postprocessing effects
- **WebView Bridge**: Seamless Flutter ↔ JavaScript communication
- **BLoC Pattern**: State management for app-wide data flow
- **HTTP Client**: Real API integration with error handling
- **Shader Programming**: Custom atmospheric and terrain effects

### 🔗 Real Data Sources (Integrated)
- **OpenWeatherMap API**: Live weather data for Kayanza, Ngozi, and Muyinga
- **Alpha Vantage API**: Real-time coffee commodity futures (KC=F)
- **ExchangeRate-API**: Live USD/BIF currency conversion rates
- **NewsAPI**: Real-time news with AI sentiment analysis
- **Fallback Systems**: Mock data generators when APIs are unavailable
- **Caching Layer**: 5-minute cache to optimize API usage and costs

## Installation

```bash
# Clone the repository
git clone https://github.com/yourusername/agripulse.git

# Navigate to project directory
cd agripulse

# Install dependencies
flutter pub get

# Run the app
flutter run
```

## Usage

1. **Dashboard**: View overall coffee market status and key metrics
2. **3D Echo**: Interact with the real-time intelligence visualization
3. **Search**: Ask natural language questions about market conditions
4. **Alerts**: Receive filtered notifications by priority and type

## Killer Queries the System Can Answer

- "What's affecting coffee prices in Kayanza province right now?"
- "Show me weather patterns that could impact harvest in next 30 days"
- "Alert me if coffee rust disease is reported within 50km"
- "How will USD/BIF exchange rate change affect export profits?"

## Business Impact

### For Farmers
- **Early Warning**: Get ahead of price crashes and weather threats
- **Market Intelligence**: Know when to sell for maximum profit
- **Risk Management**: Prepare for disease outbreaks and climate events

### For Burundi's Economy
- **Export Optimization**: Maximize coffee export revenues
- **Supply Chain Efficiency**: Reduce post-harvest losses
- **Market Transparency**: Fair pricing for smallholder farmers

## Development Roadmap

### Phase 1 (Current)
- ✅ 3D visualization prototype
- ✅ Mock data integration
- ✅ Basic correlation detection
- ✅ Interactive UI components

### Phase 2 (Next)
- 🔄 Real API integrations
- 🔄 Machine learning models for price prediction
- 🔄 SMS/USSD integration for rural farmers
- 🔄 Multi-language support (Kirundi, French, English)

### Phase 3 (Future)
- 📋 Blockchain-based supply chain tracking
- 📋 Satellite imagery analysis for crop monitoring
- 📋 IoT sensor integration for farm-level data
- 📋 Cooperative management tools

## Contributing

We welcome contributions from developers, agricultural experts, and data scientists. Please see our contributing guidelines for more information.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Contact

For questions, partnerships, or investment opportunities:
- Email: info@agripulse.bi
- Website: www.agripulse.bi
- Twitter: @AgriPulseBurundi

---

*AgriPulse: Empowering Burundian coffee farmers with intelligence that matters.*# agri_puls
