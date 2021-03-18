import 'dart:async';
import 'dart:io';

import 'package:fk_webview/fk_webview.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sgpexchange/pages/main/handler/biz_javascript_handler.dart';
import 'package:sgpexchange/widgets/my_app_bar.dart';

/// 支持的JSHandle列表
const _bizHandlers = [
  JavaScriptHandler('scanQRCode'),
  JavaScriptHandler('getUserInfo'),
  JavaScriptHandler('chooseImage'),
  JavaScriptHandler('previewImage'),
  JavaScriptHandler('saveToAlbum'),
  JavaScriptHandler('toNative'),
  JavaScriptHandler('closeWindow'),
];

/// 类型
enum URL_TYPE {
  URL,
  HTML,
  ASSETS,
}

class FWebViewPage extends StatefulWidget {
  final URL_TYPE urlType;
  final Future<String> Function(BuildContext context) urlBuilder;

  final String title;
  final bool autoTitle;
  final bool showNavBarItem;
  final bool immersive;
  final bool isSafeArea;

  const FWebViewPage(
      {this.urlType = URL_TYPE.URL,
      this.urlBuilder,
      this.title,
      this.autoTitle = true,
      this.showNavBarItem = true,
      this.immersive = false,
      this.isSafeArea = true});

  @override
  _FWebViewPageState createState() => _FWebViewPageState();
}

class _FWebViewPageState extends State<FWebViewPage> {
  final Completer<String> _requestURL = Completer<String>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      Future.delayed(Duration.zero, () async {
        try {
          final String url = await widget.urlBuilder(context);
          _requestURL.complete(url);
        } catch (e) {
          _requestURL.completeError('error');
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: FutureBuilder<String>(
          future: _requestURL.future,
          builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
            if (snapshot.hasData) {
              return SafeArea(
                  top: widget.isSafeArea,
                  child: FKWebView(
                    initialUrl: snapshot.data,
                    config: FKWebViewConfig(
                        title: widget.title,
                        autoTitle: widget.autoTitle,
                        showNavBarItem: widget.showNavBarItem,
                        immersive: widget.immersive,
                        customJavaScriptHandler: _bizHandlers,
                        javaScriptHandlerInterceptor: BizJavaScriptHandlerInterceptor(context)),
                  ));
            } else if (snapshot.hasError) {
              return const Scaffold(
                appBar: MyAppBar(
                  centerTitle: '错误',
                ),
                body: Center(
                  child: Text(
                    '无法加载此网页!',
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                ),
              );
            }
            return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 18,
                    height: 18,
                    child: Platform.isIOS ? const CupertinoActivityIndicator() : const CircularProgressIndicator(),
                  )
                ]);
          }),
    );
  }
}

class BizJavaScriptHandlerInterceptor implements JavaScriptHandlerInterceptor {
  final BuildContext context;

  BizJavaScriptHandlerInterceptor(this.context);

  @override
  Future<JavaScriptHandlerResult> handler(JavaScriptHandler handler, List<dynamic> args) async {
    switch (handler.name) {
      case 'scanQRCode':
        return ScanQRCodeHandler(context).handle(args);
        break;
      case 'getUserInfo':
        return GetUserInfoHandler().handle(args);
        break;
      case 'chooseImage':
        return ChooseImageHandler(context).handle(args);
        break;
      case 'previewImage':
        return PreviewImageHandler(context).handle(args);
        break;
      case 'saveToAlbum':
        return SaveToAlbumHandler().handle(args);
        break;
      case 'toNative':
        return ToNativeHandler(context).handle(args);
        break;
      case 'closeWindow':
        return CloseWindowHandler(context).handle(args);
        break;
      default:
        return null;
        break;
    }
  }
}
