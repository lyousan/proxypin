import 'package:flutter/material.dart';
import 'package:proxypin/ui/mobile/dataswarm/login.dart';
import 'package:proxypin/ui/mobile/dataswarm/user.dart';

class DataSwarmMePage extends StatelessWidget {
  const DataSwarmMePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('我的'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
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
}
