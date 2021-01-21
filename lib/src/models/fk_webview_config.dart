import 'package:fk_webview/src/handler/javascript_handler_interceptor.dart';

import 'fk_webview_error.dart';

class FKWebViewConfig {
  FKWebViewConfig(
      {this.title,
      this.autoTitle = true,
      this.showNavBarItem = true,
      this.immersive = false,
      this.initialHeaders,
      this.errorLangDelegate,
      this.customJavaScriptHandler,
      this.javaScriptHandlerInterceptor});

  String title;
  bool autoTitle;
  bool showNavBarItem;
  bool immersive;

  Map<String, dynamic> initialHeaders = {};

  FKWebViewErrorLangDelegate errorLangDelegate = DefaultFKWebViewErrorLangDelegate();

  /// 自定义 JavaScript 处理器
  List<JavaScriptHandler> customJavaScriptHandler;
  JavaScriptHandlerInterceptor javaScriptHandlerInterceptor;

  /// 通过URL参数进行解析
  ///
  /// [url] URL
  factory FKWebViewConfig.parse(String url) {
    Uri uri = Uri.tryParse(url);
    if (uri != null && uri.queryParameters != null) {
      Map<String, String> queryParams = uri.queryParameters;
      return FKWebViewConfig(
          title: queryParams['title'],
          showNavBarItem: _getSafeValue<bool>('showNav', queryParams, true),
          autoTitle: _getSafeValue<bool>('autoTitle', queryParams, true),
          immersive: _getSafeValue<bool>('immersive', queryParams, false));
    }
    return FKWebViewConfig();
  }
}

T _getSafeValue<T>(String key, Map<String, String> map, T defaultValue) {
  if (map.containsKey(key)) {
    return map[key] as T;
  }
  return defaultValue;
}
