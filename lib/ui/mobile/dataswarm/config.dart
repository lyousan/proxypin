import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_toastr/flutter_toastr.dart';
import 'package:http/http.dart' as http;
import 'package:proxypin/network/components/manager/hosts_manager.dart';
import 'package:proxypin/network/components/manager/report_server_manager.dart';
import 'package:proxypin/network/components/manager/request_rewrite_manager.dart';
import 'package:proxypin/network/components/manager/rewrite_rule.dart';
import 'package:proxypin/network/components/manager/script_manager.dart';
import 'package:proxypin/network/util/logger.dart';
import 'package:proxypin/utils/lang.dart';
import 'package:proxypin/utils/navigator.dart';
import 'package:proxypin/ui/mobile/dataswarm/common.dart' as common;

/// 全局配置类，单例模式
class SwarmForagerConfig {
  // 私有构造函数
  SwarmForagerConfig._internal();

  // 服务器主机名
  static String serverUrl = 'http://bodtok.com/ds';
  // 模式 dev/user
  static final ValueNotifier<String> modeNotifier = ValueNotifier('user'); // user/dev
  static String get mode => modeNotifier.value;
  static set mode(String newMode) => modeNotifier.value = newMode;

  // login url
  static Future<String> get loginUrl async {
    return await wrapUrl('$serverUrl/auth/login');
  }

  // report config url
  static Future<String> get configUrl async {
    return await wrapUrl('$serverUrl/config/report');
  }

  // pull task url
  static Future<String> get pullTaskUrl async {
    return await wrapUrl('$serverUrl/task/pull');
  }

  // report hertz url
  static Future<String> get hertzUrl async {
    return await wrapUrl('$serverUrl/hello');
  }

  static Future<dynamic> get scriptUrl async => await wrapUrl('$serverUrl/config/script');

  static Future<String> get scriptConfigUrl async => await wrapUrl('$serverUrl/config/check_script_versions');

  static Future<String> get checkUpdateUrl async => await wrapUrl('$serverUrl/config/check_app_version');

  static Future<String> wrapUrl(String url) async {
    var hostsManager = await HostsManager.instance;
    var mappedHost = await hostsManager.getHosts(serverUrl);
    if (mappedHost != null && mappedHost.toAddress != null) {
      return url.replaceFirst(serverUrl, mappedHost.toAddress!);
    }
    var rewriteManager = await RequestRewriteManager.instance;
    var redirectRule = rewriteManager.getRewriteRule(url, [RuleType.redirect]);
    if (redirectRule != null) {
      var rewriteItems = await rewriteManager.getRewriteItems(redirectRule);
      var redirectUrl = rewriteItems?.firstWhereOrNull((element) => element.enabled)?.redirectUrl;
      if (redirectUrl != null && redirectRule.url.contains("*") && redirectUrl.contains("*")) {
        String ruleUrl = redirectRule.url.replaceAll("*", "");
        url = redirectUrl.replaceAll("*", url.replaceAll(ruleUrl, ""));
      }
    }
    return url;
  }
}

class ReportConfigManager {
  static Timer? timer;
  static List<ReportServer> reportConfigs = [];
  static void startTimer() {
    logger.i('startTimer 开始拉取上报配置');
    pullReportConfig();
    if (timer != null) {
      return;
    }
    timer = Timer.periodic(Duration(seconds: 60), (timer) {
      pullReportConfig();
    });
  }

  static void stopTimer() {
    timer?.cancel();
    timer = null;
  }

  // 拉取配置
  static Future<void> pullReportConfig() async {
    final response = await http.get(Uri.parse(await SwarmForagerConfig.configUrl), headers: await common.baseHeaders());
    if (response.statusCode != 200) {
      if (NavigatorHelper().context.mounted) {
        FlutterToastr.show('拉取上报配置失败 ${response.statusCode}', NavigatorHelper().context);
      }
      return;
    }

    logger.d('拉取上报配置返回 ${response.body}');

    // 请求成功，解析JSON数据
    Map<String, dynamic> result = json.decode(response.body);
    if (result['ok'] && result['data'] != null) {
      final data = result['data'];
      if (data is List) {
        reportConfigs = data.map((e) => ReportServer.fromJson(e)).toList();
        var reprotServerMgr = await ReportServerManager.instance;
        reprotServerMgr.servers = reportConfigs;
      }
      return;
    }
    if (NavigatorHelper().context.mounted) {
      FlutterToastr.show(result['msg'], NavigatorHelper().context);
    }
  }
}

class ScriptConfigManager {
  static Timer? timerTask;
  static String? taskInfo;

  static void startTimer() {
    logger.i('startTimer 开始拉取脚本');
    pullScripts();
    if (timerTask != null) {
      return;
    }
    timerTask = Timer.periodic(Duration(seconds: 300), (timer) {
      pullScripts();
    });
  }

  static void stopTimer() {
    timerTask?.cancel();
    timerTask = null;
  }

  // 拉取脚本
  static Future<void> pullScripts() async {
    final response =
        await http.get(Uri.parse(await SwarmForagerConfig.scriptConfigUrl), headers: await common.baseHeaders());

    logger.d('拉取脚本返回 ${response.body}');

    // 请求成功，解析JSON数据
    Map<String, dynamic> result = json.decode(response.body);
    if (result['ok'] && result['data'] != null) {
      final data = result['data'];
      if (data is List) {
        var scriptManager = await ScriptManager.instance;
        for (var script in data) {
          var scriptName = script['name'];
          var scriptVersion = script['version'];
          ScriptItem? localScript = scriptManager.list.firstWhereOrNull((it) => it.name == scriptName);
          if (localScript == null || localScript.version != scriptVersion) {
            logger.d('本地脚本不存在或版本不一致，开始拉取脚本 $scriptName');
            await pullScriptByName(scriptName);
          }
        }
      }

      return;
    }
  }

  static Future<void> pullScriptByName(String name) async {
    final response = await http.get(Uri.parse('${await SwarmForagerConfig.scriptUrl}?name=$name'),
        headers: await common.baseHeaders());
    logger.d('拉取脚本返回 ${response.body}');
    // 请求成功，解析JSON数据
    Map<String, dynamic> result = json.decode(response.body);
    if (result['ok'] && result['data'] != null) {
      final data = result['data'];
      var scriptManager = await ScriptManager.instance;
      if (data is Map) {
        var version = data['version'];
        var url = data['url'];
        var script = data['code'];
        var enable = data['enable'];
        await scriptManager.removeScriptByName(name);
        if (enable) {
          var scriptItem = ScriptItem(enable, name, url, version: version);
          await scriptManager.addScript(scriptItem, script);
        }
        await scriptManager.flushConfig();
      }
      scriptManager.reloadScript();
      return;
    }
  }
}
