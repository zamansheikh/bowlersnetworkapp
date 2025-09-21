import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/calendar_event.dart';
import '../cubit/events_cubit.dart';
import '../cubit/events_state.dart';

class EventsPage extends StatefulWidget {
  const EventsPage({Key? key}) : super(key: key);

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
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
      backgroundColor: AppColors.gray50,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.gray900,
        leading: Container(
          margin: EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: AppColors.gray50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.gray200),
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded),
            onPressed: () => Navigator.of(context).pop(),
            color: AppColors.gray700,
            iconSize: 18,
          ),
        ),
        title: Text(
          'Events',
          style: AppTextStyles.headlineMedium.copyWith(
            color: AppColors.gray900,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          Container(
            margin: EdgeInsets.only(right: AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.primaryLimeGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.refresh_rounded),
              onPressed: () => context.read<EventsCubit>().loadEvents(),
              color: AppColors.primaryLimeGreen,
            ),
          ),
        ],
      ),
      body: BlocBuilder<EventsCubit, EventsState>(
        builder: (context, state) {
          if (state is EventsLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppColors.primaryLimeGreen),
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
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text(
                    'Error',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
    );
  }

  Widget _buildEventsContent(BuildContext context, EventsLoaded state) {
    final filteredEvents = context.read<EventsCubit>().getFilteredEvents(
      state.selectedDate,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        // Mobile layout (single column)
        if (constraints.maxWidth < 800) {
          return _buildMobileLayout(context, state, filteredEvents);
        }
        // Desktop/tablet layout (two columns)
        else {
          return _buildDesktopLayout(context, state, filteredEvents);
        }
      },
    );
  }

  Widget _buildMobileLayout(
    BuildContext context,
    EventsLoaded state,
    List<CalendarEvent> filteredEvents,
  ) {
    return CustomScrollView(
      slivers: [
        // Search and Filter Section
        SliverToBoxAdapter(
          child: Container(
            color: AppColors.white,
            padding: EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.lg,
              AppSpacing.lg,
            ),
            child: _buildSearchAndFilters(state),
          ),
        ),

        // Calendar Section
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: _buildCompactCalendar(state),
          ),
        ),

        SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),

        // Events List Header
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Row(
              children: [
                Icon(
                  Icons.event_note_rounded,
                  size: 24,
                  color: AppColors.primaryLimeGreen,
                ),
                SizedBox(width: AppSpacing.sm),
                Text(
                  state.selectedDate != null
                      ? 'Events on ${_formatSelectedDate(state.selectedDate!)}'
                      : 'All Events',
                  style: AppTextStyles.titleLarge.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.gray900,
                  ),
                ),
                const Spacer(),
                if (filteredEvents.isNotEmpty)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLimeGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '${filteredEvents.length}',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.primaryLimeGreen,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),

        SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),

        // Events List
        filteredEvents.isEmpty
            ? SliverToBoxAdapter(child: _buildEmptyState(state))
            : SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final event = filteredEvents[index];
                  return Padding(
                    padding: EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      AppSpacing.xs,
                      AppSpacing.lg,
                      AppSpacing.xs,
                    ),
                    child: _buildModernEventCard(event),
                  );
                }, childCount: filteredEvents.length),
              ),

        // Bottom padding
        SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xxl)),
      ],
    );
  }

  Widget _buildDesktopLayout(
    BuildContext context,
    EventsLoaded state,
    List<CalendarEvent> filteredEvents,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left: Calendar + Stats
        Expanded(
          flex: 2,
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.lg),
            child: Column(
              children: [
                _buildCompactCalendar(state),
                SizedBox(height: AppSpacing.lg),
                _buildEventTypesLegend(state),
                SizedBox(height: AppSpacing.lg),
                _buildMonthlyStats(context, state),
              ],
            ),
          ),
        ),

        // Right: Search + Events List
        Expanded(
          flex: 3,
          child: Container(
            height: MediaQuery.of(context).size.height,
            color: AppColors.white,
            child: Column(
              children: [
                // Search and filters
                Container(
                  padding: EdgeInsets.all(AppSpacing.lg),
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: AppColors.gray200),
                    ),
                  ),
                  child: _buildSearchAndFilters(state),
                ),

                // Events list
                Expanded(
                  child: filteredEvents.isEmpty
                      ? _buildEmptyState(state)
                      : ListView.separated(
                          padding: EdgeInsets.all(AppSpacing.lg),
                          itemCount: filteredEvents.length,
                          separatorBuilder: (_, __) =>
                              SizedBox(height: AppSpacing.md),
                          itemBuilder: (context, index) {
                            return _buildModernEventCard(filteredEvents[index]);
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEventTypesLegend(EventsLoaded state) {
    return Card(
      color: AppColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.legend_toggle_rounded,
                  color: AppColors.primaryLimeGreen,
                  size: 20,
                ),
                SizedBox(width: AppSpacing.sm),
                Text(
                  'Event Types',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.gray900,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.md),
            ...EventType.values.map((type) {
              final count = context.read<EventsCubit>().getEventCountByType(
                type,
                state.currentDate,
              );
              return Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.xs),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: _getEventTypeColor(type),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        _getEventTypeLabel(type),
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.gray700,
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.gray100,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '$count',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.gray700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlyStats(BuildContext context, EventsLoaded state) {
    final cubit = context.read<EventsCubit>();
    final totalEvents = cubit.getEventCountForMonth(state.currentDate);
    final tournaments = cubit.getEventCountByType(
      EventType.tournament,
      state.currentDate,
    );
    final leagues = cubit.getEventCountByType(
      EventType.league,
      state.currentDate,
    );
    final practice = cubit.getEventCountByType(
      EventType.practice,
      state.currentDate,
    );

    return Card(
      color: AppColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.bar_chart_rounded,
                  color: AppColors.primaryLimeGreen,
                  size: 20,
                ),
                SizedBox(width: AppSpacing.sm),
                Text(
                  'This Month',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.gray900,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.md),

            _buildStatRow(
              Icons.emoji_events_rounded,
              'Tournaments',
              tournaments,
              AppColors.error,
            ),
            SizedBox(height: AppSpacing.sm),
            _buildStatRow(
              Icons.groups_rounded,
              'League Games',
              leagues,
              AppColors.info,
            ),
            SizedBox(height: AppSpacing.sm),
            _buildStatRow(
              Icons.sports_rounded,
              'Practice Sessions',
              practice,
              AppColors.success,
            ),

            Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
              child: const Divider(color: AppColors.gray200),
            ),

            Container(
              padding: EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.primaryLimeGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Events',
                    style: AppTextStyles.titleSmall.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.gray900,
                    ),
                  ),
                  Text(
                    '$totalEvents',
                    style: AppTextStyles.headlineSmall.copyWith(
                      color: AppColors.primaryLimeGreen,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(IconData icon, String label, int count, Color color) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        SizedBox(width: AppSpacing.md),
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.gray700),
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: AppColors.gray100,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            '$count',
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.gray700,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  String _formatSelectedDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}';
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

  IconData _getEventTypeIcon(EventType type) {
    switch (type) {
      case EventType.tournament:
        return Icons.emoji_events_rounded;
      case EventType.league:
        return Icons.groups_rounded;
      case EventType.special:
        return Icons.star_rounded;
      case EventType.practice:
        return Icons.sports_rounded;
      case EventType.maintenance:
        return Icons.build_rounded;
    }
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
            color: AppColors.gray900.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
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
                  color: AppColors.primaryLimeGreen.withOpacity(0.2),
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
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.gray50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.gray200),
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

  Widget _buildModernEventCard(CalendarEvent event) {
    final statusColor = _getStatusColor(event.status);
    final typeColor = _getEventTypeColor(event.type);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gray100),
        boxShadow: [
          BoxShadow(
            color: AppColors.gray900.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            // TODO: Navigate to event details
          },
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Event icon
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: typeColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _getEventTypeIcon(event.type),
                        color: typeColor,
                        size: 24,
                      ),
                    ),

                    SizedBox(width: AppSpacing.md),

                    // Title and type
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            event.title,
                            style: AppTextStyles.titleMedium.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.gray900,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: AppSpacing.xs),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                              vertical: AppSpacing.xs,
                            ),
                            decoration: BoxDecoration(
                              color: typeColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              _getEventTypeLabel(event.type),
                              style: AppTextStyles.labelSmall.copyWith(
                                color: typeColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Status badge
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        _getStatusLabel(event.status),
                        style: AppTextStyles.labelSmall.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: AppSpacing.md),

                // Event details
                _buildEventDetailRow(
                  Icons.schedule_rounded,
                  event.endTime == null
                      ? '${event.time}'
                      : '${event.time} - ${event.endTime}',
                ),

                SizedBox(height: AppSpacing.sm),

                _buildEventDetailRow(Icons.location_on_rounded, event.location),

                if (event.participants > 0) ...[
                  SizedBox(height: AppSpacing.sm),
                  _buildEventDetailRow(
                    Icons.people_rounded,
                    event.maxParticipants != null
                        ? '${event.participants}/${event.maxParticipants} participants'
                        : '${event.participants} participants',
                  ),
                ],

                if (event.entryFee != null && event.entryFee! > 0) ...[
                  SizedBox(height: AppSpacing.sm),
                  _buildEventDetailRow(
                    Icons.attach_money_rounded,
                    '\$${event.entryFee!.toStringAsFixed(0)} entry fee',
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEventDetailRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.gray500),
        SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.gray600),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchAndFilters(EventsLoaded state) {
    return Row(
      children: [
        // Search field
        Expanded(
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.gray50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.gray200),
            ),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search events...',
                hintStyle: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.gray400,
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: AppColors.gray400,
                  size: 20,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
              ),
              onChanged: (v) => context.read<EventsCubit>().updateSearch(v),
            ),
          ),
        ),

        SizedBox(width: AppSpacing.md),

        // Filter button
        Container(
          height: 48,
          decoration: BoxDecoration(
            color: state.filterType != null
                ? AppColors.primaryLimeGreen
                : AppColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: state.filterType != null
                  ? AppColors.primaryLimeGreen
                  : AppColors.gray200,
            ),
          ),
          child: PopupMenuButton<EventType?>(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
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
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.filter_list_rounded,
                    color: state.filterType != null
                        ? AppColors.white
                        : AppColors.gray600,
                    size: 20,
                  ),
                  SizedBox(width: AppSpacing.xs),
                  Text(
                    state.filterType == null
                        ? 'Filter'
                        : _getEventTypeLabel(state.filterType!),
                    style: AppTextStyles.labelLarge.copyWith(
                      color: state.filterType != null
                          ? AppColors.white
                          : AppColors.gray600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
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

  Color _getEventTypeColor(EventType type) {
    switch (type) {
      case EventType.tournament:
        return Colors.red;
      case EventType.league:
        return Colors.blue;
      case EventType.special:
        return Colors.purple;
      case EventType.practice:
        return Colors.green;
      case EventType.maintenance:
        return Colors.grey;
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
