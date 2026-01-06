import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app.dart';

void bootstrap() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations(const [
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const SkillBridgeApp());
}

