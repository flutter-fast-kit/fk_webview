import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'javascript_handler_dispatcher.dart';
import 'javascript_handler_interceptor.dart';

class JavaScriptHandlerManager {
  static List<JavaScriptHandler> _defaultJavascriptHandler = [
    /// 基础接口
    JavaScriptHandler('checkJsApi'), // 判断当前客户端是否支持指定JS接口 - YES

    /// 业务接口
    // JavaScriptHandler('getUserInfo'), // 获取当前登录的用户信息
    // JavaScriptHandler('toNative'), // 跳转到原生页面

    /// 图像接口
    // JavaScriptHandler('chooseImage'), // 拍照或从手机相册中选图接口
    // JavaScriptHandler('previewImage'), // 预览图片接口
    // JavaScriptHandler('saveToAlbum'), // 保存图片到系统相册

    /// 设备信息接口
    JavaScriptHandler('getNetworkType'), // 获取网络状态接口 - YES

    /// 剪切板接口
    JavaScriptHandler('getClipboard'), // 获取系统剪切板内容 - YES
    JavaScriptHandler('setClipboard'), // 设置内容到剪切板 - YES

    /// URLScheme
    JavaScriptHandler('urlSchemeCanOpen'), // 是否可打开 - YES
    JavaScriptHandler('urlSchemeOpen'), // 调用 URLScheme - YES

    /// 界面操作接口
    JavaScriptHandler('setOptionMenu'), // 右上角菜单接口 - YES
    JavaScriptHandler('closeWindow'), // 关闭当前网页窗口接口 - YES
    JavaScriptHandler('setTitle'), // 设置当前页面标题 - YES
    JavaScriptHandler('setAutoTitle'), // 设置自动获取标题(默认开启) - YES
    JavaScriptHandler('setImmersive'), // 设置沉浸式 - YES
    JavaScriptHandler('hideNav'), // 隐藏导航栏 - YES

    /// 扫一扫
    // JavaScriptHandler('scanQRCode'), // scanQRCode(直接返回结果)

    /// 打开系统默认浏览器
    JavaScriptHandler('openDefaultBrowser'), // 打开系统默认浏览器 - YES
  ];

  /// 支持的所有Api
  static List<JavaScriptHandler> get supportApi => _supportApi;
  static List<JavaScriptHandler> _supportApi = [];

  static JavaScriptHandlerInterceptor? get handlerInterceptor => _handlerInterceptor;
  static JavaScriptHandlerInterceptor? _handlerInterceptor;

  /// 注册 Handlers
  static void registerHandlers(InAppWebViewController webViewController,
      JavaScriptHandlerInterceptor? customHandlerInterceptor, List<JavaScriptHandler>? customHandlers) {
    _supportApi.addAll(_defaultJavascriptHandler);
    if (customHandlers != null) {
      _supportApi.addAll(customHandlers);
    }
    _handlerInterceptor = customHandlerInterceptor;

    _supportApi.forEach((JavaScriptHandler handler) {
      webViewController.addJavaScriptHandler(
          handlerName: handler.name,
          callback: (List<dynamic> arguments) {
            try {
              return JavaScriptHandlerDispatcher.disPatcher(handler, arguments);
            } catch (e) {
              return null;
            }
          });
    });
  }

  /// 取消注册 handlers
  static void unRegisterHandlers(InAppWebViewController webViewController) {
    _supportApi.forEach((JavaScriptHandler handler) {
      webViewController.removeJavaScriptHandler(handlerName: handler.name);
    });
    _handlerInterceptor = null;
  }
}
