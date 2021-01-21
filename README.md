# fk_webview

[![Pub](https://img.shields.io/pub/v/fk_webview.svg)](https://pub.dartlang.org/packages/fk_webview)
[![Awesome Flutter](https://img.shields.io/badge/Awesome-Flutter-blue.svg?longCache=true&style=flat-square)]()
[![Awesome Flutter](https://img.shields.io/badge/Platform-Android_iOS-blue.svg?longCache=true&style=flat-square)]()
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](/LICENSE)

基于 `flutter_inappwebview` 的二次封装

## 使用

🔩 安装

在 `pubspec.yaml` 添加依赖

```
dependencies:
  fk_webview: <last_version>
```

⚙️ 配置

#### iOS

要支持HTTP请求：您需要禁用Apple Transport Security（ATS）功能。有两种选择：

1. 仅针对特定域禁用ATS( [Official wiki](https://developer.apple.com/documentation/bundleresources/information_property_list/nsapptransportsecurity/nsexceptiondomains) )：（将以下代码添加到您的Info.plist文件中）

```xml
<key>NSAppTransportSecurity</key>
<dict>
  <key>NSExceptionDomains</key>
  <dict>
    <key>www.yourserver.com</key>
    <dict>
      <!-- add this key to enable subdomains such as sub.yourserver.com -->
      <key>NSIncludesSubdomains</key>
      <true/>
      <!-- add this key to allow standard HTTP requests, thus negating the ATS -->
      <key>NSTemporaryExceptionAllowsInsecureHTTPLoads</key>
      <true/>
      <!-- add this key to specify the minimum TLS version to accept -->
      <key>NSTemporaryExceptionMinimumTLSVersion</key>
      <string>TLSv1.1</string>
    </dict>
  </dict>
</dict>
```

2. 完全禁用ATS( [Official wiki](https://developer.apple.com/documentation/bundleresources/information_property_list/nsapptransportsecurity/nsallowsarbitraryloads) )：（在您的Info.plist文件中添加以下代码）

```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key><true/>
</dict>
```

其他 Info.plist 属性：

- `NSAllowsLocalNetworking`: 设置为**true**以支持加载本地网络资源 ([Official wiki](https://developer.apple.com/documentation/bundleresources/information_property_list/nsapptransportsecurity/nsallowslocalnetworking))
- `NSAllowsArbitraryLoadsInWebContent`: 针对从webview发出的网络请求 ([Official wiki](https://developer.apple.com/documentation/bundleresources/information_property_list/nsapptransportsecurity/nsallowsarbitraryloadsinwebcontent))

#### Android

支持http网络 [官方文档](https://developer.android.com/training/articles/security-config#CleartextTrafficPermitted)

要支持所有的http请求, 需要在 `res/xml/network_security_config.xml` 配置如下代码:

```xml
<?xml version="1.0" encoding="utf-8"?>
<network-security-config>
    <base-config cleartextTrafficPermitted="true">
        <trust-anchors>
            <certificates src="system" />
        </trust-anchors>
    </base-config>
</network-security-config>
```

然后打开 `AndroidManifest.xml` , 根据如下代码进行配置：

```xml
<?xml version="1.0" encoding="utf-8"?>
<manifest ... >
    <application android:networkSecurityConfig="@xml/network_security_config"
                    ... >
        ...
    </application>
</manifest>
``` 

在 Android 端, 如果需要支持 `<input type="file" accept="image/*" capture>` HTML标签, 则需在 `android/app/src/main/AndroidManifest.xml` 文件的 `<application>` 标签中配置如下：

```xml
<provider
    android:name="com.pichillilorenzo.flutter_inappwebview.InAppWebViewFileProvider"
    android:authorities="${applicationId}.flutter_inappwebview.fileprovider"
    android:exported="false"
    android:grantUriPermissions="true">
    <meta-data
        android:name="android.support.FILE_PROVIDER_PATHS"
        android:resource="@xml/provider_paths" />
</provider>
```

更多其他的配置, 请参考 [flutter_inappwebview](https://github.com/pichillilorenzo/flutter_inappwebview/blob/master/README.md)

🔨 使用

```dart
import 'package:fk_webview/fk_webview.dart';
```

#### 初始化 FkWebView

```dart
FKWebView(
  initialUrl: 'yoururl',
  initialData: '<html><body><h1>test</h1></body></html>',
  initialFile: 'assets/html/index.html', config: FKWebViewConfig());
```

#### FKWebViewConfig

...