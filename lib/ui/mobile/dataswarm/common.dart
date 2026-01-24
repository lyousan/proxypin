import 'package:package_info_plus/package_info_plus.dart';
import 'package:proxypin/ui/configuration.dart';
import 'package:proxypin/ui/mobile/dataswarm/user.dart';

Future<Map<String, String>> baseHeaders() async {
  var packageInfo = await PackageInfo.fromPlatform();
  var headers = {
    'Token': '',
    'X-Client': 'swarmprobe',
    'X-Client-Ver': packageInfo.version,
  };
  var userInfoMgr = await UserInfoManager.instance;
  var userInfo = userInfoMgr.currentUser;
  if (userInfo != null) {
    headers['Token'] = userInfo.token;
  }
  var appConfiguration = await AppConfiguration.instance;
  headers['Language'] = appConfiguration.language?.languageCode ?? 'en'; // ['en', 'zh', 'j']
  return headers;
}

String humanLength(int size) {
  if (size < 1025) {
    return "$size B";
  }

  if (size > 1024 * 1024) {
    return "${(size / 1024 / 1024).toStringAsFixed(2)} M";
  }
  return "${(size / 1024).toStringAsFixed(2)} K";
}
