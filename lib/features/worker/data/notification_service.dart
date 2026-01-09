import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/config/api_config.dart';
import '../../../../features/auth/data/auth_service.dart';

class NotificationService {
  static Future<List<Map<String, dynamic>>> getNotifications() async {
    final token = AuthService.token;
    if (token == null) return [];

    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/notifications'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['data']);
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<void> markAsRead(String id) async {
    final token = AuthService.token;
    if (token == null) return;

    try {
      await http.patch(
        Uri.parse('${ApiConfig.baseUrl}/notifications/$id/read'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
    } catch (_) {}
  }
}
