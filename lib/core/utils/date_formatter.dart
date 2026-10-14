import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  static String formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24 && dateTime.day == now.day) {
      return 'Today, ${DateFormat('h:mm a').format(dateTime)}';
    } else if (difference.inDays < 7) {
      return DateFormat('EEE, h:mm a').format(dateTime);
    } else {
      return DateFormat('d MMM yyyy, h:mm a').format(dateTime);
    }
  }

  static String formatTime(DateTime dateTime) {
    return DateFormat('h:mm a').format(dateTime);
  }

  static String formatDate(DateTime dateTime) {
    return DateFormat('d MMMM yyyy').format(dateTime);
  }
}
