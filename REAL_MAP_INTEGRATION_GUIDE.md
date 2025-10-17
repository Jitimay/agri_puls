# Real Map Integration Guide for AgriPulse 3D

## Overview
This guide shows you how to integrate real maps (like Google Maps) into your AgriPulse 3D visualization instead of the generated terrain.

## Integration Options

### 1. OpenStreetMap (Free, No API Key Required)
**Status: ✅ Already Implemented**

The current implementation uses OpenStreetMap tiles which provide:
- Free satellite and terrain imagery
- No API key required
- Good coverage of Burundi
- CORS-friendly

```javascript
// Already implemented in agripulse-3d.js
const mapUrl = `https://tile.openstreetmap.org/${zoom}/${x}/${y}.png`;
```

### 2. Google Maps Static API (Requires API Key)
**Status: ✅ Code Ready**

To use Google Maps:

1. **Get Google Maps API Key:**
   - Go to [Google Cloud Console](https://console.cloud.google.com/)
   - Enable "Maps Static API"
   - Create API key
   - Restrict it to your domain

2. **Update the code:**
   ```javascript
   // In agripulse-3d.js, replace YOUR_GOOGLE_MAPS_API_KEY
   const apiKey = 'your-actual-api-key-here';
   ```

3. **Use Google Maps texture:**
   ```javascript
   // Call this instead of loadMapTexture()
   const texture = await this.loadGoogleMapsTexture(bounds);
   ```

### 3. Mapbox (Alternative, Requires API Key)
**Status: 📝 Implementation Available**

```javascript
async loadMapboxTexture(bounds) {
    const accessToken = 'your-mapbox-token';
    const centerLat = (bounds.north + bounds.south) / 2;
    const centerLon = (bounds.west + bounds.east) / 2;
    
    const mapboxUrl = `https://api.mapbox.com/styles/v1/mapbox/satellite-v9/static/` +
        `${centerLon},${centerLat},8,0/512x512@2x?access_token=${accessToken}`;
    
    return this.loadTextureFromUrl(mapboxUrl, bounds);
}
```

## Current Implementation Features

### ✅ What's Working Now:
- **Real Burundi coordinates** for coffee regions
- **OpenStreetMap integration** with satellite imagery
- **Accurate country borders** based on real geographic data
- **Coffee region overlays** with real locations
- **Elevation data simulation** based on Burundi's actual topography
- **Lake Tanganyika border** representation

### 🔄 Enhanced Features Available:
- **Multiple map sources** (OSM, Satellite, Terrain)
- **Data layer overlays** (Weather, Price, Alerts)
- **Real-time map switching**
- **Google Maps integration** (with API key)

## How to Test Real Maps

### Option 1: Use Current OpenStreetMap Integration
1. The current code already loads real map tiles
2. Open your 3D visualization
3. You should see actual satellite imagery of Burundi

### Option 2: Test Google Maps Integration
1. Open `assets/3d_visualization/google-maps-integration.html`
2. Add your Google Maps API key
3. Test different map sources using the control panel

### Option 3: Verify Real Coordinates
The coffee regions now use real coordinates:
- **Kayanza**: -2.9217°, 29.6297°
- **Ngozi**: -2.9083°, 29.8306°
- **Muyinga**: -2.8444°, 30.3417°
- **Kirundo**: -2.5833°, 30.0833°
- **Gitega**: -3.4264°, 29.9306°

## Troubleshooting

### Map Not Loading?
1. **Check browser console** for CORS errors
2. **Try different tile sources** in the code
3. **Verify internet connection**
4. **Check if tiles are blocked** by your network

### Google Maps Not Working?
1. **Verify API key** is correct
2. **Check API quotas** in Google Cloud Console
3. **Enable required APIs** (Maps Static API)
4. **Add your domain** to API key restrictions

### Blurry or Low Quality Maps?
1. **Increase tile resolution** in the code
2. **Use higher zoom levels** (but be careful of API limits)
3. **Try satellite imagery** instead of road maps

## Code Structure

```
assets/3d_visualization/
├── agripulse-3d.js           # Main 3D engine with real map integration
├── index.html                # Original visualization
├── google-maps-integration.html  # Enhanced version with map controls
└── README.md                 # This guide
```

## Next Steps

1. **Test the current OpenStreetMap integration**
2. **Get Google Maps API key** if you want higher quality imagery
3. **Customize the coffee region overlays** with your specific data
4. **Add more data layers** (weather, prices, alerts)
5. **Integrate with your Flutter app** using the WebView

## API Costs (Approximate)

- **OpenStreetMap**: Free
- **Google Maps Static API**: $2 per 1,000 requests
- **Mapbox**: $0.50 per 1,000 requests

For development and testing, OpenStreetMap is perfect. For production with high traffic, consider the paid options for better quality and reliability.