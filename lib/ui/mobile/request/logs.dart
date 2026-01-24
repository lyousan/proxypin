import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import 'package:proxypin/network/util/logger.dart';

import 'package:proxypin/ui/mobile/dataswarm/config.dart';

class LogListWidget extends StatefulWidget {
  const LogListWidget({super.key});

  @override
  State<LogListWidget> createState() => LogListWidgetState();
}

class LogListWidgetState extends State<LogListWidget> {
  final ScrollController _scrollController = ScrollController();
  List<OutputEvent> logs = [];

  @override
  void initState() {
    super.initState();
    // 初始化时对已有日志进行过滤
    logs = AppLogOutput.logs.where((event) {
      if (SwarmProbeConfig.mode == 'user') {
        if (event.level != Level.info) return false;
        return event.lines.any((line) => line.startsWith("biz:"));
      }
      return true;
    }).toList();

    AppLogOutput.addListener(_onLog);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  @override
  void dispose() {
    AppLogOutput.removeListener(_onLog);
    _scrollController.dispose();
    super.dispose();
  }

  void _onLog(OutputEvent event) {
    if (mounted) {
      if (event.origin.message == 'clear') {
        setState(() {
          logs = [];
        });
        return;
      }

      // 过滤逻辑：当 mode 为 user 时，只显示 info 级别且以 biz:: 开头的日志
      if (SwarmProbeConfig.mode == 'user') {
        if (event.level != Level.info) {
          return;
        }
        bool hasBizPrefix = event.lines.any((line) => line.startsWith("biz:"));
        if (!hasBizPrefix) {
          return;
        }
        for (int i = 0; i < event.lines.length; i++) {
          if (event.lines[i].startsWith("biz:")) {
            event.lines[i] = event.lines[i].replaceFirst("biz:", "");
          }
        }
      }

      setState(() {
        logs.add(event);
        if (logs.length > 1000) {
          logs.removeAt(0);
        }
      });
      _scrollToBottom();
    }
  }

  void clear() {
    AppLogOutput.clear();
  }

  void copy() {
    var text = logs.expand((e) => e.lines).join('\n');
    Clipboard.setData(ClipboardData(text: text));
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.only(top: 10, bottom: 10, right: 3),
            child: Scrollbar(
              controller: _scrollController,
              thumbVisibility: true,
              thickness: 6,
              interactive: true,
              child: ListView.builder(
                controller: _scrollController,
                itemCount: logs.length,
                itemBuilder: (context, index) {
                  var log = logs[index];
                  Color? color;
                  if (log.level == Level.error) {
                    color = Colors.red;
                  } else if (log.level == Level.warning) {
                    color = Colors.orange;
                  } else if (log.level == Level.debug || log.level == Level.trace) {
                    color = Colors.grey;
                  } else if (log.level == Level.info) {
                    color = Theme.of(context).textTheme.bodyMedium?.color;
                  }

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 5, left: 10, right: 3),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: log.lines
                          .map((line) => SelectableText(
                                line,
                                style: TextStyle(fontSize: 13, color: color, fontFamily: 'monospace'),
                              ))
                          .toList(),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}
