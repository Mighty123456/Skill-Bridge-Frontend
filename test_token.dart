import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('auth_token');
  
  debugPrint('🔍 Checking stored token...');
  if (token != null) {
    debugPrint('✅ Token found in storage!');
    debugPrint('📏 Token length: ${token.length}');
    debugPrint('🔑 Token preview: ${token.substring(0, token.length > 50 ? 50 : token.length)}...');
  } else {
    debugPrint('❌ No token found in storage');
  }
  
  // List all keys in SharedPreferences
  debugPrint('\n📋 All keys in SharedPreferences:');
  final keys = prefs.getKeys();
  for (var key in keys) {
    debugPrint('   - $key: ${prefs.get(key)}');
  }
}
