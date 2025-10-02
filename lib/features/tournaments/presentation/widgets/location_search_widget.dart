import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/constants.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_spacing.dart';

class LocationSearchWidget extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final Function(double lat, double lng, String locationName)
  onLocationSelected;
  final Function() onClearLocation;
  final bool showDistanceFilter;

  const LocationSearchWidget({
    super.key,
    required this.controller,
    required this.hintText,
    required this.onLocationSelected,
    required this.onClearLocation,
    this.showDistanceFilter = false,
  });

  @override
  State<LocationSearchWidget> createState() => _LocationSearchWidgetState();
}

class _LocationSearchWidgetState extends State<LocationSearchWidget> {
  Timer? _debounceTimer;
  bool _showSuggestions = false;
  bool _isSearching = false;
  List<Map<String, dynamic>> _locationSuggestions = [];
  final FocusNode _focusNode = FocusNode();

  // Mapbox token from constants
  static final String _mapboxToken = AppConstants.mapboxAccessToken;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _focusNode.dispose();
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    final query = widget.controller.text;

    if (query.isEmpty) {
      setState(() {
        _showSuggestions = false;
        _locationSuggestions.clear();
        _isSearching = false;
      });
      _debounceTimer?.cancel();
      return;
    }

    // Cancel previous timer
    _debounceTimer?.cancel();

    // Show loading state immediately
    setState(() {
      _showSuggestions = true;
      _isSearching = true;
    });

    // Debounce the search to avoid too many API calls
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _searchLocations(query);
    });
  }

  Future<void> _searchLocations(String query) async {
    if (query.trim().isEmpty) return;

    try {
      setState(() {
        _isSearching = true;
      });

      // Mapbox Geocoding API endpoint
      final String url =
          'https://api.mapbox.com/geocoding/v5/mapbox.places/${Uri.encodeComponent(query)}.json'
          '?access_token=$_mapboxToken'
          '&limit=5'
          '&types=address,poi,place';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> features = data['features'] ?? [];

        setState(() {
          _locationSuggestions = features.map((feature) {
            final List<double> coordinates = List<double>.from(
              feature['center'] ?? [0.0, 0.0],
            );
            return {
              'place_name': feature['place_name'] ?? '',
              'lat': coordinates.length > 1 ? coordinates[1] : 0.0,
              'lng': coordinates.isNotEmpty ? coordinates[0] : 0.0,
            };
          }).toList();
          _isSearching = false;
        });
      } else {
        setState(() {
          _locationSuggestions.clear();
          _isSearching = false;
        });
        debugPrint('Mapbox API error: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _locationSuggestions.clear();
        _isSearching = false;
      });
      debugPrint('Location search error: $e');
    }
  }

  void _selectLocation(Map<String, dynamic> location) {
    final placeName = location['place_name'] as String;
    final lat = location['lat'] as double;
    final lng = location['lng'] as double;

    widget.controller.text = placeName;
    widget.onLocationSelected(lat, lng, placeName);

    setState(() {
      _showSuggestions = false;
      _locationSuggestions.clear();
    });

    _focusNode.unfocus();
  }

  void _clearLocation() {
    widget.controller.clear();
    widget.onClearLocation();
    setState(() {
      _showSuggestions = false;
      _locationSuggestions.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: widget.controller,
          focusNode: _focusNode,
          style: AppTextStyles.bodyMedium,
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.gray500,
            ),
            prefixIcon: const Icon(Icons.location_on, color: AppColors.gray500),
            suffixIcon: widget.controller.text.isNotEmpty
                ? IconButton(
                    onPressed: _clearLocation,
                    icon: const Icon(
                      Icons.clear,
                      color: AppColors.gray500,
                      size: 20,
                    ),
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.gray300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.gray300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primaryLimeGreen),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
          ),
        ),

        // Location suggestions dropdown
        if (_showSuggestions)
          Container(
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.gray300),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: _isSearching
                ? SizedBox(
                    height: 60,
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.primaryLimeGreen,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Searching locations...',
                            style: AppTextStyles.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  )
                : _locationSuggestions.isEmpty
                ? SizedBox(
                    height: 60,
                    child: Center(
                      child: Text(
                        'No locations found',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.gray500,
                        ),
                      ),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _locationSuggestions.length,
                    itemBuilder: (context, index) {
                      final location = _locationSuggestions[index];
                      return ListTile(
                        dense: true,
                        leading: const Icon(
                          Icons.location_on,
                          color: AppColors.gray500,
                          size: 16,
                        ),
                        title: Text(
                          location['place_name'],
                          style: AppTextStyles.bodySmall,
                        ),
                        subtitle: widget.showDistanceFilter
                            ? Text(
                                'Within 10 miles',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.primaryLimeGreen,
                                  fontSize: 11,
                                ),
                              )
                            : null,
                        onTap: () => _selectLocation(location),
                      );
                    },
                  ),
          ),
      ],
    );
  }
}
