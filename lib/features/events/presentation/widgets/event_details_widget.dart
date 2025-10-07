import 'package:flutter/material.dart';
import '../../domain/entities/calendar_event.dart';
import 'package:intl/intl.dart';

class EventDetailsWidget extends StatelessWidget {
  final List<CalendarEvent> events;
  final DateTime? selectedDate;
  final String searchTerm;
  final EventType? filterType;
  final Function(String) onSearchChanged;
  final Function(EventType?) onFilterChanged;

  const EventDetailsWidget({
    super.key,
    required this.events,
    this.selectedDate,
    required this.searchTerm,
    this.filterType,
    required this.onSearchChanged,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  selectedDate != null
                      ? DateFormat('EEEE, MMMM d').format(selectedDate!)
                      : 'All Events',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${events.length} event(s)',
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Search and Filter
            TextField(
              decoration: const InputDecoration(
                hintText: 'Search events...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onChanged: onSearchChanged,
            ),
            const SizedBox(height: 8),

            DropdownButtonFormField<EventType?>(
              initialValue: filterType,
              decoration: const InputDecoration(
                labelText: 'Filter by type',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              items: [
                const DropdownMenuItem<EventType?>(
                  value: null,
                  child: Text('All Types'),
                ),
                ...EventType.values.map(
                  (type) => DropdownMenuItem<EventType?>(
                    value: type,
                    child: Text(_getEventTypeLabel(type)),
                  ),
                ),
              ],
              onChanged: onFilterChanged,
            ),
            const SizedBox(height: 16),

            // Events List
            Expanded(
              child: events.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.event_note,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            selectedDate != null
                                ? 'No events on this date'
                                : 'No events found',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: events.length,
                      itemBuilder: (context, index) {
                        final event = events[index];
                        return _buildEventCard(event);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventCard(CalendarEvent event) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: _getEventTypeColor(event.type),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    event.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                _getPriorityIcon(event.priority),
              ],
            ),
            const SizedBox(height: 8),

            Row(
              children: [
                const Icon(Icons.access_time, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  event.endTime != null
                      ? '${event.time} - ${event.endTime}'
                      : event.time,
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 4),

            Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    event.location,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
              ],
            ),

            if (event.participants > 0) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.people, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    event.maxParticipants != null
                        ? '${event.participants}/${event.maxParticipants} participants'
                        : '${event.participants} participants',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ],

            if (event.entryFee != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.attach_money, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    '\$${event.entryFee!.toStringAsFixed(2)} entry fee',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 8),
            Text(
              event.description,
              style: const TextStyle(color: Colors.black87),
            ),

            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(event.status),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getStatusLabel(event.status),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    // TODO: Navigate to event details
                  },
                  icon: const Icon(Icons.arrow_forward, size: 16),
                  label: const Text('View Details'),
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

  Widget _getPriorityIcon(EventPriority priority) {
    Color color;
    switch (priority) {
      case EventPriority.high:
        color = Colors.red;
        break;
      case EventPriority.medium:
        color = Colors.orange;
        break;
      case EventPriority.low:
        color = Colors.green;
        break;
    }

    return Icon(Icons.flag, size: 16, color: color);
  }

  Color _getStatusColor(EventStatus status) {
    switch (status) {
      case EventStatus.upcoming:
        return Colors.blue;
      case EventStatus.ongoing:
        return Colors.green;
      case EventStatus.completed:
        return Colors.grey;
      case EventStatus.cancelled:
        return Colors.red;
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
}
