import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
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

  @override
  void initState() {
    super.initState();
  }

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
      var packageInfo = await PackageInfo.fromPlatform();
      final response = await http.post(
        Uri.parse(await SwarmProbeConfig.loginUrl), // 请在这里补充 URL
        headers: {
          'Content-Type': 'application/json',
          'X-Client': 'swarmprobe',
          'X-Client-Ver': packageInfo.version,
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 60),
                    // 顶部 Logo
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1), // 浅蓝背景
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Image.asset(
                          'assets/icon_foreground.png',
                          width: 80,
                          height: 80,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    // 欢迎语
                    Text(
                      'Swarm Probe',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 48),
                    // 输入框部分
                    TextField(
                      controller: _accountController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: '账号',
                        hintText: '请输入您的账号',
                        prefixIcon: const Icon(Icons.person_outline),
                        filled: true,
                        fillColor: colorScheme.surfaceVariant.withOpacity(0.3),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: colorScheme.primary, width: 2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _handleLogin(),
                      decoration: InputDecoration(
                        labelText: '密码',
                        hintText: '请输入您的密码',
                        prefixIcon: const Icon(Icons.lock_outline),
                        filled: true,
                        fillColor: colorScheme.surfaceVariant.withOpacity(0.3),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: colorScheme.primary, width: 2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    // 登录按钮
                    FilledButton(
                      onPressed: _isLoading ? null : _handleLogin,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: colorScheme.onPrimary,
                              ),
                            )
                          : const Text(
                              '登 录',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                    ),
                    const SizedBox(height: 24),
                    // 底部辅助信息（可选）
                    TextButton(
                      onPressed: () {
                        // 这里可以放找回密码或联系管理员
                      },
                      child: Text(
                        '遇到问题？联系管理员',
                        style: TextStyle(color: colorScheme.primary),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // 底部版本号
            FutureBuilder<PackageInfo>(
              future: PackageInfo.fromPlatform(),
              builder: (context, snapshot) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    snapshot.hasData ? 'V${snapshot.data!.version}' : '',
                    style: TextStyle(
                      color: Color.fromARGB(255, 71, 122, 164),
                      fontSize: 12,
                    ),
                  ),
                );
              },
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
