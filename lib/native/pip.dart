import 'dart:io';

import 'package:flutter/services.dart';
import 'package:proxypin/network/util/logger.dart';
import 'package:proxypin/ui/mobile/dataswarm/log_page.dart';
import 'package:proxypin/utils/lang.dart';

///画中画
class PictureInPicture {
  static bool inPip = false;

  static final MethodChannel _channel = const MethodChannel('com.proxy/pictureInPicture')
    ..setMethodCallHandler((call) async {
      logger.d("pictureInPicture MethodCallHandler ${call.method}");
      if (call.method == 'cleanSession') {
        LogPageState.clear();
      } else if (call.method == 'exitPictureInPictureMode') {
        inPip = false;
      }

      return Future.value();
    });

  ///进入画中画模式
  static Future<bool> enterPictureInPictureMode() async {
    final bool enterPictureInPictureMode = await _channel.invokeMethod('enterPictureInPictureMode');
    inPip = true;

    return enterPictureInPictureMode;
  }

  ///退出画中画模式
  static Future<bool> exitPictureInPictureMode() async {
    final bool exitPictureInPictureMode = await _channel.invokeMethod('exitPictureInPictureMode');
    return exitPictureInPictureMode;
  }

  ///发送数据
  static Future<bool> addData(String text) async {
    if (Platform.isIOS && inPip) {
      _channel.invokeMethod('addData', text.fixAutoLines());
    }
    return false;
  }
}
