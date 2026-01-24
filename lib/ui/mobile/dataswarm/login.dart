import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:proxypin/network/bin/configuration.dart';
import 'package:proxypin/ui/configuration.dart';
import 'package:proxypin/ui/mobile/dataswarm/config.dart';
import 'package:proxypin/ui/mobile/dataswarm/user.dart';
import 'package:proxypin/ui/mobile/mobile.dart';

class DataSwarmLoginPage extends StatefulWidget {
  const DataSwarmLoginPage({super.key});

  @override
  State<DataSwarmLoginPage> createState() => _DataSwarmLoginPageState();
}

class _DataSwarmLoginPageState extends State<DataSwarmLoginPage> {
  final TextEditingController _accountController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  // 登录逻辑预留
  Future<void> _handleLogin() async {
    final account = _accountController.text.trim();
    final password = _passwordController.text.trim();

    if (account.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入账号和密码')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse(await SwarmProbeConfig.loginUrl), // 请在这里补充 URL
        headers: {
          'Content-Type': 'application/json',
          'X-Client': 'swarmprobe',
          'X-Client-Ver': '1.2.4',
        },
        body: jsonEncode({
          'account': account,
          'password': password,
        }),
      );
      final Map<String, dynamic> body = jsonDecode(response.body);
      if (body['ok'] != true) {
        // 解析失败信息中的 msg 字段
        final String msg = body['msg'] ?? '登录失败';
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(msg)),
          );
        }
        return;
      } else {
        var token = body['access_token'];
        // 保存用户信息到本地
        var userInfo = UserInfo(account: account, token: token);
        var userInfoMgr = await UserInfoManager.instance;
        await userInfoMgr.saveUserInfo(userInfo);
      }
      if (mounted) {
        final appConfiguration = await AppConfiguration.instance;
        final configuration = await Configuration.instance;
        // 登录成功后跳转到我的页面
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => MobileHomePage(
              configuration,
              appConfiguration,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('登录失败: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DataSwarm 登录'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _accountController,
              decoration: const InputDecoration(
                labelText: '账号',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: '密码',
                prefixIcon: Icon(Icons.lock),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleLogin,
                child:
                    _isLoading ? const CircularProgressIndicator() : const Text('登录', style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _accountController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
