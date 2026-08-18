import 'package:logging/logging.dart';

/// Thin wrapper around `package:logging` so feature modules don't import
/// the logging package directly.
class AppLogger {
  AppLogger._();

  static void init() {
    Logger.root.level = Level.INFO;
    Logger.root.onRecord.listen((record) {
      // In a real build you'd route this to a file or crash reporter.
      // ignore: avoid_print
      print('[${record.level.name}] ${record.loggerName}: ${record.message}');
    });
  }

  static Logger get(String name) => Logger(name);
}
