import 'package:fk_webview/src/event/events.dart';

import 'javascript_handler_interceptor.dart';
import 'javascript_handler_manager.dart';
import 'javascript_handlers.dart';

class JavaScriptHandlerDispatcher {
  static dynamic disPatcher(JavaScriptHandler handler, List<dynamic> args) async {
    print('[JS侧消息] - [handlerName: ${handler.name}] - [args: ${args.toString()}]');
    JavaScriptHandlerResult _result;
    try {
      _result = await _patcher(handler, args);
    } catch (e) {
      print('JavaScriptHandlerDispatcher: $e');
      _result = JavaScriptHandlerResult(success: false, message: e.toString());
    }
    print(
        '[Native侧消息] - [handlerName: ${handler.name}] - [args: ${args.toString()}] - [result: ${_result.toString()}]');
    return _result.toMap();
  }

  static dynamic _patcher(JavaScriptHandler handler, List<dynamic> args) async {
    JavaScriptHandlerResult? _result;

    /// 有限匹配自定义处理器
    if (JavaScriptHandlerManager.handlerInterceptor != null) {
      _result = await JavaScriptHandlerManager.handlerInterceptor?.handler(handler, args);
    }

    /// 如果没有匹配到自定义处理器, 则使用默认方式
    if (_result != null) {
      return _result;
    }

    switch (handler.name) {
      case 'checkJsApi':
        _result = await CheckJsApiHandler().handle(args);
        break;
      case 'getNetworkType':
        _result = await NetworkTypeHandler().handle(args);
        break;
      case 'getClipboard':
        _result = await GetClipboardHandler().handle(args);
        break;
      case 'setClipboard':
        _result = await SetClipboardHandler().handle(args);
        break;
      case 'urlSchemeCanOpen':
        _result = await UrlSchemeCanOpenHandler().handle(args);
        break;
      case 'urlSchemeOpen':
        _result = await UrlSchemeOpenHandler().handle(args);
        break;
      case 'refresh':
      case 'setOptionMenu':
      case 'setTitle':
      case 'setAutoTitle':
      case 'setImmersive':
      case 'hideNav':
      case 'closeWindow':
        eventBus.fire(WebViewUIEvent(name: handler.name, data: args.length > 0 ? args[0] : null));
        _result = JavaScriptHandlerResult();
        break;
      default:
        {
          return null;
        }
        break;
    }
    return _result;
  }
}
