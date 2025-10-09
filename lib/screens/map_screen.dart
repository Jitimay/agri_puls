import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../data/models.dart';
import '../data/mock_service.dart';
import '../theme/app_theme.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _controller;
  final MockDataService _dataService = MockDataService();
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _createMarkers();
  }

  void _createMarkers() {
    final regions = _dataService.getRegions();
    _markers = regions.map((region) => Marker(
      markerId: MarkerId(region.name),
      position: LatLng(region.lat, region.lng),
      onTap: () => _showRegionInfo(region),
      icon: BitmapDescriptor.defaultMarkerWithHue(_getMarkerColor(region.status)),
    )).toSet();
  }

  double _getMarkerColor(AlertPriority status) {
    switch (status) {
      case AlertPriority.critical:
        return BitmapDescriptor.hueRed;
      case AlertPriority.warning:
        return BitmapDescriptor.hueYellow;
      case AlertPriority.info:
        return BitmapDescriptor.hueGreen;
    }
  }

  void _showRegionInfo(Region region) {
    showModalBottomSheet(
      context: context,
      builder: (context) => _RegionInfoSheet(region: region),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Coffee Regions')),
      body: GoogleMap(
        initialCameraPosition: const CameraPosition(
          target: LatLng(-2.9, 29.8),
          zoom: 8,
        ),
        markers: _markers,
        onMapCreated: (controller) => _controller = controller,
      ),
    );
  }
}

class _RegionInfoSheet extends StatelessWidget {
  final Region region;

  const _RegionInfoSheet({required this.region});

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
                  color: AppTheme.getAlertColor(region.status),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  region.status.name.toUpperCase(),
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text('Current Weather:', style: TextStyle(fontWeight: FontWeight.bold)),
          const Text('25°C - Partly Cloudy'),
          const SizedBox(height: 12),
          const Text('Active Alerts:', style: TextStyle(fontWeight: FontWeight.bold)),
          const Text('• Heavy rain expected tomorrow'),
          const Text('• Coffee rust detected in 3 farms'),
        ],
      ),
    );
  }
}
