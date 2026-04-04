import 'package:intl/intl.dart';

extension DateTimeExtensions on DateTime {
  String get formatted => DateFormat('MMM d, yyyy').format(this);
  String get formattedWithTime => DateFormat('MMM d, yyyy h:mm a').format(this);
  String get shortDate => DateFormat('MM/dd/yyyy').format(this);
  String get isoDate => DateFormat('yyyy-MM-dd').format(this);
  String get timeOnly => DateFormat('h:mm a').format(this);
  String get monthYear => DateFormat('MMMM yyyy').format(this);

  String get timeAgo {
    final now = DateTime.now();
    final diff = now.difference(this);

    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()}w ago';
    if (diff.inDays < 365) return '${(diff.inDays / 30).floor()}mo ago';
    return '${(diff.inDays / 365).floor()}y ago';
  }

  int get age {
    final now = DateTime.now();
    int age = now.year - year;
    if (now.month < month || (now.month == month && now.day < day)) {
      age--;
    }
    return age;
  }

  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year && month == yesterday.month && day == yesterday.day;
  }
}
