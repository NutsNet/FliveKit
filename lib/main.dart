import 'package:flutter/material.dart';

import 'package:flivekit/scaffold.dart';
import 'package:flivekit/tools.dart';

void main() {
  const scaffoldWidget = ScaffoldWidget();

  Tools().toolsSetParams();

  runApp(const MaterialApp(
    title: 'FliveKit',
    debugShowCheckedModeBanner: false,
    home: scaffoldWidget,
  ));
}
