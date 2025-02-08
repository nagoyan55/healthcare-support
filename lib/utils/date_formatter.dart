class DateFormatter {
  static String formatMessageDate(DateTime date) {
    final now = DateTime.now();
    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      return '今日';
    } else if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day - 1) {
      return '昨日';
    }
    return '${date.month}月${date.day}日';
  }

  static String formatMessageTime(DateTime date) {
    return '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  static int compareDates(DateTime a, DateTime b) {
    return DateTime(b.year, b.month, b.day)
        .compareTo(DateTime(a.year, a.month, a.day));
  }

  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
