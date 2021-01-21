import 'package:fk_webview/src/handler/javascript_handler_interceptor.dart';

import 'fk_webview_error.dart';

class FKWebViewConfig {
  const FKWebViewConfig(
      {this.title,
      this.autoTitle = true,
      this.showNavBarItem = true,
      this.immersive = false,
      this.initialHeaders,
      this.errorLangDelegate,
      this.customJavaScriptHandler,
      this.javaScriptHandlerInterceptor});

  final String title;
  final bool autoTitle;
  final bool showNavBarItem;
  final bool immersive;

  final Map<String, dynamic> initialHeaders;

  final FKWebViewErrorLangDelegate errorLangDelegate;

  /// 自定义 JavaScript 处理器
  final List<JavaScriptHandler> customJavaScriptHandler;
  final JavaScriptHandlerInterceptor javaScriptHandlerInterceptor;

  FKWebViewErrorLangDelegate get errorLang => errorLangDelegate ?? DefaultFKWebViewErrorLangDelegate();

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
