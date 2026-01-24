import 'package:logger/logger.dart';

final logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 15,
      lineLength: 120,
      colors: false,
      printEmojis: false,
      dateTimeFormat: DateTimeFormat.onlyTime,
      excludeBox: {Level.info: true, Level.debug: true},
    ),
    output: MultiOutput([
      ConsoleOutput(),
      AppLogOutput(),
    ]));

extension LoggerExt on Logger {
  void biz(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    i("biz:$message", error: error, stackTrace: stackTrace);
  }

  void bizError(
    dynamic message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    e("biz:$message", error: error, stackTrace: stackTrace);
  }
}

class AppLogOutput extends LogOutput {
  static final List<OutputEvent> logs = [];
  static final List<Function(OutputEvent)> _listeners = [];

  @override
  void output(OutputEvent event) {
    logs.add(event);
    if (logs.length > 1000) {
      logs.removeAt(0);
    }
    for (var listener in _listeners) {
      listener(event);
    }
  }

  static void addListener(Function(OutputEvent) listener) {
    _listeners.add(listener);
  }

  static void removeListener(Function(OutputEvent) listener) {
    _listeners.remove(listener);
  }

  static void clear() {
    logs.clear();
    for (var listener in _listeners) {
      // 触发一个空事件通知 UI
      listener(OutputEvent(LogEvent(Level.info, 'clear'), []));
    }
  }
}
