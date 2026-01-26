import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:proxypin/network/components/manager/report_server_manager.dart';
import 'package:proxypin/ui/mobile/dataswarm/config.dart';
import 'package:proxypin/ui/mobile/dataswarm/common.dart' as common;
import 'package:proxypin/ui/mobile/dataswarm/user.dart';

/// 心跳上报功能
/// 定时向指定服务器发送设备状态信息
class Hertz {
  static Timer? _timer;
  static bool _isRunning = false;
  static int _failedCount = 0;

  /// 开始心跳任务
  static void start() {
    if (_isRunning) return;
    _isRunning = true;

    // 立即执行一次，然后开始定时
    _report();

    _timer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _report();
    });
  }

  /// 停止心跳任务
  static void stop() {
    _timer?.cancel();
    _timer = null;
    _isRunning = false;
  }

  /// 执行上报逻辑
  static Future<void> _report() async {
    try {
      final Map<String, String> headers = await common.baseHeaders();

      final Map<String, dynamic> body = {
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'mode': SwarmForagerConfig.mode,
      };

      final response = await http
          .post(
            Uri.parse(await SwarmForagerConfig.hertzUrl),
            headers: {
              ...headers,
              'Content-Type': 'application/json',
            },
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 30));
      switch (response.statusCode) {
        case 200:
          _failedCount = 0;
          break;
        default:
          _failedCount++;
      }
    } catch (e) {
      _failedCount++;
    }
    if (_failedCount >= 5) {
      await (await UserInfoManager.instance).clearUserInfo();
      await (await ReportServerManager.instance).clear();
      stop();
      exit(0);
    }
  }
}
