import 'package:intl/intl.dart';

/// Pure formatting helpers — no I/O, no Flutter imports.
class DateFormatters {
  DateFormatters._();

  static String monthDay(DateTime d) => DateFormat('d MMM', 'en').format(d);

  static String fullDate(DateTime d) => DateFormat('d MMMM yyyy', 'en').format(d);

  static String timeOfDay(DateTime d) => DateFormat('HH:mm', 'en').format(d);

  /// Bucket a date into a human label: Today / Yesterday / month-year.
  static String bucket(DateTime d, DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    final that = DateTime(d.year, d.month, d.day);
    final diff = today.difference(that).inDays;
    if (diff == 0) return 'today';
    if (diff == 1) return 'yesterday';
    if (d.year == now.year) return DateFormat('MMMM', 'en').format(d);
    return DateFormat('MMMM yyyy', 'en').format(d);
  }
}

class FileFormatters {
  FileFormatters._();

  static String bytes(int bytes) {
    const units = ['B', 'KB', 'MB', 'GB', 'TB'];
    var size = bytes.toDouble();
    var i = 0;
    while (size >= 1024 && i < units.length - 1) {
      size /= 1024;
      i++;
    }
    return '${size.toStringAsFixed(size >= 100 ? 0 : 1)} ${units[i]}';
  }

  static String duration(Duration d) {
    final m = d.inMinutes;
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}
