import 'package:fk_webview/src/event/events.dart';
import 'package:flutter/material.dart';

import 'base_page_presenter.dart';
import 'webview_iview.dart';

class WebViewPresenter extends BasePagePresenter<WebViewIMvpView> {
  @override
  void afterFirstLayout() {
    super.afterFirstLayout();
    eventBus.on<WebViewUIEvent>().listen((event) {
      switch (event.name) {
        case 'setOptionMenu':
          view?.setOptionMenu(event.data);
          break;
        case 'setTitle':
          view?.setTitle(event.data);
          break;
        case 'setAutoTitle':
          view?.setAutoTitle(event.data);
          break;
        case 'setImmersive':
          view?.setImmersive(event.data);
          break;
        case 'hideNav':
          view?.hideNav(event.data);
          break;
        case 'closeWindow':
          _closeWindow();
          break;
        case 'refresh':
          view?.refresh(event.data);
          break;
        default:
          break;
      }
    });
  }

  void onWebViewReday() async {
    String platformReadyJS = "window.dispatchEvent(new Event('FKWebViewReady'));";
    await view?.webViewController.evaluateJavascript(source: platformReadyJS);
  }

  void onWebViewDispose() async {
    String platformReadyJS = "window.dispatchEvent(new Event('FKWebViewDispose'));";
    await view?.webViewController.evaluateJavascript(source: platformReadyJS);
  }

  @override
  void deactivate() {
    onWebViewDispose();
    super.deactivate();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _closeWindow() {
    if (view != null) {
      Navigator.pop(view!.getContext());
    }
  }
}
