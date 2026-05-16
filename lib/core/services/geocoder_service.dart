import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

/// Result of a geocode lookup. The address editor on the profile screen
/// hands these back to the user as autocomplete suggestions.
class GeocodeSuggestion {
  const GeocodeSuggestion({
    required this.displayName,
    required this.latitude,
    required this.longitude,
    this.zipCode = '',
  });

  /// Human-readable label — what the user sees in the suggestion list.
  final String displayName;
  final double latitude;
  final double longitude;
  final String zipCode;
}

/// Address → lat/lng + zip lookup, used by the edit-profile address
/// editor. Backed by Nominatim (OpenStreetMap) — free, no API key.
///
/// Nominatim's usage policy requires a descriptive `User-Agent`, a max
/// of 1 req/sec, and no heavy automated traffic. The callers (the
/// edit-profile sheet) debounce typing, so we stay well under the rate.
@lazySingleton
class GeocoderService {
  GeocoderService() : _dio = _buildClient();

  final Dio _dio;

  static Dio _buildClient() {
    return Dio(BaseOptions(
      baseUrl: 'https://nominatim.openstreetmap.org',
      headers: {
        // Per Nominatim ToS — identify the app + contact.
        'User-Agent': 'BowlersNetworkApp/1.0 (support@bowlersnetwork.com)',
      },
      sendTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ));
  }

  /// Search for [query] and return up to [limit] matching addresses.
  /// Empty / short queries (<3 chars) return an empty list without a
  /// network call.
  Future<List<GeocodeSuggestion>> search(
    String query, {
    int limit = 5,
  }) async {
    final q = query.trim();
    if (q.length < 3) return const [];
    try {
      final res = await _dio.get<List<dynamic>>(
        '/search',
        queryParameters: {
          'q': q,
          'format': 'json',
          'addressdetails': 1,
          'limit': limit,
        },
      );
      final data = res.data ?? const [];
      return data
          .whereType<Map<String, dynamic>>()
          .map(_parse)
          .whereType<GeocodeSuggestion>()
          .toList(growable: false);
    } on DioException {
      return const [];
    } catch (_) {
      return const [];
    }
  }

  GeocodeSuggestion? _parse(Map<String, dynamic> json) {
    final display = json['display_name'];
    final lat = double.tryParse('${json['lat']}');
    final lon = double.tryParse('${json['lon']}');
    if (display is! String || lat == null || lon == null) return null;
    final addr = json['address'];
    final zip = (addr is Map && addr['postcode'] is String)
        ? addr['postcode'] as String
        : '';
    return GeocodeSuggestion(
      displayName: display,
      latitude: lat,
      longitude: lon,
      zipCode: zip,
    );
  }
}
