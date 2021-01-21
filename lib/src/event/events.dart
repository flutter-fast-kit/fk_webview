import 'package:flutter/material.dart';
import 'package:rx_event_bus/rx_event_bus.dart';

final eventBus = EventBus();

@immutable
class WebViewUIEvent {
  final String name;
  final dynamic data;
  const WebViewUIEvent({this.name, this.data});
}
