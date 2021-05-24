import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'mvps.dart';

abstract class WebViewIMvpView implements IMvpView {
  InAppWebViewController get webViewController;

  /// 设置右上角按钮
  void setOptionMenu(bool hide);

  /// 设置标题
  void setTitle(String title);

  /// 设置自动获取标题
  void setAutoTitle(bool auto);

  /// 设置沉浸式
  void setImmersive(bool hide);

  /// 设置导航是否显示
  void hideNav(bool hide);

  /// 刷新当前URL
  /// resetCache: 是否清空缓存
  Future<void> refresh(bool resetCache);
}
