import 'package:flutter/material.dart';

import 'i_lifecycle.dart';

abstract class IMvpView {
  BuildContext getContext();
}

abstract class IPresenter extends ILifecycle {}
