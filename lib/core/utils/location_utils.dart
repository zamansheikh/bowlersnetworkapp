import 'dart:math';

/// Utility functions for location-based operations
class LocationUtils {
  /// Calculate distance between two coordinates using Haversine formula
  /// Returns distance in miles
  static double calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadiusMiles = 3959; // Earth's radius in miles

    // Convert latitude and longitude from degrees to radians
    final lat1Rad = _degreesToRadians(lat1);
    final lon1Rad = _degreesToRadians(lon1);
    final lat2Rad = _degreesToRadians(lat2);
    final lon2Rad = _degreesToRadians(lon2);

    // Calculate differences
    final deltaLat = lat2Rad - lat1Rad;
    final deltaLon = lon2Rad - lon1Rad;

    // Haversine formula
    final a =
        pow(sin(deltaLat / 2), 2) +
        cos(lat1Rad) * cos(lat2Rad) * pow(sin(deltaLon / 2), 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadiusMiles * c;
  }

  /// Convert degrees to radians
  static double _degreesToRadians(double degrees) {
    return degrees * (pi / 180);
  }

  /// Format distance for display
  static String formatDistance(double miles) {
    if (miles < 1) {
      return '${(miles * 5280).toInt()} ft';
    } else if (miles < 10) {
      return '${miles.toStringAsFixed(1)} mi';
    } else {
      return '${miles.round()} mi';
    }
  }

  /// Check if a location is within a certain radius
  static bool isWithinRadius(
    double centerLat,
    double centerLon,
    double targetLat,
    double targetLon,
    double radiusMiles,
  ) {
    final distance = calculateDistance(
      centerLat,
      centerLon,
      targetLat,
      targetLon,
    );
    return distance <= radiusMiles;
  }
}
