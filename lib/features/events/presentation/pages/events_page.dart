import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mapbox;
import 'package:table_calendar/table_calendar.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/constants.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/calendar_event.dart';
import '../cubit/events_cubit.dart';
import '../cubit/events_state.dart';

class EventsPage extends StatefulWidget {
  const EventsPage({super.key});

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  final TextEditingController _searchController = TextEditingController();
  EventsLoaded? _latestLoadedState;
  mapbox.MapboxMap? _mapboxMap;
  mapbox.PointAnnotationManager? _pointAnnotationManager;

  static const List<double> _defaultCoordinates = [39.0997, -94.5786];
  static const Map<String, List<double>> _fallbackLocationCoordinates = {
    'new york': [40.7128, -74.0060],
    'los angeles': [34.0522, -118.2437],
    'chicago': [41.8781, -87.6298],
    'seattle': [47.6062, -122.3321],
    'houston': [29.7604, -95.3698],
    'miami': [25.7617, -80.1918],
    'atlanta': [33.7490, -84.3880],
    'dallas': [32.7767, -96.7970],
    'las vegas': [36.1699, -115.1398],
    'orlando': [28.5384, -81.3789],
  };

  @override
  void initState() {
    super.initState();
    // Load events when page initializes
    context.read<EventsCubit>().loadEvents();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _pointAnnotationManager = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: BlocBuilder<EventsCubit, EventsState>(
          builder: (context, state) {
            if (state is EventsLoading) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Color(0xFF8BC342)),
                    SizedBox(height: 16),
                    Text('Loading events...'),
                  ],
                ),
              );
            }

            if (state is EventsError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Error',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        state.message,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<EventsCubit>().loadEvents();
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            if (state is EventsLoaded) {
              return _buildEventsContent(context, state);
            }

            return const Center(child: Text('No events data available'));
          },
        ),
      ),
    );
  }

  Widget _buildEventsContent(BuildContext context, EventsLoaded state) {
    final eventsCubit = context.read<EventsCubit>();
    final filteredEvents = eventsCubit.getFilteredEvents(state.selectedDate);

    _latestLoadedState = state;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _mapboxMap == null) return;
      _refreshMapAnnotations(state, filteredEvents);
    });

    return Container(
      color: Colors.white,
      height: double.infinity,
      child: Column(
        children: [
          // Custom Header (Fixed at top)
          _buildHeader(),

          // Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                children: [
                  SizedBox(height: 16.h),

                  // Search and Filter Row
                  _buildSearchAndFilter(state),

                  if (state.events.isNotEmpty)
                    _buildMapSection(state, filteredEvents),

                  SizedBox(height: 24.h),

                  // Calendar
                  _buildCompactCalendar(state),

                  SizedBox(height: 24.h),

                  // Filter Tabs
                  _buildFigmaFilterTabs(state),

                  SizedBox(height: 16.h),

                  // Events List
                  filteredEvents.isEmpty
                      ? _buildEmptyState(state)
                      : Column(
                          children: [
                            for (int i = 0; i < filteredEvents.length; i++) ...[
                              _buildFigmaEventCard(filteredEvents[i]),
                              if (i < filteredEvents.length - 1)
                                SizedBox(height: 16.h),
                            ],
                          ],
                        ),
                  SizedBox(height: 32.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getFormattedMonth(DateTime date) {
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  Widget _buildCompactCalendar(EventsLoaded state) {
    _selectedDay = state.selectedDate;
    _focusedDay = state.currentDate;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Color(0x3F000000),
            blurRadius: 30,
            offset: Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(AppSpacing.lg),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.gray100)),
            ),

            child: Row(
              children: [
                Icon(
                  Icons.calendar_month_rounded,
                  color: AppColors.primaryLimeGreen,
                  size: 24,
                ),
                SizedBox(width: AppSpacing.sm),
                Text(
                  _getFormattedMonth(_focusedDay),
                  style: AppTextStyles.titleLarge.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.gray900,
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    _buildCalendarNavButton(Icons.chevron_left_rounded, () {
                      final newDate = DateTime(
                        _focusedDay.year,
                        _focusedDay.month - 1,
                        1,
                      );
                      setState(() => _focusedDay = newDate);
                      context.read<EventsCubit>().setCurrentDate(newDate);
                    }),
                    SizedBox(width: AppSpacing.sm),
                    _buildCalendarNavButton(Icons.chevron_right_rounded, () {
                      final newDate = DateTime(
                        _focusedDay.year,
                        _focusedDay.month + 1,
                        1,
                      );
                      setState(() => _focusedDay = newDate);
                      context.read<EventsCubit>().setCurrentDate(newDate);
                    }),
                  ],
                ),
              ],
            ),
          ),

          // Calendar
          Padding(
            padding: EdgeInsets.all(AppSpacing.md),
            child: TableCalendar<CalendarEvent>(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2035, 12, 31),
              focusedDay: _focusedDay,
              calendarFormat: CalendarFormat.month,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
                context.read<EventsCubit>().selectDate(selectedDay);
              },
              onPageChanged: (focusedDay) {
                setState(() => _focusedDay = focusedDay);
                context.read<EventsCubit>().setCurrentDate(focusedDay);
              },
              eventLoader: (day) =>
                  context.read<EventsCubit>().getEventsForDate(day),
              headerVisible: false,
              daysOfWeekHeight: 40,
              rowHeight: 48,
              daysOfWeekStyle: DaysOfWeekStyle(
                weekdayStyle: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.gray600,
                  fontWeight: FontWeight.w600,
                ),
                weekendStyle: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.gray400,
                  fontWeight: FontWeight.w600,
                ),
              ),
              calendarStyle: CalendarStyle(
                outsideDaysVisible: false,
                weekendTextStyle: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.gray400,
                ),
                defaultTextStyle: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.gray700,
                ),
                todayDecoration: BoxDecoration(
                  color: AppColors.primaryLimeGreen.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                todayTextStyle: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.primaryLimeGreen,
                  fontWeight: FontWeight.w600,
                ),
                selectedDecoration: const BoxDecoration(
                  color: AppColors.primaryLimeGreen,
                  shape: BoxShape.circle,
                ),
                selectedTextStyle: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.w600,
                ),
                markerDecoration: const BoxDecoration(
                  color: AppColors.error,
                  shape: BoxShape.circle,
                ),
                markersMaxCount: 3,
                canMarkersOverflow: false,
                markerMargin: const EdgeInsets.symmetric(horizontal: 1),
                markerSize: 6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarNavButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: ShapeDecoration(
          color: const Color(0xFFF4F9ED) /* Lime-Green-100 */,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
        ),
        child: Icon(icon, size: 18, color: AppColors.gray600),
      ),
    );
  }

  Widget _buildEmptyState(EventsLoaded state) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.gray100,
                borderRadius: BorderRadius.circular(40),
              ),
              child: Icon(
                Icons.event_busy_rounded,
                size: 40,
                color: AppColors.gray400,
              ),
            ),
            SizedBox(height: AppSpacing.lg),
            Text(
              state.selectedDate != null
                  ? 'No events on this date'
                  : state.searchTerm.isNotEmpty || state.filterType != null
                  ? 'No events match your filters'
                  : 'No events available',
              style: AppTextStyles.titleMedium.copyWith(
                color: AppColors.gray700,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              state.selectedDate != null
                  ? 'Try selecting a different date'
                  : 'Check back later for new events',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.gray500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 56.h,
      width: 375.w,
      padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 8.h),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Events',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                fontSize: 20.sp,
                color: const Color(0xFF111B05),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter(EventsLoaded state) {
    final eventsCubit = context.read<EventsCubit>();
    final suggestions = state.searchTerm.isEmpty
        ? const <String>[]
        : eventsCubit.getSearchSuggestions(state.searchTerm);

    if (_searchController.text != state.searchTerm) {
      _searchController.value = TextEditingValue(
        text: state.searchTerm,
        selection: TextSelection.collapsed(offset: state.searchTerm.length),
      );
    }

    final hintText = state.searchMode == EventSearchMode.eventName
        ? 'Search events by name'
        : 'Search events by location';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  // For location search, just update the search term
                  // Geocoding happens when user selects a suggestion
                  eventsCubit.updateSearch(value);
                },
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12.sp,
                  color: Colors.black,
                ),
                decoration: InputDecoration(
                  hintText: hintText,
                  hintStyle: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12.sp,
                    color: const Color(0xFFA0A49B),
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    size: 24.sp,
                    color: const Color(0xFFA0A49B),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                    borderSide: const BorderSide(color: Color(0xFFE8E9E6)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                    borderSide: const BorderSide(color: Color(0xFFE8E9E6)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                    borderSide: const BorderSide(color: Color(0xFF8BC342)),
                  ),
                  contentPadding: EdgeInsets.symmetric(vertical: 16.h),
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Container(
              height: 48.h,
              width: 48.w,
              decoration: BoxDecoration(
                color: const Color(0xFF8BC342),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: PopupMenuButton<Object?>(
                tooltip: 'Search & filter',
                onSelected: (value) {
                  if (value is EventSearchMode) {
                    eventsCubit.updateSearchMode(value);
                    _searchController.clear();
                    FocusScope.of(context).unfocus();
                  } else if (value == null) {
                    eventsCubit.clearFilter();
                  } else if (value is EventType) {
                    eventsCubit.updateFilter(value);
                  }
                },
                itemBuilder: (context) {
                  return [
                    PopupMenuItem<Object?>(
                      enabled: false,
                      child: Text(
                        'Search mode',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.gray500,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    PopupMenuItem<Object?>(
                      value: EventSearchMode.eventName,
                      child: _buildPopupOption(
                        label: 'Event name',
                        selected: state.searchMode == EventSearchMode.eventName,
                        icon: Icons.event,
                      ),
                    ),
                    PopupMenuItem<Object?>(
                      value: EventSearchMode.location,
                      child: _buildPopupOption(
                        label: 'Location',
                        selected: state.searchMode == EventSearchMode.location,
                        icon: Icons.location_on,
                      ),
                    ),
                    const PopupMenuDivider(),
                    PopupMenuItem<Object?>(
                      enabled: false,
                      child: Text(
                        'Event type',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.gray500,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    PopupMenuItem<Object?>(
                      value: null,
                      child: _buildPopupOption(
                        label: 'All types',
                        selected: state.filterType == null,
                        icon: Icons.all_inclusive,
                      ),
                    ),
                    ...EventType.values.map(
                      (t) => PopupMenuItem<Object?>(
                        value: t,
                        child: _buildPopupOption(
                          label: _getEventTypeLabel(t),
                          selected: state.filterType == t,
                          icon: Icons.emoji_events,
                        ),
                      ),
                    ),
                  ];
                },
                child: Icon(Icons.tune, size: 24.sp, color: Colors.white),
              ),
            ),
          ],
        ),
        if (state.searchTerm.isNotEmpty && suggestions.isNotEmpty)
          Container(
            margin: EdgeInsets.only(top: 8.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: suggestions
                  .map(
                    (suggestion) => ListTile(
                      dense: true,
                      visualDensity: VisualDensity.compact,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 4.h,
                      ),
                      leading: Icon(
                        state.searchMode == EventSearchMode.location
                            ? Icons.location_on
                            : Icons.event,
                        color: AppColors.primaryLimeGreen,
                      ),
                      title: Text(
                        suggestion,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.gray800,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      onTap: () => _onSuggestionSelected(suggestion),
                    ),
                  )
                  .toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildPopupOption({
    required String label,
    required bool selected,
    IconData? icon,
  }) {
    return Row(
      children: [
        Icon(
          Icons.check,
          size: 16.sp,
          color: selected ? AppColors.primaryLimeGreen : Colors.transparent,
        ),
        SizedBox(width: 8.w),
        if (icon != null) ...[
          Icon(icon, size: 16.sp, color: AppColors.gray600),
          SizedBox(width: 8.w),
        ],
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: selected ? AppColors.primaryLimeGreen : AppColors.gray700,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  void _onSuggestionSelected(String suggestion) async {
    final eventsCubit = context.read<EventsCubit>();
    final currentState = eventsCubit.state;

    // If in location mode, geocode the selected location
    if (currentState is EventsLoaded &&
        currentState.searchMode == EventSearchMode.location) {
      // Try to geocode the location to get coordinates
      final coordinates = await _geocodeLocation(suggestion);

      if (coordinates != null) {
        eventsCubit.updateSearch(
          suggestion,
          lat: coordinates['lat'],
          lng: coordinates['lng'],
        );
      } else {
        // Fallback: just use text search without coordinates
        eventsCubit.updateSearch(suggestion);
      }
    } else {
      // Event name search - no geocoding needed
      eventsCubit.updateSearch(suggestion);
    }

    _searchController.value = TextEditingValue(
      text: suggestion,
      selection: TextSelection.collapsed(offset: suggestion.length),
    );
    FocusScope.of(context).unfocus();

    if (currentState is EventsLoaded) {
      final filteredEvents = eventsCubit.getFilteredEvents(
        currentState.selectedDate,
      );
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _refreshMapAnnotations(currentState, filteredEvents);
      });
    }
  }

  Future<Map<String, double>?> _geocodeLocation(String locationName) async {
    if (!_hasValidMapboxToken) return null;

    try {
      final String url =
          'https://api.mapbox.com/geocoding/v5/mapbox.places/${Uri.encodeComponent(locationName)}.json'
          '?access_token=${AppConstants.mapboxAccessToken}'
          '&limit=1'
          '&types=address,poi,place';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> features = data['features'] ?? [];

        if (features.isNotEmpty) {
          final feature = features[0];
          final List<double> coordinates = List<double>.from(
            feature['center'] ?? [0.0, 0.0],
          );

          if (coordinates.length >= 2) {
            return {'lng': coordinates[0], 'lat': coordinates[1]};
          }
        }
      }
    } catch (e) {
      debugPrint('Geocoding error: $e');
    }

    return null;
  }

  Widget _buildMapSection(
    EventsLoaded state,
    List<CalendarEvent> filteredEvents,
  ) {
    final eventsToDisplay = filteredEvents.isNotEmpty
        ? filteredEvents
        : state.events;

    if (eventsToDisplay.isEmpty) {
      return const SizedBox.shrink();
    }

    final initialPoint = _resolveLocationToPoint(
      eventsToDisplay.first.location,
    );
    final hasValidToken = _hasValidMapboxToken;

    return Container(
      margin: EdgeInsets.only(top: 16.h),
      width: double.infinity,
      height: 220.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: hasValidToken
            ? mapbox.MapWidget(
                key: const ValueKey('events-map-widget'),
                styleUri: mapbox.MapboxStyles.MAPBOX_STREETS,
                cameraOptions: mapbox.CameraOptions(
                  center: initialPoint,
                  zoom: 9,
                ),
                onMapCreated: _onMapCreated,
              )
            : _buildMapPlaceholder(),
      ),
    );
  }

  void _onMapCreated(mapbox.MapboxMap mapboxMap) {
    if (!_hasValidMapboxToken) {
      return;
    }
    _mapboxMap = mapboxMap;
    mapboxMap.annotations
        .createPointAnnotationManager()
        .then((manager) async {
          _pointAnnotationManager = manager;
          if (!mounted || _latestLoadedState == null) return;
          final eventsCubit = context.read<EventsCubit>();
          final filteredEvents = eventsCubit.getFilteredEvents(
            _latestLoadedState!.selectedDate,
          );
          await _refreshMapAnnotations(_latestLoadedState!, filteredEvents);
        })
        .catchError((error) {
          debugPrint('Failed to create annotation manager: $error');
        });
  }

  Future<void> _refreshMapAnnotations(
    EventsLoaded state,
    List<CalendarEvent> filteredEvents,
  ) async {
    final map = _mapboxMap;
    if (map == null || !_hasValidMapboxToken) return;

    _pointAnnotationManager ??= await map.annotations
        .createPointAnnotationManager();
    final manager = _pointAnnotationManager;
    if (manager == null) return;

    await manager.deleteAll();

    final eventsToDisplay = filteredEvents.isNotEmpty
        ? filteredEvents
        : state.events;
    if (eventsToDisplay.isEmpty) return;

    final annotations = eventsToDisplay.map((event) {
      final point = _resolveLocationToPoint(event.location);
      return mapbox.PointAnnotationOptions(
        geometry: point,
        iconImage: 'marker-15',
        iconSize: 1.2,
        textField: event.title,
        textOffset: const [0, 1.2],
        textColor: 0xFF212121,
      );
    }).toList();

    if (annotations.isNotEmpty) {
      await manager.createMulti(annotations);
      final firstPoint = _resolveLocationToPoint(
        eventsToDisplay.first.location,
      );
      await map.setCamera(mapbox.CameraOptions(center: firstPoint, zoom: 9));
    }
  }

  mapbox.Point _resolveLocationToPoint(String location) {
    final parsed = _tryParseExplicitCoordinates(location);
    if (parsed != null) {
      return parsed;
    }

    final normalized = location.toLowerCase();
    for (final entry in _fallbackLocationCoordinates.entries) {
      if (normalized.contains(entry.key)) {
        final coords = entry.value;
        return mapbox.Point(coordinates: mapbox.Position(coords[1], coords[0]));
      }
    }

    final coords = _defaultCoordinates;
    return mapbox.Point(coordinates: mapbox.Position(coords[1], coords[0]));
  }

  mapbox.Point? _tryParseExplicitCoordinates(String location) {
    final regex = RegExp(r'(-?\d{1,3}(?:\.\d+)?)\s*,\s*(-?\d{1,3}(?:\.\d+)?)');
    final match = regex.firstMatch(location);
    if (match == null) {
      return null;
    }

    final lat = double.tryParse(match.group(1)!);
    final lng = double.tryParse(match.group(2)!);
    if (lat == null || lng == null) {
      return null;
    }

    if (lat.abs() > 90 || lng.abs() > 180) {
      return null;
    }

    return mapbox.Point(coordinates: mapbox.Position(lng, lat));
  }

  Widget _buildMapPlaceholder() {
    return Container(
      color: AppColors.gray100,
      alignment: Alignment.center,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.map_outlined, size: 36.sp, color: AppColors.gray400),
            SizedBox(height: 12.h),
            Text(
              'Add your Mapbox access token to enable the interactive map.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.gray600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool get _hasValidMapboxToken =>
      AppConstants.mapboxAccessToken.isNotEmpty &&
      !AppConstants.mapboxAccessToken.contains('your_mapbox_access_token');

  Widget _buildFigmaFilterTabs(EventsLoaded state) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildFigmaFilterTab('All', true),
          SizedBox(width: 12.w),
          _buildFigmaFilterTab('Ongoing', false),
          SizedBox(width: 12.w),
          _buildFigmaFilterTab('Completed', false),
          SizedBox(width: 12.w),
          _buildFigmaFilterTab('Canceled', false),
        ],
      ),
    );
  }

  Widget _buildFigmaFilterTab(String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: isSelected
          ? ShapeDecoration(
              color: const Color(0xFF8BC342) /* Lime-Green-500 */,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(40),
              ),
            )
          : ShapeDecoration(
              shape: RoundedRectangleBorder(
                side: BorderSide(width: 2, color: const Color(0xFF696969)),
                borderRadius: BorderRadius.circular(40),
              ),
            ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 14.sp,
          color: isSelected ? const Color(0xFF101010) : Colors.grey,
        ),
      ),
    );
  }

  Widget _buildFigmaEventCard(CalendarEvent event) {
    final statusColor = _getStatusColor(event.status);
    final statusText = _getStatusLabel(event.status);

    return Container(
      width: 335.w,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFF0F0F0)),
      ),
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Column(
          children: [
            // Header Row
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      // Icon Container
                      Container(
                        width: 48.w,
                        height: 48.h,
                        decoration: BoxDecoration(
                          color: const Color(
                            0xFF3B82F6,
                          ).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(24.r),
                        ),
                        child: Icon(
                          Icons.emoji_events,
                          size: 24.sp,
                          color: const Color(0xFF3B82F6),
                        ),
                      ),

                      SizedBox(width: 8.w),

                      // Event Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              event.title,
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w600,
                                fontSize: 14.sp,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              _getEventTypeLabel(event.type),
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 12.sp,
                                color: const Color(0xFF7D7D7D),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Status Badge
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(25.r),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w500,
                      fontSize: 12.sp,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 12.h),

            // Divider
            Container(
              width: double.infinity,
              height: 1.h,
              color: const Color(0xFFE8E9E6),
            ),

            SizedBox(height: 12.h),

            // Details
            Column(
              children: [
                // Time Row
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 24.sp,
                      color: const Color(0xFF111B05),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        '${event.time} - ${event.endTime ?? event.time}',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w500,
                          fontSize: 14.sp,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 12.h),

                // Location Row
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 24.sp,
                      color: const Color(0xFF111B05),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        event.location,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w500,
                          fontSize: 14.sp,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 12.h),

                // Fee Row
                Row(
                  children: [
                    Icon(
                      Icons.attach_money,
                      size: 24.sp,
                      color: const Color(0xFF111B05),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        '\$${event.entryFee?.toStringAsFixed(0) ?? '0'} Entry Fee',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w500,
                          fontSize: 14.sp,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getEventTypeLabel(EventType type) {
    switch (type) {
      case EventType.tournament:
        return 'Tournaments';
      case EventType.league:
        return 'League Games';
      case EventType.special:
        return 'Special Events';
      case EventType.practice:
        return 'Practice Sessions';
      case EventType.maintenance:
        return 'Maintenance';
    }
  }

  String _getStatusLabel(EventStatus status) {
    switch (status) {
      case EventStatus.upcoming:
        return 'Upcoming';
      case EventStatus.ongoing:
        return 'Ongoing';
      case EventStatus.completed:
        return 'Completed';
      case EventStatus.cancelled:
        return 'Cancelled';
    }
  }

  Color _getStatusColor(EventStatus status) {
    switch (status) {
      case EventStatus.upcoming:
        return AppColors.info; // blue
      case EventStatus.ongoing:
        return AppColors.primaryLimeGreen; // brand
      case EventStatus.completed:
        return AppColors.success; // green
      case EventStatus.cancelled:
        return AppColors.error; // red
    }
  }
}
