import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:skillbridge_mobile/features/auth/data/auth_service.dart';
import 'app.dart';

void bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize AuthService to load saved token
  await AuthService.init();

  SystemChrome.setPreferredOrientations(const [
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const SkillBridgeApp());
}
