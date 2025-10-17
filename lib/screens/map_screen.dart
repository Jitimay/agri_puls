import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final ApiService _apiService = ApiService();
  Set<Marker> _markers = {};
  List<RegionData> _regions = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadRegions();
  }

  Future<void> _loadRegions() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final regions = await _apiService.getRegions();
      setState(() {
        _regions = regions;
        _isLoading = false;
      });
      _createMarkers();
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _createMarkers() {
    _markers = _regions.map((region) => Marker(
      markerId: MarkerId(region.name),
      position: LatLng(region.lat, region.lng),
      onTap: () => _showRegionInfo(region),
      icon: BitmapDescriptor.defaultMarkerWithHue(_getMarkerColor(region.alertLevel)),
      infoWindow: InfoWindow(
        title: region.name,
        snippet: '${region.farmers.toString()} abahinzi',
      ),
    )).toSet();
  }

  double _getMarkerColor(String alertLevel) {
    switch (alertLevel) {
      case 'red':
        return BitmapDescriptor.hueRed;
      case 'yellow':
        return BitmapDescriptor.hueYellow;
      case 'green':
        return BitmapDescriptor.hueGreen;
      default:
        return BitmapDescriptor.hueBlue;
    }
  }

  void _showRegionInfo(RegionData region) {
    showModalBottomSheet(
      context: context,
      builder: (context) => _RegionInfoSheet(region: region),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Uturere tw\'ikawa (Coffee Regions)'),
        backgroundColor: AppTheme.coffeeBrown,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadRegions,
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: LatLng(-2.9, 29.8), // Center of Burundi
              zoom: 8,
            ),
            markers: _markers,
            onMapCreated: (controller) {
              // Map controller ready
            },
          ),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(
                color: AppTheme.coffeeBrown,
              ),
            ),
          if (_error != null)
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Card(
                color: Colors.red[100],
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      const Icon(Icons.error, color: Colors.red),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Ikibazo: $_error',
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                      TextButton(
                        onPressed: _loadRegions,
                        child: const Text('Ongera'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _RegionInfoSheet extends StatelessWidget {
  final RegionData region;

  const _RegionInfoSheet({required this.region});

  Color _getAlertColor(String alertLevel) {
    switch (alertLevel) {
      case 'red':
        return AppTheme.alertRed;
      case 'yellow':
        return AppTheme.alertYellow;
      case 'green':
        return AppTheme.coffeeGreen;
      default:
        return Colors.grey;
    }
  }

  String _getAlertText(String alertLevel) {
    switch (alertLevel) {
      case 'red':
        return 'BIKOMEYE';
      case 'yellow':
        return 'REBA';
      case 'green':
        return 'BYIZA';
      default:
        return 'NTIBIZWI';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                region.name,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getAlertColor(region.alertLevel),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _getAlertText(region.alertLevel),
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _InfoRow(
            label: 'Abahinzi (Farmers):',
            value: region.farmers.toString(),
            icon: Icons.people,
          ),
          const SizedBox(height: 8),
          _InfoRow(
            label: 'Igiciro (Price):',
            value: '${region.priceBif.toStringAsFixed(0)} BIF/kg',
            icon: Icons.attach_money,
          ),
          const SizedBox(height: 8),
          _InfoRow(
            label: 'Ikirere (Weather):',
            value: '${region.weather.temp.toStringAsFixed(1)}°C - ${region.weather.conditions}',
            icon: Icons.wb_sunny,
          ),
          const SizedBox(height: 8),
          _InfoRow(
            label: 'Coordinates:',
            value: '${region.lat.toStringAsFixed(4)}, ${region.lng.toStringAsFixed(4)}',
            icon: Icons.location_on,
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _InfoRow({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppTheme.coffeeBrown),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(color: Colors.grey),
          ),
        ),
      ],
    );
  }
}
