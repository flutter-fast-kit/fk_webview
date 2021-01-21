import 'base_presenter.dart';
import 'mvps.dart';

class BasePagePresenter<V extends IMvpView> extends BasePresenter<V> {
  @override
  void dispose() {
    super.dispose();
  }
}
