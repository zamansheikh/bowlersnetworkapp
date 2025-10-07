import 'package:flutter/material.dart';
import '../../domain/entities/calendar_day.dart';
import '../../domain/entities/calendar_event.dart';

class CalendarWidget extends StatelessWidget {
  final List<CalendarDay> calendarDays;
  final DateTime currentDate;
  final DateTime? selectedDate;
  final Function(CalendarDay) onDaySelected;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;
  final VoidCallback onToday;

  const CalendarWidget({
    super.key,
    required this.calendarDays,
    required this.currentDate,
    this.selectedDate,
    required this.onDaySelected,
    required this.onPreviousMonth,
    required this.onNextMonth,
    required this.onToday,
  });

  @override
  Widget build(BuildContext context) {
    const monthNames = [
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

    const weekDays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Calendar Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      '${monthNames[currentDate.month - 1]} ${currentDate.year}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Row(
                      children: [
                        IconButton(
                          onPressed: onPreviousMonth,
                          icon: const Icon(Icons.chevron_left),
                          tooltip: 'Previous month',
                        ),
                        IconButton(
                          onPressed: onNextMonth,
                          icon: const Icon(Icons.chevron_right),
                          tooltip: 'Next month',
                        ),
                      ],
                    ),
                  ],
                ),
                TextButton(onPressed: onToday, child: const Text('Today')),
              ],
            ),
            const SizedBox(height: 16),
            // Calendar Grid
            Column(
              children: [
                // Week Day Headers
                Row(
                  children: weekDays
                      .map(
                        (day) => Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            child: Text(
                              day,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
                // Calendar Days
                ...List.generate(
                  (calendarDays.length / 7).ceil(),
                  (weekIndex) => Row(
                    children: List.generate(7, (dayIndex) {
                      final index = weekIndex * 7 + dayIndex;
                      if (index >= calendarDays.length) {
                        return const Expanded(child: SizedBox());
                      }

                      final day = calendarDays[index];
                      final isSelected =
                          selectedDate != null &&
                          selectedDate!.day == day.date &&
                          day.isCurrentMonth &&
                          selectedDate!.month == currentDate.month &&
                          selectedDate!.year == currentDate.year;

                      return Expanded(
                        child: GestureDetector(
                          onTap: () => onDaySelected(day),
                          child: Container(
                            margin: const EdgeInsets.all(2),
                            height: 80,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.green.withValues(alpha: 0.2)
                                  : day.isCurrentMonth
                                  ? Colors.white
                                  : Colors.grey.withValues(alpha: 0.1),
                              border: day.isToday
                                  ? Border.all(color: Colors.green, width: 2)
                                  : isSelected
                                  ? Border.all(color: Colors.green, width: 2)
                                  : Border.all(
                                      color: Colors.grey.withValues(alpha: 0.3),
                                    ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(4),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '${day.date}',
                                        style: TextStyle(
                                          fontWeight: day.isToday
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                          color: day.isToday
                                              ? Colors.green
                                              : day.isCurrentMonth
                                              ? Colors.black
                                              : Colors.grey,
                                        ),
                                      ),
                                      if (day.events.isNotEmpty)
                                        Container(
                                          padding: const EdgeInsets.all(2),
                                          decoration: const BoxDecoration(
                                            color: Colors.green,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Text(
                                            '${day.events.length}',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Expanded(
                                    child: Column(
                                      children: [
                                        ...day.events
                                            .take(2)
                                            .map(
                                              (event) => Container(
                                                margin: const EdgeInsets.only(
                                                  bottom: 1,
                                                ),
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 4,
                                                        vertical: 1,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: _getEventTypeColor(
                                                      event.type,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          4,
                                                        ),
                                                  ),
                                                  child: Text(
                                                    event.title,
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 8,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                        if (day.events.length > 2)
                                          Text(
                                            '+${day.events.length - 2} more',
                                            style: const TextStyle(
                                              fontSize: 8,
                                              color: Colors.grey,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
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
