import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../../core/constants/colors.dart';
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

  @override
  void initState() {
    super.initState();
    // Load events when page initializes
    context.read<EventsCubit>().loadEvents();
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
    final filteredEvents = context.read<EventsCubit>().getFilteredEvents(
      state.selectedDate,
    );

    return Container(
      color: Colors.white,
      child: Column(
        children: [
          // Custom Header
          _buildHeader(),

          // Content
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                children: [
                  SizedBox(height: 16.h),

                  // Search and Filter Row
                  _buildSearchAndFilter(state),

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
                      : ListView.separated(
                          shrinkWrap: true,
                          itemCount: filteredEvents.length,
                          separatorBuilder: (_, __) => SizedBox(height: 16.h),
                          itemBuilder: (context, index) =>
                              _buildFigmaEventCard(filteredEvents[index]),
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
    return Row(
      children: [
        // Search Field
        Expanded(
          child: TextField(
            onChanged: (v) => context.read<EventsCubit>().updateSearch(v),
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12.sp,
              color: Colors.black,
            ),
            decoration: InputDecoration(
              hintText: 'Search Events',
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

        // Filter Button
        Container(
          height: 48.h,
          width: 48.w,
          decoration: BoxDecoration(
            color: const Color(0xFF8BC342),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: PopupMenuButton<EventType?>(
            initialValue: state.filterType,
            onSelected: (val) => context.read<EventsCubit>().updateFilter(val),
            itemBuilder: (context) => <PopupMenuEntry<EventType?>>[
              const PopupMenuItem<EventType?>(
                value: null,
                child: Text('All types'),
              ),
              ...EventType.values.map(
                (t) => PopupMenuItem<EventType?>(
                  value: t,
                  child: Text(_getEventTypeLabel(t)),
                ),
              ),
            ],
            child: Icon(Icons.tune, size: 24.sp, color: Colors.white),
          ),
        ),
      ],
    );
  }

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
