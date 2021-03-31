import 'package:flutter/foundation.dart';

import 'mvps.dart';

class BasePresenter<V extends IMvpView> extends IPresenter {
  V? view;

  @mustCallSuper
  @override
  void afterFirstLayout() {}

  @mustCallSuper
  @override
  void deactivate() {}

  @mustCallSuper
  @override
  void didChangeDependencies() {}

  @mustCallSuper
  @override
  void didUpdateWidgets<W>(W oldWidget) {}

  @mustCallSuper
  @override
  void dispose() {}

  @mustCallSuper
  @override
  void initState() {}
}
