import 'package:logger/logger.dart';
import 'package:proxypin/ui/mobile/dataswarm/config.dart';

final logger = Logger(
    filter: ProductionFilter(),
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 15,
      lineLength: 120,
      colors: true,
      printEmojis: false,
      dateTimeFormat: DateTimeFormat.onlyTime,
      excludeBox: {Level.info: true, Level.debug: true, Level.verbose: true, Level.warning: true, Level.error: true},
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
    // 移除 颜色 转义序列
    for (int i = 0; i < event.lines.length; i++) {
      event.lines[i] = event.lines[i].replaceAll(RegExp(r'\x1B\[[0-9;]*m'), '');
    }
    // 过滤逻辑：当 mode 为 user 时，只显示 info 级别且以 biz:: 开头的日志
    if (SwarmForagerConfig.mode == 'user') {
      if (event.level != Level.info) {
        return;
      }

      bool hasBizPrefix = event.lines.any((line) => line.contains("biz:"));
      if (!hasBizPrefix) {
        return;
      }
      for (int i = 0; i < event.lines.length; i++) {
        if (event.lines[i].startsWith("biz:")) {
          event.lines[i] = event.lines[i].replaceFirst("biz:", "");
        }
      }
    }
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
