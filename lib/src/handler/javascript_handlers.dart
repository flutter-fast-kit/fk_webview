import 'package:connectivity/connectivity.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import 'javascript_handler_interceptor.dart';
import 'javascript_handler_manager.dart';

/// 判断当前客户端是否支持指定JS接口
class CheckJsApiHandler implements JavaScriptHandlerBase {
  @override
  Future<JavaScriptHandlerResult> handle(List<dynamic> args) async {
    final jsApiList = args[0]['jsApiList'] as List;
    final _supportApi = JavaScriptHandlerManager.supportApi.map((e) => e.name).toList();

    final result = {};
    jsApiList.forEach((_apiName) {
      result[_apiName] = _supportApi.contains(_apiName);
    });

    return JavaScriptHandlerResult(data: result);
  }
}

/// 获取网络状态接口
class NetworkTypeHandler implements JavaScriptHandlerBase {
  @override
  Future<JavaScriptHandlerResult> handle(List<dynamic> args) async {
    final connectivityResult = await (Connectivity().checkConnectivity());
    return JavaScriptHandlerResult(data: connectivityResult.value);
  }
}

extension ConnectivityResultExtension on ConnectivityResult {
  String get value => ['wifi', 'mobile', 'none'][index];
}

/// 获取系统剪切板内容
class GetClipboardHandler implements JavaScriptHandlerBase {
  @override
  Future<JavaScriptHandlerResult> handle(List<dynamic> args) async {
    ClipboardData? clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
    return JavaScriptHandlerResult(data: clipboardData?.text);
  }
}

/// 设置内容到剪切板
class SetClipboardHandler implements JavaScriptHandlerBase {
  @override
  Future<JavaScriptHandlerResult> handle(List<dynamic> args) async {
    ClipboardData data = ClipboardData(text: args[0]);
    await Clipboard.setData(data);
    return JavaScriptHandlerResult();
  }
}

/// 是否可打开
class UrlSchemeCanOpenHandler implements JavaScriptHandlerBase {
  @override
  Future<JavaScriptHandlerResult> handle(List<dynamic> args) async {
    bool canOpen = await canLaunch(args[0]);
    return JavaScriptHandlerResult(data: canOpen);
  }
}

/// 调用 URLScheme
class UrlSchemeOpenHandler implements JavaScriptHandlerBase {
  @override
  Future<JavaScriptHandlerResult> handle(List<dynamic> args) async {
    await launch(args[0]);
    return JavaScriptHandlerResult();
  }
}

/// 打开系统浏览器
class OpenDefaultBrowserHandler implements JavaScriptHandlerBase {
  @override
  Future<JavaScriptHandlerResult> handle(List<dynamic> args) async {
    await launch(args[0], forceSafariVC: true);
    return JavaScriptHandlerResult();
  }
}
