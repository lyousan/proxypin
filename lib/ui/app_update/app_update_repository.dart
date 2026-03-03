import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:proxypin/l10n/app_localizations.dart';
import 'package:http/http.dart' as http;
import 'package:proxypin/network/util/logger.dart';
import 'package:proxypin/ui/app_update/remote_version_entity.dart';
import 'package:proxypin/ui/component/app_dialog.dart';
import 'package:proxypin/ui/configuration.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'constants.dart';
import 'new_version_dialog.dart';

import 'package:proxypin/ui/mobile/dataswarm/config.dart';

class AppUpdateRepository {
  static final HttpClient httpClient = HttpClient();

  static Future<void> checkUpdate(BuildContext context, {bool canIgnore = true, bool showToast = false}) async {
    try {
      var lastVersion = await getLatestVersion();
      if (lastVersion == null) {
        logger.w("[AppUpdate] failed to fetch latest version info");
        return;
      }

      if (!context.mounted) return;
      var packageInfo = await PackageInfo.fromPlatform();
      var availableUpdates = compareVersions(packageInfo.version, lastVersion.version);
      if (availableUpdates) {
        if (canIgnore && !lastVersion.isForceUpdate) {
          var ignoreVersion = await SharedPreferencesAsync().getString(Constants.ignoreReleaseVersionKey);
          if (ignoreVersion == lastVersion.version) {
            logger.d("ignored release [${lastVersion.version}]");
            return;
          }
        }

        logger.d("new version available: $lastVersion");

        if (!context.mounted) return;
        NewVersionDialog(
          AppConfiguration.version,
          lastVersion,
          canIgnore: !lastVersion.isForceUpdate,
        ).show(context);
        return;
      }

      logger.i("already using latest version[${AppConfiguration.version}], last: [${lastVersion.version}]");

      if (showToast) {
        AppLocalizations localizations = AppLocalizations.of(context)!;
        CustomToast.success(localizations.appUpdateNotAvailableMsg).show(context);
      }
    } catch (e) {
      logger.e("Error checking for updates: $e");
      if (showToast) {
        CustomToast.error(e.toString()).show(context);
      }
    }
  }

  /// Fetches the latest version information from the custom server.
  static Future<RemoteVersionEntity?> getLatestVersion({bool includePreReleases = false}) async {
    try {
      final response = await http.get(Uri.parse(await SwarmForagerConfig.checkUpdateUrl));
      Map<String, dynamic> result = jsonDecode(response.body);
      if (!result['ok'] || result['data'] == null) {
        logger.w("[AppUpdate] failed to fetch latest version info");
        return null;
      }

      return RemoteVersionEntity(
          version: result['data']['version'],
          buildNumber: "",
          releaseTag: "v${result['data']['version']}",
          preRelease: false,
          url: result['data']['download_url'],
          content: result['data']['changelog'],
          publishedAt: DateTime.now(),
          isForceUpdate: result['data']['is_force_update'] ?? false);
    } catch (e) {
      logger.e("[AppUpdate] failed to fetch latest version info: $e");
      return null;
    }
  }

  static bool compareVersions(String currentVersion, String latestVersion) {
    String normalizeVersion(String version) {
      return version.startsWith('v') ? version.substring(1) : version;
    }

    List<int> parseVersion(String version) {
      return normalizeVersion(version).split('.').map(int.parse).toList();
    }

    List<int> current = parseVersion(currentVersion);
    List<int> latest = parseVersion(latestVersion);

    for (int i = 0; i < current.length; i++) {
      if (i >= latest.length || current[i] > latest[i]) {
        return false; // 当前版本高于最新版本
      } else if (current[i] < latest[i]) {
        return true; // 需要更新
      }
    }

    return latest.length > current.length; // 最新版本有更多的子版本号
  }
}
