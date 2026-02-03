import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/config/api_config.dart';
import '../../../../features/auth/data/auth_service.dart';

class WorkerIdentityService {
  
  // Fetch the full digital passport for a worker
  static Future<Map<String, dynamic>> getSkillPassport(String userId) async {
    final token = await AuthService.getToken();
    if (token == null) return {'success': false, 'message': 'Not authenticated'};

    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/workers/$userId/passport'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'data': data['data']};
      }
      return {'success': false, 'message': data['message'] ?? 'Failed to load passport'};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }
}
