import 'package:flutter/foundation.dart';

abstract class JavaScriptHandlerInterceptor {
  Future<JavaScriptHandlerResult?> handler(JavaScriptHandler handler, List<dynamic> args);
}

@immutable
class JavaScriptHandler {
  final String name;

  const JavaScriptHandler(this.name);
}

@immutable
class JavaScriptHandlerResult {
  final bool success;
  final String? message;
  final dynamic data;

  const JavaScriptHandlerResult({this.success = true, this.message, this.data});

  dynamic toMap() {
    return {'success': success, 'message': message, 'result': data};
  }

  @override
  String toString() {
    return 'JavaScriptHandlerResult{success: $success, message: $message, data: $data}';
  }
}

abstract class JavaScriptHandlerBase {
  Future<JavaScriptHandlerResult> handle(List<dynamic> args);
}
