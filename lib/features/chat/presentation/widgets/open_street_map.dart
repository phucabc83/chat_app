import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:latlong2/latlong.dart';

class OpenStreetMap extends StatefulWidget {
  final LatLng initialPosition;
  final Function(LatLng) onPositionChanged;

  const OpenStreetMap({
    super.key,
    required this.initialPosition,
    required this.onPositionChanged,
  });

  @override
  State<OpenStreetMap> createState() => _OpenStreetMapState();
}

class _OpenStreetMapState extends State<OpenStreetMap> {
  late final MapController _mapController;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: widget.initialPosition,
        initialZoom: 16,
        onMapEvent: (event) {
          if (event is MapEventMoveEnd) {
            final center = event.camera.center;
            widget.onPositionChanged(center);
          }
        },
      ),

      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          tileProvider: CancellableNetworkTileProvider(),
        )
      ],
    );
  }




}
