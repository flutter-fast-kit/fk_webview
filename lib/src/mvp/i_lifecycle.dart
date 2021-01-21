abstract class ILifecycle {
  /// 页面初始化
  ///
  /// 来源: Flutter
  void initState();

  /// 此方法为 [WidgetsBinding.instance.addPostFrameCallback] 包装实现
  ///
  /// 来源：自定义
  void afterFirstLayout();

  /// “依赖”发生变化时
  ///
  /// 来源: Flutter
  void didChangeDependencies();

  /// 当组件状态发生改变
  ///
  /// 来源: Flutter
  void didUpdateWidgets<W>(W oldWidget);

  /// 将要销毁
  void deactivate();

  /// 页面销毁
  ///
  /// 主要用于移除监听
  ///
  /// 来源：Flutter
  void dispose();
}
