import 'package:flutter/material.dart';
import 'package:proxypin/l10n/app_localizations.dart';
import 'package:proxypin/network/bin/server.dart';
import 'package:proxypin/ui/mobile/dataswarm/config.dart';
import 'package:proxypin/ui/mobile/request/logs.dart';
import 'package:proxypin/utils/ip.dart';

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
        title: Text(localizations.logger),
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
            onPressed: () async {
              var ips = await localIps();
              var port = ProxyServer.current?.port;
              if (mounted) {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text('连接信息'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("本机地址:", style: TextStyle(fontSize: 18)),
                          ...ips.map((ip) => SelectableText("$ip:$port", style: TextStyle(fontSize: 18))),
                          // Padding(
                          //   padding: const EdgeInsets.only(top: 10.0), // 设置上边距为 10
                          //   child: Text("任务中心:", style: TextStyle(fontSize: 18)),
                          // ),
                          // SelectableText(SwarmProbeConfig.serverUrl, style: TextStyle(fontSize: 18))
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(localizations.close),
                        ),
                      ],
                    );
                  },
                );
              }
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: LogListWidget(key: _logListKey),
    );
  }
}
