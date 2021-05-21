import 'dart:io';
import 'dart:ui';

import 'package:fk_action_sheet/fk_action_sheet.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart';

import 'handler/javascript_handler_manager.dart';
import 'models/fk_webview_config.dart';
import 'models/fk_webview_error.dart';
import 'mvp/base_page.dart';
import 'mvp/webview_iview.dart';
import 'mvp/webview_presenter.dart';

class FKWebView extends StatefulWidget {
  final String? initialUrl;
  final String? initialData;
  final String? initialFile;

  final FKWebViewConfig? config;

  final void Function(InAppWebViewController controller)? onWebViewCreated;

  const FKWebView(
      {this.initialUrl,
      this.initialData,
      this.initialFile,
      this.onWebViewCreated,
      this.config = const FKWebViewConfig()});

  @override
  _FKWebViewState createState() => new _FKWebViewState();
}

class _FKWebViewState extends State<FKWebView>
    with SingleTickerProviderStateMixin, BasePageMixin<FKWebView, WebViewPresenter>
    implements WebViewIMvpView {
  InAppWebViewController? _webViewController;

  // ContextMenu contextMenu;

  late FKWebViewConfig _fkWebViewConfig;

  // CookieManager _cookieManager = CookieManager.instance();

  /// 网页标题
  ValueNotifier<String> _title = ValueNotifier<String>('');

  /// Progress
  ValueNotifier<double> _progress = ValueNotifier<double>(0);

  /// 是否显示导航栏
  ValueNotifier<bool> _showNavBarItem = ValueNotifier<bool>(true);

  /// 是否沉浸式导航
  ValueNotifier<bool> _immersive = ValueNotifier<bool>(false);

  /// 是否显示右上角按钮
  ValueNotifier<bool> _showActionItem = ValueNotifier<bool>(true);

  /// 是否显示底部栏
  ValueNotifier<bool> _showCloseButton = ValueNotifier<bool>(false);

  /// onError
  ValueNotifier<FKWebViewError> _onWebViewError = ValueNotifier<FKWebViewError>(FKWebViewError.noError());

  bool _autoTitle = true;

  @override
  void initState() {
    super.initState();
    if (widget.config != null) {
      _fkWebViewConfig = widget.config!;
    } else {
      _fkWebViewConfig = FKWebViewConfig();
    }

    if (_fkWebViewConfig.title != null && _fkWebViewConfig.title!.isNotEmpty) {
      _title.value = _fkWebViewConfig.title!;
    }

    if (_fkWebViewConfig.immersive != _immersive.value) {
      _immersive.value = _fkWebViewConfig.immersive;
    }

    if (_fkWebViewConfig.showNavBarItem != _showNavBarItem.value) {
      _showNavBarItem.value = _fkWebViewConfig.showNavBarItem;
    }

    if (_fkWebViewConfig.autoTitle != _autoTitle) {
      _autoTitle = _fkWebViewConfig.autoTitle;
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _progress.dispose();
    _showNavBarItem.dispose();
    _showCloseButton.dispose();
    _immersive.dispose();
    _showActionItem.dispose();
    _onWebViewError.dispose();
    super.dispose();
  }

  /// 注册 JavaScriptHandler
  void _addJavaScriptHandler() {
    JavaScriptHandlerManager.registerHandlers(
        _webViewController!, widget.config?.javaScriptHandlerInterceptor, widget.config?.customJavaScriptHandler);
  }

  Widget _buildBody() {
    return ValueListenableBuilder<bool>(
        valueListenable: _showNavBarItem,
        builder: (BuildContext context, bool showNavigator, Widget? child) {
          return SafeArea(
              top: showNavigator,
              child: Padding(
                padding: EdgeInsets.only(top: showNavigator ? 0 : 0), // window.padding.top / window.devicePixelRatio
                child: child,
              ));
        },
        child: Stack(
          children: [
            Column(children: <Widget>[
              Expanded(
                child: Container(
                  child: InAppWebView(
                    // contextMenu: contextMenu,
                    /// 加载链接
                    // initialUrl:
                    //     "https://customer.aitdcoin.com/help/index.html?v=v3&name=16716582401&mobile=16716582401&email=&trueName=&userSn=975181&userId=c6a474edbc2946159047f5e4ef8a071d&isAuth=1&language=en_US&resion=app_home&belong=2&size=375.0x667.0&device=2&appname=sgp&appid=0p55p1&deviceversion=11.4.1&phonemodel=iPhone&appversion=3.0.0",
                    initialUrlRequest: widget.initialUrl != null
                        ? URLRequest(url: Uri.parse(widget.initialUrl!), headers: _fkWebViewConfig.initialHeaders)
                        : null,

                    /// 加载html代码
                    initialData: widget.initialData != null ? InAppWebViewInitialData(data: widget.initialData!) : null,
                    // InAppWebViewInitialData(data: 'null'),

                    /// 加载本地文件, 需要在 pubspec.yaml 里加入 assets
                    initialFile: widget.initialFile,
                    // "assets/index.html",

                    /// webView 初始化配置
                    initialOptions: InAppWebViewGroupOptions(
                        crossPlatform: InAppWebViewOptions(
                          clearCache: kDebugMode,
                          useShouldOverrideUrlLoading: true,

                          /// 禁用缩放
                          supportZoom: false,
                        ),
                        android: AndroidInAppWebViewOptions(useHybridComposition: true)),
                    onWebViewCreated: (InAppWebViewController controller) {
                      _webViewController = controller;
                      print("FKWebView: onWebViewCreated");
                      if (widget.onWebViewCreated != null) {
                        widget.onWebViewCreated!(_webViewController!);
                      }
                      _addJavaScriptHandler();
                    },
                    onLoadStart: (InAppWebViewController controller, Uri? url) {
                      print("FKWebView: onLoadStart ${url.toString()}");
                      _progress.value = 5 / 100;
                    },
                    shouldOverrideUrlLoading: (controller, shouldOverrideUrlLoadingRequest) async {
                      Uri? uri = shouldOverrideUrlLoadingRequest.request.url;

                      if (!["http", "https", "file", "chrome", "data", "javascript", "about"].contains(uri?.scheme)) {
                        if (await canLaunch(uri.toString())) {
                          // Launch the App
                          await launch(
                            uri.toString(),
                          );
                          // and cancel the request
                          return NavigationActionPolicy.CANCEL;
                        }
                      }

                      return NavigationActionPolicy.ALLOW;
                    },
                    onLoadStop: (InAppWebViewController controller, Uri? uri) async {
                      print("FKWebView: onLoadStop $uri");
                      // setState(() {
                      //   this.url = url;
                      // });
                      presenter?.onWebViewReday();
                      _onWebViewError.value = FKWebViewError(code: FKWebViewError.noError().code);
                    },
                    onProgressChanged: (InAppWebViewController controller, int progress) {
                      _progress.value = progress / 100;
                    },
                    onTitleChanged: (InAppWebViewController controller, String? title) async {
                      print('FKWebView: 当前标题为: $title');
                      if (_autoTitle) {
                        _title.value = title ?? '';
                      }
                      _showCloseButton.value = await controller.canGoBack();
                    },
                    onConsoleMessage: (controller, consoleMessage) {
                      print('JS Console: $consoleMessage}');
                    },
                    onLoadError: (InAppWebViewController controller, Uri? uri, int code, String message) {
                      print('FKWebView: 加载错误: $code , $message');
                      _onWebViewError.value = FKWebViewError(url: uri.toString(), code: code, message: message);
                      _progress.value = 0;
                      _title.value = 'error';
                    },
                    onLoadHttpError: (InAppWebViewController controller, Uri? uri, int statusCode, String description) {
                      print('FKWebView: http加载错误: $statusCode , $description');
                      _onWebViewError.value =
                          FKWebViewError(url: uri.toString(), code: statusCode, message: description);
                      _progress.value = 0;
                      _title.value = 'error';
                    },
                  ),
                ),
              ),
            ]),

            /// 错误页面
            ValueListenableBuilder<FKWebViewError>(
                valueListenable: _onWebViewError,
                builder: (BuildContext context, FKWebViewError error, Widget? child) {
                  bool isHttpError = (error.code >= 100 && error.code <= 600);
                  return error.code != FKWebViewError.noError().code
                      ? Center(
                          child: GestureDetector(
                            child: Container(
                              color: Colors.white,
                              width: double.infinity,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    height: MediaQuery.of(context).size.height / 4,
                                  ),
                                  Image(
                                    image: AssetImage('assets/images/network-error.png', package: 'fk_webview'),
                                    width: 120,
                                  ),
                                  SizedBox(
                                    height: 25,
                                  ),
                                  Text(
                                    _fkWebViewConfig.errorLang.errorTitle,
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  // Text(error.url),
                                  // SizedBox(
                                  //   height: 10,
                                  // ),
                                  // Text(
                                  //   '${error.message} (${error.code})',
                                  //   style: TextStyle(color: Colors.black54),
                                  // ),
                                  Opacity(
                                    opacity: isHttpError ? 1 : 0,
                                    child: Text(_fkWebViewConfig.errorLang.reloadButtonTitle),
                                  )
                                ],
                              ),
                            ),
                            onTap: () async {
                              if (isHttpError) {
                                _onWebViewError.value = FKWebViewError.noError();
                                await _webViewController?.reload();
                              }
                            },
                          ),
                        )
                      : SizedBox();
                }),

            /// webView 进度条
            ValueListenableBuilder<double>(
                valueListenable: _progress,
                builder: (BuildContext context, double progress, Widget? child) {
                  return AnimatedOpacity(
                    opacity: progress < 1 ? 1 : 0,
                    duration: Duration(milliseconds: 100),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 2,
                      backgroundColor: Colors.white,
                    ),
                  );
                }),
          ],
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Scaffold(
          backgroundColor: Colors.transparent,
          extendBodyBehindAppBar: true,
          appBar: PreferredSize(
            child: ValueListenableBuilder<bool>(
                valueListenable: _immersive,
                builder: (BuildContext context, bool immersive, Widget? child) {
                  final appBar = AppBar(
                      brightness: Brightness.light,
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.black,
                      elevation: 0,
                      automaticallyImplyLeading: false,
                      // elevation: 0.5,
                      centerTitle: true,
                      title: immersive
                          ? SizedBox()
                          : ValueListenableBuilder<String>(
                              valueListenable: _title,
                              builder: (BuildContext context, String title, Widget? child) {
                                return Text(title,
                                    overflow: TextOverflow.fade, style: TextStyle(color: Colors.black87, fontSize: 18));
                              },
                            ),
                      leadingWidth: 80,
                      leading: immersive
                          ? null
                          : Row(
                              children: [
                                IconButton(
                                    icon: Icon(
                                      Icons.arrow_back_ios_rounded,
                                      color: Colors.black,
                                    ),
                                    onPressed: () async {
                                      if (_webViewController != null) {
                                        if (await _webViewController!.canGoBack()) {
                                          _webViewController!.goBack();
                                        } else {
                                          Navigator.pop(context);
                                        }
                                      }
                                    }),
                                ValueListenableBuilder<bool>(
                                    valueListenable: _showCloseButton,
                                    builder: (BuildContext context, bool showBottomBar, Widget? child) {
                                      return showBottomBar
                                          ? InkWell(
                                              child: Padding(
                                                padding: EdgeInsets.fromLTRB(4, 6, 0, 6),
                                                child: Icon(
                                                  Icons.close_sharp,
                                                  color: Colors.black,
                                                  size: 28,
                                                ),
                                              ),
                                              onTap: () async {
                                                Navigator.pop(context);
                                              })
                                          : SizedBox();
                                    }),
                              ],
                            ),
                      actions: immersive
                          ? []
                          : [
                              ValueListenableBuilder<bool>(
                                valueListenable: _showActionItem,
                                builder: (BuildContext context, bool showItem, Widget? child) {
                                  if (showItem) {
                                    return IconButton(
                                        icon: Icon(
                                          Icons.more_horiz_sharp,
                                          color: Colors.black,
                                        ),
                                        onPressed: () async {
                                          Uri? currentUrl = await _webViewController?.getUrl();
                                          showActionSheet(
                                              context: context,
                                              topActionItem: TopActionItem(title: '请选择操作', desc: currentUrl?.host),
                                              actions: <ActionItem>[
                                                ActionItem(
                                                    title: "复制链接",
                                                    onPressed: () async {
                                                      Clipboard.setData(ClipboardData(text: currentUrl.toString()));
                                                      Navigator.pop(context);
                                                    }),
                                                ActionItem(
                                                    title: "刷新",
                                                    onPressed: () async {
                                                      _onWebViewError.value = FKWebViewError.noError();
                                                      await _webViewController?.reload();
                                                      Navigator.pop(context);
                                                    }),
                                              ],
                                              bottomActionItem: BottomActionItem(title: "取消"));
                                        });
                                  }
                                  return SizedBox();
                                },
                              )
                            ]);
                  if (immersive) {
                    return Listener(
                      behavior: HitTestBehavior.translucent,
                      child: IgnorePointer(
                        child: appBar,
                      ),
                    );
                  }
                  return appBar;
                }),
            preferredSize: Size.fromHeight(kToolbarHeight),
          ),
          body: Platform.isAndroid
              ? WillPopScope(
                  child: _buildBody(),
                  onWillPop: () async {
                    if (_webViewController != null) {
                      if (await _webViewController!.canGoBack()) {
                        _webViewController!.goBack();
                        return false;
                      }
                    }
                    return true;
                  })
              : _buildBody()),
    );
  }

  @override
  WebViewPresenter createPresenter() => WebViewPresenter();

  @override
  InAppWebViewController get webViewController => _webViewController!;

  @override
  void hideNav(bool hide) {
    if (_showNavBarItem.value != !hide) {
      _showNavBarItem.value = !hide;
    }
  }

  @override
  void setAutoTitle(bool auto) {
    if (_autoTitle != !auto) {
      _autoTitle = !auto;
    }
  }

  @override
  void setImmersive(bool hide) {
    if (_immersive.value != hide) {
      _immersive.value = hide;
    }
  }

  @override
  void setOptionMenu(bool hide) {
    if (_showActionItem.value != !hide) {
      _showActionItem.value = !hide;
    }
  }

  @override
  void setTitle(String title) {
    if (_title.value != _title) {
      _title.value = title;
    }
  }
}
