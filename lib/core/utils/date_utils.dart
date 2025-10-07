import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Utility class for parsing dates from the API
/// Handles multiple date formats from the backend
class DateUtils {
  /// Common date formats used by the API
  static const List<String> _dateFormats = [
    'yyyy-MM-dd HH:mm:ss', // Standard SQL datetime
    'yyyy-MM-ddTHH:mm:ss.SSSZ', // ISO 8601
    'yyyy-MM-ddTHH:mm:ssZ', // ISO 8601 without milliseconds
    'yyyy-MM-dd', // Date only
    'MMMM d, yyyy', // July 30, 2025 format
    'MMMM dd, yyyy', // July 30, 2025 format with leading zero
    'MMM d, yyyy', // Jul 30, 2025 format
    'MMM dd, yyyy', // Jul 30, 2025 format with leading zero
  ];

  /// Safely parse a date string from the API
  /// Returns null if the date cannot be parsed
  static DateTime? tryParseDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) {
      return null;
    }

    // Try standard DateTime.parse first (handles most ISO formats)
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      // If that fails, try our custom formats
    }

    // Try each format in our list
    for (String format in _dateFormats) {
      try {
        final formatter = DateFormat(format);
        return formatter.parse(dateString);
      } catch (e) {
        // Continue to next format
        continue;
      }
    }

    // If all formats fail, return null
    debugPrint('Warning: Could not parse date string: $dateString');
    return null;
  }

  /// Parse a date string from the API with fallback to current time
  /// This ensures we always have a valid DateTime object
  static DateTime parseDate(String? dateString) {
    return tryParseDate(dateString) ?? DateTime.now();
  }

  /// Format a DateTime to a user-friendly string
  static String formatUserFriendly(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'year' : 'years'} ago';
    }
  }

  /// Format a DateTime to a short date string (e.g., "Jul 30, 2025")
  static String formatShortDate(DateTime dateTime) {
    return DateFormat('MMM d, yyyy').format(dateTime);
  }

  /// Format a DateTime to a full date string (e.g., "July 30, 2025")
  static String formatFullDate(DateTime dateTime) {
    return DateFormat('MMMM d, yyyy').format(dateTime);
  }
}
