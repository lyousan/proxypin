import 'package:flutter/material.dart';
import 'package:proxypin/network/bin/server.dart';
import 'package:proxypin/network/channel/channel.dart';
import 'package:proxypin/network/channel/channel_context.dart';
import 'package:proxypin/network/http/http.dart';
import 'package:proxypin/network/http/websocket.dart';
import 'package:proxypin/ui/mobile/dataswarm/config.dart';
import 'package:proxypin/ui/mobile/dataswarm/hertz.dart';
import 'package:proxypin/ui/mobile/dataswarm/login.dart';
import 'package:proxypin/ui/mobile/dataswarm/user.dart';

import '../../../network/bin/listener.dart';

class DataSwarmMePage extends StatefulWidget {
  final ProxyServer proxyServer;
  const DataSwarmMePage({super.key, required this.proxyServer});

  @override
  State<DataSwarmMePage> createState() => _DataSwarmMePageState();
}

class _DataSwarmMePageState extends State<DataSwarmMePage> implements EventListener {
  @override
  void initState() {
    super.initState();
    widget.proxyServer.listeners.removeWhere((it) => it.runtimeType == runtimeType);
    widget.proxyServer.addListener(this);
    Hertz.start();
    ReportConfigManager.startTimer();
  }

  @override
  void dispose() {
    Hertz.stop();
    ReportConfigManager.stopTimer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('我的'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              // logout
              final navigator = Navigator.of(context, rootNavigator: true);
              var userInfoMgr = await UserInfoManager.instance;
              await userInfoMgr.clearUserInfo();
              if (!context.mounted) {
                return;
              }
              navigator.pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const DataSwarmLoginPage()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 50,
              child: Icon(Icons.person, size: 50),
            ),
            const SizedBox(height: 20),
            Text(
              "User",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              '欢迎使用 DataSwarm',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void onMessage(Channel channel, HttpMessage message, WebSocketFrame frame) {
    // TODO: implement onMessage
  }

  @override
  void onRequest(Channel channel, HttpRequest request) {
    // TODO: implement onRequest
  }

  @override
  void onResponse(ChannelContext channelContext, HttpResponse response) {
    // TODO: implement onResponse
  }
}
