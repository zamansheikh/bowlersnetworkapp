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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.gray900,
        title: Text(
          'Events',
          style: AppTextStyles.titleLarge.copyWith(
            color: AppColors.gray900,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<EventsCubit>().loadEvents(),
            color: AppColors.primaryLimeGreen,
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
    final filteredEvents =
        context.read<EventsCubit>().getFilteredEvents(state.selectedDate);

    return LayoutBuilder(
      builder: (context, constraints) {
        // Mobile layout (single column)
        if (constraints.maxWidth < 800) {
          return _buildMobileLayout(
            context,
            state,
            filteredEvents,
          );
        }
        // Desktop/tablet layout (two columns)
        else {
          return _buildDesktopLayout(
            context,
            state,
            filteredEvents,
          );
        }
      },
    );
  }

  Widget _buildMobileLayout(
    BuildContext context,
    EventsLoaded state,
    List<CalendarEvent> filteredEvents,
  ) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          _buildCalendar(state),
          SizedBox(height: AppSpacing.lg),

          // Event Types Legend
          _buildEventTypesLegend(state),
          SizedBox(height: AppSpacing.lg),

          // Event Details
          SizedBox(
            height: 600,
            child: _buildEventsListCard(context, state, filteredEvents),
          ),
          SizedBox(height: AppSpacing.lg),

          // Monthly Stats
          _buildMonthlyStats(context, state),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(
    BuildContext context,
    EventsLoaded state,
    List<CalendarEvent> filteredEvents,
  ) {
    return Padding(
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Calendar section (2/3 width)
          Expanded(
            flex: 2,
            child: _buildCalendar(state),
          ),
          SizedBox(width: AppSpacing.lg),

          // Sidebar (1/3 width)
          Expanded(
            flex: 1,
            child: Column(
              children: [
                // Event Types Legend
                _buildEventTypesLegend(state),
                SizedBox(height: AppSpacing.lg),

                // Event Details
                Expanded(
                  child: _buildEventsListCard(
                    context,
                    state,
                    filteredEvents,
                  ),
                ),
                SizedBox(height: AppSpacing.lg),

                // Monthly Stats
                _buildMonthlyStats(context, state),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar(EventsLoaded state) {
    _selectedDay = state.selectedDate;
    _focusedDay = state.currentDate;
    return Card(
      color: AppColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.md),
        child: TableCalendar<CalendarEvent>(
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2035, 12, 31),
          focusedDay: _focusedDay,
          calendarFormat: _calendarFormat,
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
            context.read<EventsCubit>().selectDate(selectedDay);
          },
          onFormatChanged: (format) {
            setState(() => _calendarFormat = format);
          },
          onPageChanged: (focusedDay) {
            _focusedDay = focusedDay;
            context.read<EventsCubit>().setCurrentDate(focusedDay);
          },
          eventLoader: (day) => context.read<EventsCubit>().getEventsForDate(day),
          headerStyle: HeaderStyle(
            titleCentered: true,
            titleTextStyle: AppTextStyles.titleMedium.copyWith(
              color: AppColors.gray900,
              fontWeight: FontWeight.w700,
            ),
            formatButtonVisible: true,
            leftChevronIcon: const Icon(Icons.chevron_left),
            rightChevronIcon: const Icon(Icons.chevron_right),
          ),
          calendarStyle: CalendarStyle(
            todayDecoration: BoxDecoration(
              color: AppColors.primaryLimeGreen.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            selectedDecoration: const BoxDecoration(
              color: AppColors.primaryLimeGreen,
              shape: BoxShape.circle,
            ),
            markerDecoration: const BoxDecoration(
              color: AppColors.primaryLimeGreen,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEventsListCard(
    BuildContext context,
    EventsLoaded state,
    List<CalendarEvent> events,
  ) {
    return Card(
      color: AppColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search events...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      isDense: true,
                    ),
                    onChanged: (v) => context.read<EventsCubit>().updateSearch(v),
                  ),
                ),
                SizedBox(width: AppSpacing.md),
                PopupMenuButton<EventType?>(
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
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLimeGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.filter_list, color: AppColors.primaryLimeGreen),
                        SizedBox(width: AppSpacing.xs),
                        Text(
                          state.filterType == null
                              ? 'All types'
                              : _getEventTypeLabel(state.filterType!),
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.primaryLimeGreen,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.md),

            Expanded(
              child: events.isEmpty
                  ? Center(
                      child: Text(
                        state.selectedDate != null
                            ? 'No events on this date'
                            : 'No events found',
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.gray600,
                        ),
                      ),
                    )
                  : ListView.separated(
                      itemCount: events.length,
                      separatorBuilder: (_, __) => SizedBox(height: AppSpacing.sm),
                      itemBuilder: (context, index) {
                        final event = events[index];
                        return _buildEventTile(event);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventTile(CalendarEvent event) {
    final statusColor = _getStatusColor(event.status);
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // TODO: Navigate to event details
        },
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.event,
                  color: statusColor,
                ),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.gray900,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: AppSpacing.xs),
                    Row(
                      children: [
                        const Icon(Icons.access_time, size: 14, color: AppColors.gray600),
                        SizedBox(width: AppSpacing.xs),
                        Text(
                          event.endTime == null
                              ? '${event.date} • ${event.time}'
                              : '${event.date} • ${event.time} - ${event.endTime}',
                          style: AppTextStyles.bodySmall.copyWith(color: AppColors.gray600),
                        ),
                      ],
                    ),
                    SizedBox(height: AppSpacing.xs),
                    Row(
                      children: [
                        const Icon(Icons.place, size: 14, color: AppColors.gray600),
                        SizedBox(width: AppSpacing.xs),
                        Expanded(
                          child: Text(
                            event.location,
                            style: AppTextStyles.bodySmall.copyWith(color: AppColors.gray600),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(width: AppSpacing.md),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  _getStatusLabel(event.status),
                  style: AppTextStyles.bodySmall.copyWith(color: statusColor, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEventTypesLegend(EventsLoaded state) {
    return Card(
      color: AppColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Event Types',
              style: AppTextStyles.titleMedium.copyWith(
                color: AppColors.gray900,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: AppSpacing.sm),
            ...EventType.values.map((type) {
              final count = context.read<EventsCubit>().getEventCountByType(
                type,
                state.currentDate,
              );
              return Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.xs),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: _getEventTypeColor(type),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        SizedBox(width: AppSpacing.sm),
                        Text(
                          _getEventTypeLabel(type),
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.gray800,
                          ),
                        ),
                      ],
                    ),
                    Text('$count', style: AppTextStyles.bodyMedium),
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This Month',
              style: AppTextStyles.titleMedium.copyWith(
                color: AppColors.gray900,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: AppSpacing.sm),

            _buildStatRow(
              Icons.emoji_events,
              'Tournaments',
              tournaments,
              Colors.red,
            ),
            _buildStatRow(
              Icons.calendar_today,
              'League Games',
              leagues,
              Colors.blue,
            ),
            _buildStatRow(
              Icons.sports_tennis,
              'Practice Sessions',
              practice,
              Colors.green,
            ),

            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total Events', style: AppTextStyles.bodyMedium),
                Text(
                  '$totalEvents',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.primaryLimeGreen,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(IconData icon, String label, int count, Color color) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              SizedBox(width: AppSpacing.sm),
              Text(label),
            ],
          ),
          Text('$count', style: AppTextStyles.bodyMedium),
        ],
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
