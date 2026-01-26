/*
 * Copyright 2024 Hongen Wang All rights reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      https://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import 'dart:async';
import 'dart:convert';
import 'package:proxypin/network/http/http.dart';
import 'package:proxypin/ui/mobile/dataswarm/common.dart';
import 'package:proxypin/ui/mobile/dataswarm/config.dart';
import 'interceptor.dart';

class SwarmInterceptor extends Interceptor {
  @override
  int get priority => 10; // 优先级可以根据需要调整
  static String rawTask = '';
  @override
  Future<HttpRequest?> onRequest(HttpRequest request) async {
    String host = request.hostAndPort?.host ?? request.requestUri?.host ?? '';

    if (host.isEmpty) {
      return request;
    }
    if (request.requestUri.toString().contains(SwarmForagerConfig.serverUrl)) {
      (await baseHeaders()).forEach((key, value) {
        request.headers.set(key, value);
      });
    }
    return request;
  }

  @override
  Future<HttpResponse?> onResponse(HttpRequest request, HttpResponse response) async {
    if (request.requestUri.toString().contains(await SwarmForagerConfig.pullTaskUrl)) {
      if (response.body != null) {
        // 使用 utf8.decode 将 List<int> 转换为字符串
        rawTask = utf8.decode(response.body!);
      }
    }
    return response;
  }
}
