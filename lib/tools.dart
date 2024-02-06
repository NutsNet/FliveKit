import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform;

enum AppDevice { ios, android }

class Tools {
  static final Tools tools = Tools._internal();

  AppDevice? appDevice;

  factory Tools() {
    return tools;
  }

  Tools._internal();

  void toolsSetParams() {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      appDevice = AppDevice.ios;
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      appDevice = AppDevice.android;
    }
  }
}
