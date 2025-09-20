import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/calendar_event.dart';
import '../../domain/entities/calendar_day.dart';
import '../cubit/events_cubit.dart';
import '../cubit/events_state.dart';
import '../widgets/calendar_widget.dart';
import '../widgets/calendar_helper.dart';
import '../widgets/event_details_widget.dart';

class EventsPage extends StatefulWidget {
  const EventsPage({Key? key}) : super(key: key);

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  @override
  void initState() {
    super.initState();
    // Load events when page initializes
    context.read<EventsCubit>().loadEvents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Events Calendar'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<EventsCubit>().loadEvents();
            },
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
                  CircularProgressIndicator(),
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
    final calendarDays = CalendarHelper.generateCalendar(
      state.currentDate,
      state.events,
    );

    final filteredEvents = context.read<EventsCubit>().getFilteredEvents(
      state.selectedDate,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        // Mobile layout (single column)
        if (constraints.maxWidth < 800) {
          return _buildMobileLayout(
            context,
            state,
            calendarDays,
            filteredEvents,
          );
        }
        // Desktop/tablet layout (two columns)
        else {
          return _buildDesktopLayout(
            context,
            state,
            calendarDays,
            filteredEvents,
          );
        }
      },
    );
  }

  Widget _buildMobileLayout(
    BuildContext context,
    EventsLoaded state,
    List<CalendarDay> calendarDays,
    List<CalendarEvent> filteredEvents,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Calendar
          CalendarWidget(
            calendarDays: calendarDays,
            currentDate: state.currentDate,
            selectedDate: state.selectedDate,
            onDaySelected: (day) {
              if (day.isCurrentMonth) {
                final selectedDate = DateTime(
                  state.currentDate.year,
                  state.currentDate.month,
                  day.date,
                );
                context.read<EventsCubit>().selectDate(selectedDate);
              }
            },
            onPreviousMonth: () {
              context.read<EventsCubit>().navigateMonth(false);
            },
            onNextMonth: () {
              context.read<EventsCubit>().navigateMonth(true);
            },
            onToday: () {
              context.read<EventsCubit>().setCurrentDate(DateTime.now());
            },
          ),
          const SizedBox(height: 16),

          // Event Types Legend
          _buildEventTypesLegend(state),
          const SizedBox(height: 16),

          // Event Details
          SizedBox(
            height: 600,
            child: EventDetailsWidget(
              events: filteredEvents,
              selectedDate: state.selectedDate,
              searchTerm: state.searchTerm,
              filterType: state.filterType,
              onSearchChanged: (searchTerm) {
                context.read<EventsCubit>().updateSearch(searchTerm);
              },
              onFilterChanged: (filterType) {
                context.read<EventsCubit>().updateFilter(filterType);
              },
            ),
          ),
          const SizedBox(height: 16),

          // Monthly Stats
          _buildMonthlyStats(context, state),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(
    BuildContext context,
    EventsLoaded state,
    List<CalendarDay> calendarDays,
    List<CalendarEvent> filteredEvents,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Calendar section (2/3 width)
          Expanded(
            flex: 2,
            child: CalendarWidget(
              calendarDays: calendarDays,
              currentDate: state.currentDate,
              selectedDate: state.selectedDate,
              onDaySelected: (day) {
                if (day.isCurrentMonth) {
                  final selectedDate = DateTime(
                    state.currentDate.year,
                    state.currentDate.month,
                    day.date,
                  );
                  context.read<EventsCubit>().selectDate(selectedDate);
                }
              },
              onPreviousMonth: () {
                context.read<EventsCubit>().navigateMonth(false);
              },
              onNextMonth: () {
                context.read<EventsCubit>().navigateMonth(true);
              },
              onToday: () {
                context.read<EventsCubit>().setCurrentDate(DateTime.now());
              },
            ),
          ),
          const SizedBox(width: 16),

          // Sidebar (1/3 width)
          Expanded(
            flex: 1,
            child: Column(
              children: [
                // Event Types Legend
                _buildEventTypesLegend(state),
                const SizedBox(height: 16),

                // Event Details
                Expanded(
                  child: EventDetailsWidget(
                    events: filteredEvents,
                    selectedDate: state.selectedDate,
                    searchTerm: state.searchTerm,
                    filterType: state.filterType,
                    onSearchChanged: (searchTerm) {
                      context.read<EventsCubit>().updateSearch(searchTerm);
                    },
                    onFilterChanged: (filterType) {
                      context.read<EventsCubit>().updateFilter(filterType);
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // Monthly Stats
                _buildMonthlyStats(context, state),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventTypesLegend(EventsLoaded state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Event Types',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...EventType.values.map((type) {
              final count = context.read<EventsCubit>().getEventCountByType(
                type,
                state.currentDate,
              );
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
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
                        const SizedBox(width: 8),
                        Text(_getEventTypeLabel(type)),
                      ],
                    ),
                    Text(
                      '$count',
                      style: const TextStyle(fontWeight: FontWeight.bold),
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'This Month',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

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
                const Text(
                  'Total Events',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '$totalEvents',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
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
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 8),
              Text(label),
            ],
          ),
          Text('$count', style: const TextStyle(fontWeight: FontWeight.bold)),
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
}
