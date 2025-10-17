# Backend Integration Setup Guide

## 🚀 Quick Setup

### 1. Update Backend IP Address
Edit `lib/services/api_service.dart` and replace the IP address:
```dart
static const String _baseUrl = 'http://YOUR_BACKEND_IP:5001/api';
```

**Common IP addresses:**
- **Android Emulator**: `http://10.0.2.2:5001/api`
- **iOS Simulator**: `http://localhost:5001/api` or `http://127.0.0.1:5001/api`
- **Physical Device**: `http://192.168.1.XXX:5001/api` (your computer's local IP)

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Add Permissions (Android)
Add to `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.MICROPHONE" />
```

### 4. Add Permissions (iOS)
Add to `ios/Runner/Info.plist`:
```xml
<key>NSMicrophoneUsageDescription</key>
<string>This app needs microphone access for voice search</string>
<key>NSSpeechRecognitionUsageDescription</key>
<string>This app needs speech recognition for voice search</string>
```

## 🔧 Features Implemented

### ✅ API Service (`lib/services/api_service.dart`)
- **Dashboard Data**: Fetches coffee prices in BIF, weather, alerts
- **Regions Data**: Gets 5 coffee regions with coordinates and data
- **AI Questions**: Voice search integration with backend AI
- **Error Handling**: Graceful fallbacks and user-friendly error messages

### ✅ Updated Dashboard (`lib/screens/dashboard_screen.dart`)
- **Real Coffee Prices**: Displays prices in BIF (Burundian Francs)
- **Percentage Changes**: Green/red color coding for price changes
- **Pull-to-Refresh**: Swipe down to update data
- **Kirundi Labels**: "Igiciro cy'ikawa" (Coffee Price), "Ikirere" (Weather)
- **Loading States**: Shimmer loading animations
- **Error Handling**: Retry buttons with Kirundi text

### ✅ Enhanced 3D Map (`lib/screens/map_screen.dart`)
- **Real Regions**: Fetches 5 regions from `/api/regions`
- **GPS Coordinates**: Uses real lat/lng from API
- **Color Coding**: Green/Yellow/Red markers based on alert_level
- **Region Details**: Shows farmers count, current price, weather
- **Tap Interaction**: Bottom sheet with detailed region info
- **Kirundi Interface**: "Uturere tw'ikawa" (Coffee Regions)

### ✅ Voice Search (`lib/screens/voice_search_screen.dart`)
- **Multi-Language**: Kirundi, English, French support
- **Speech Recognition**: Real-time voice-to-text
- **AI Integration**: Sends questions to `/api/ai/ask`
- **Animated UI**: Pulsing microphone button
- **Quick Questions**: Pre-defined common questions in Kirundi
- **Error Handling**: Voice recognition and API error handling

### ✅ Updated Navigation
- **Voice Search Tab**: Replaced "Search" with "Baza" (Ask in Kirundi)
- **Microphone Icon**: Clear voice search indication
- **Consistent Theming**: Coffee brown color scheme

## 📱 How to Test

### 1. Test API Connection
```bash
# Start your backend server first
# Then run the Flutter app
flutter run
```

### 2. Test Dashboard
- Pull down to refresh
- Check if coffee prices load in BIF
- Verify weather data for regions
- Test error handling (stop backend server)

### 3. Test Map
- Tap refresh button in app bar
- Check if 5 regions appear on map
- Tap markers to see region details
- Verify color coding (green/yellow/red)

### 4. Test Voice Search
- Grant microphone permissions
- Select language (Kirundi/English/French)
- Tap microphone button and speak
- Try quick questions in Kirundi
- Check AI responses

## 🐛 Troubleshooting

### API Connection Issues
1. **Check IP Address**: Ensure backend IP is correct in `api_service.dart`
2. **Network Access**: Verify phone/emulator can reach backend
3. **Backend Running**: Confirm backend server is running on port 5001
4. **Firewall**: Check if firewall blocks port 5001

### Voice Search Issues
1. **Permissions**: Grant microphone permissions in device settings
2. **Language Support**: Some languages may not be available on all devices
3. **Network**: Voice recognition may require internet connection

### Map Issues
1. **Google Maps API**: Ensure Google Maps API key is configured
2. **Location Services**: May need location permissions for some features

## 🔄 API Response Examples

### Dashboard Response
```json
{
  "success": true,
  "data": {
    "price": {
      "bif_per_kg": 4800,
      "change_24h": 120
    },
    "weather": {
      "kayanza": {"temp": 24, "conditions": "Partly Cloudy"}
    },
    "alerts": [
      {"level": "yellow", "title": "Rain Expected", "description": "..."}
    ]
  }
}
```

### Regions Response
```json
{
  "success": true,
  "regions": [
    {
      "id": 1,
      "name": "Kayanza",
      "coordinates": {"lat": -2.9217, "lng": 29.6297},
      "farmers": 120000,
      "alert_level": "green",
      "price_bif": 4800,
      "weather": {"temp": 24, "conditions": "Partly Cloudy"}
    }
  ]
}
```

### AI Response
```json
{
  "success": true,
  "answer": "Igiciro cy'ikawa ubu ni 4800 BIF ku kilo...",
  "language": "rn"
}
```

## 🌟 Production Ready Features

- **Error Handling**: Comprehensive error handling with user-friendly messages
- **Loading States**: Professional loading animations and indicators
- **Offline Graceful**: App works even when backend is unavailable
- **Responsive UI**: Works on phones, tablets, and different screen sizes
- **Accessibility**: Proper labels and semantic widgets
- **Performance**: Efficient API calls with proper caching
- **Security**: No hardcoded sensitive data
- **Internationalization**: Kirundi language support throughout

Your AgriPulse app is now fully integrated with your backend API and ready for production use! 🚀