import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;

/// Service để xử lý các chức năng liên quan đến vị trí
class LocationService {
  /// Kiểm tra và yêu cầu quyền truy cập vị trí
  static Future<bool> requestPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Kiểm tra xem dịch vụ vị trí có bật không
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Dịch vụ vị trí bị tắt, yêu cầu người dùng bật
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Quyền bị từ chối
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Quyền bị từ chối vĩnh viễn
      return false;
    }

    return true;
  }

  /// Lấy vị trí hiện tại của người dùng
  static Future<Position?> getCurrentLocation() async {
    try {
      final hasPermission = await requestPermission();
      if (!hasPermission) {
        return null;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      return position;
    } catch (e) {
      print('Error getting location: $e');
      return null;
    }
  }

  /// Reverse geocoding: tọa độ → địa chỉ
  static Future<String?> getAddressFromCoordinates(
      double lat,
      double lon,
      ) async {
    try {
      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse'
            '?format=json'
            '&lat=$lat'
            '&lon=$lon'
            '&zoom=18'
            '&addressdetails=1',
      );

      final response = await http
          .get(
        uri,
        headers: const {
          // BẮT BUỘC
          'User-Agent': 'ChatApp/1.0 (contact@yourapp.com)',
        },
      )
          .timeout(const Duration(seconds: 6));

      if (response.statusCode != 200) {
        debugPrint('OSM HTTP ${response.statusCode}');
        return null;
      }

      final data = jsonDecode(response.body);

      // Ưu tiên display_name
      if (data is Map && data['display_name'] != null) {
        return data['display_name'] as String;
      }

      // Fallback thủ công từ address
      final address = data['address'];
      if (address is Map) {
        final parts = <String>[];

        for (final key in [
          'road',
          'suburb',
          'city',
          'state',
          'country',
        ]) {
          if (address[key] != null) {
            parts.add(address[key]);
          }
        }

        if (parts.isNotEmpty) {
          return parts.join(', ');
        }
      }

      return null;
    } catch (e) {
      debugPrint('Reverse OSM error: $e');
      return null;
    }
  }

  /// Tính khoảng cách giữa hai điểm (đơn vị: mét)
  static double calculateDistance(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }

  /// Format khoảng cách thành chuỗi dễ đọc
  static String formatDistance(double distanceInMeters) {
    if (distanceInMeters < 1000) {
      return '${distanceInMeters.toStringAsFixed(0)} m';
    } else {
      final km = distanceInMeters / 1000;
      return '${km.toStringAsFixed(1)} km';
    }
  }
}
