import 'dart:async';
import 'dart:convert';

import 'package:chat_app/features/chat/presentation/widgets/open_street_map.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

import '../../../../services/location_service.dart';

/// Widget để chọn vị trí từ bản đồ (tích hợp với Google Maps hoặc OpenStreetMap)
class LocationPickerScreen extends StatefulWidget {
  final double? initialLatitude;
  final double? initialLongitude;

  const LocationPickerScreen({
    super.key,
    this.initialLatitude,
    this.initialLongitude,
  });

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  double? selectedLatitude;
  double? selectedLongitude;
  String? selectedAddress;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    selectedLatitude = widget.initialLatitude ?? 10.944512; // tphcm default
    selectedLongitude = widget.initialLongitude ?? 106.725376;
  }

  void _confirmLocation() {
    if (selectedLatitude != null && selectedLongitude != null) {
      Navigator.pop(context, {
        'latitude': selectedLatitude,
        'longitude': selectedLongitude,
        'address': selectedAddress,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E2C),
      body: SafeArea(
        child: Stack(
          children: [
            // Map placeholder (integrate with google_maps_flutter or flutter_map)
            Container(
              decoration: BoxDecoration(color: Colors.grey.shade200),
              child: OpenStreetMap(
                initialPosition: LatLng(selectedLatitude!, selectedLongitude!),

                onPositionChanged:  (LatLng latLng) {
                  onPositionChangedLatLng(latLng);
                },
              ),
            ),

            // Center pin marker
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withOpacity(0.5),
                          blurRadius: 12,
                          spreadRadius: 3,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.location_on,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 60),
                ],
              ),
            ),

            // Top bar with back button and title
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.black),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom card with location info and confirm button
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF2C2F3E),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Handle bar
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Location info
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.location_on,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                selectedAddress ??
                                    'Di chuyển bản đồ để chọn vị trí',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              if (selectedLatitude != null &&
                                  selectedLongitude != null)
                                Text(
                                  '${selectedLatitude!.toStringAsFixed(6)}, ${selectedLongitude!.toStringAsFixed(6)}',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white.withOpacity(0.6),
                                    fontSize: 12,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Confirm button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _confirmLocation,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Ink(
                          decoration: BoxDecoration(
                            color: Colors.redAccent,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.check_circle,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Xác nhận vị trí',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  void onPositionChangedLatLng(LatLng latLng) {
    debugPrint('Map stopped at $latLng');

    setState(() {
      selectedLatitude = latLng.latitude;
      selectedLongitude = latLng.longitude;
    });

    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 600), () async {
      final lat = selectedLatitude;
      final lng = selectedLongitude;

      if (lat == null || lng == null) return;

      try {
        final address = await LocationService.getAddressFromCoordinates(
          latLng.latitude,
          latLng.longitude,
        );


        if (!mounted) return;

        setState(() {
          selectedAddress = address ?? '$lat, $lng';
        });
      } catch (e) {
        debugPrint('Reverse geocoding failed: $e');
      }
    });
  }



  // write function reverse geocode
}
