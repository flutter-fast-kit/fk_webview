import 'package:flutter/material.dart';

import 'base_presenter.dart';
import 'mvps.dart';

mixin BasePageMixin<T extends StatefulWidget, P extends BasePresenter> on State<T> implements IMvpView {
  P presenter;

  P createPresenter();

  @override
  BuildContext getContext() {
    return context;
  }

  @override
  void didChangeDependencies() {
    presenter?.didChangeDependencies();
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    presenter?.dispose();
    super.dispose();
  }

  @override
  void deactivate() {
    presenter?.deactivate();
    super.deactivate();
  }

  @override
  void didUpdateWidget(T oldWidget) {
    presenter?.didUpdateWidgets<T>(oldWidget);
    super.didUpdateWidget(oldWidget);
  }

  @override
  void initState() {
    presenter = createPresenter();
    presenter?.view = this;
    presenter?.initState();
    super.initState();

    /// 添加 firstLayout 生命周期回调
    WidgetsBinding.instance.addPostFrameCallback((_) => afterFirstLayout(context));
  }

  @mustCallSuper
  void afterFirstLayout(BuildContext context) {
    presenter?.afterFirstLayout();
  }
}
