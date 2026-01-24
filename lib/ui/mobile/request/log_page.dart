import 'package:flutter/material.dart';
import 'package:flutter_toastr/flutter_toastr.dart';
import 'package:proxypin/l10n/app_localizations.dart';
import 'package:proxypin/network/util/logger.dart';
import 'package:proxypin/ui/mobile/dataswarm/logs.dart';

class LogPage extends StatefulWidget {
  const LogPage({super.key});

  @override
  State<LogPage> createState() => _LogPageState();
}

class _LogPageState extends State<LogPage> {
  final GlobalKey<LogListWidgetState> _logListKey = GlobalKey<LogListWidgetState>();

  @override
  Widget build(BuildContext context) {
    AppLocalizations localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.logger, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w400)),
        centerTitle: false, // 标题显示在左边
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              _logListKey.currentState?.clear();
            },
          ),
          IconButton(
            icon: const Icon(Icons.wifi),
            onPressed: () {
              _logListKey.currentState?.copy();
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: LogListWidget(key: _logListKey),
    );
  }
}
