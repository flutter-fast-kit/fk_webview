import 'package:flutter/foundation.dart';

@immutable
class FKWebViewError {
  final String url;
  final int code;
  final String message;

  const FKWebViewError(this.url, this.code, this.message);
}

abstract class FKWebViewErrorLangDelegate {
  String errorTitle;
  String reloadButtonTitle;
}

class DefaultFKWebViewErrorLangDelegate implements FKWebViewErrorLangDelegate {
  factory DefaultFKWebViewErrorLangDelegate() => _instance;

  DefaultFKWebViewErrorLangDelegate._internal();

  static final DefaultFKWebViewErrorLangDelegate _instance = DefaultFKWebViewErrorLangDelegate._internal();

  @override
  String errorTitle = "网页加载错误";

  @override
  String reloadButtonTitle = "点击重试";
}
