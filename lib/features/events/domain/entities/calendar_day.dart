import 'package:equatable/equatable.dart';
import 'calendar_event.dart';

class CalendarDay extends Equatable {
  final int date;
  final bool isCurrentMonth;
  final bool isToday;
  final List<CalendarEvent> events;

  const CalendarDay({
    required this.date,
    required this.isCurrentMonth,
    required this.isToday,
    required this.events,
  });

  @override
  List<Object?> get props => [date, isCurrentMonth, isToday, events];
}
