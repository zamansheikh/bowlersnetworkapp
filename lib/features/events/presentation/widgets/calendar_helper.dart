import '../../domain/entities/calendar_day.dart';
import '../../domain/entities/calendar_event.dart';

class CalendarHelper {
  static List<CalendarDay> generateCalendar(
    DateTime currentDate,
    List<CalendarEvent> events,
  ) {
    final year = currentDate.year;
    final month = currentDate.month;
    final today = DateTime.now();

    final firstDayOfMonth = DateTime(year, month, 1);
    final lastDayOfMonth = DateTime(year, month + 1, 0);
    final firstDayOfWeek =
        firstDayOfMonth.weekday % 7; // Convert Monday=1 to Sunday=0
    final daysInMonth = lastDayOfMonth.day;

    final List<CalendarDay> calendar = [];

    // Add previous month's trailing days
    final prevMonth = DateTime(year, month - 1, 0);
    for (int i = firstDayOfWeek - 1; i >= 0; i--) {
      final date = prevMonth.day - i;
      calendar.add(
        CalendarDay(
          date: date,
          isCurrentMonth: false,
          isToday: false,
          events: [],
        ),
      );
    }

    // Add current month's days
    for (int date = 1; date <= daysInMonth; date++) {
      final currentDay = DateTime(year, month, date);
      final isToday =
          currentDay.year == today.year &&
          currentDay.month == today.month &&
          currentDay.day == today.day;

      final dayEvents = events.where((event) {
        final eventDate = DateTime.parse(event.date);
        return eventDate.year == currentDay.year &&
            eventDate.month == currentDay.month &&
            eventDate.day == currentDay.day;
      }).toList();

      calendar.add(
        CalendarDay(
          date: date,
          isCurrentMonth: true,
          isToday: isToday,
          events: dayEvents,
        ),
      );
    }

    // Add next month's leading days to fill the grid
    final remainingDays = 42 - calendar.length; // 6 weeks * 7 days
    for (int date = 1; date <= remainingDays; date++) {
      calendar.add(
        CalendarDay(
          date: date,
          isCurrentMonth: false,
          isToday: false,
          events: [],
        ),
      );
    }

    return calendar;
  }
}
