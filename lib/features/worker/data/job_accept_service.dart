import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/config/api_config.dart';
import '../../../../features/auth/data/auth_service.dart';

class JobAcceptService {
  static Future<Map<String, dynamic>> getJobDetails(String jobId) async {
    final token = await AuthService.getToken();
    if (token == null) return {'success': false, 'message': 'Not authenticated'};

    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/jobs/$jobId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'data': data['data']};
      }
      return {'success': false, 'message': data['message']};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> acceptJob(String jobId) async {
    final token = await AuthService.getToken();
    if (token == null) return {'success': false, 'message': 'Not authenticated'};

    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/jobs/$jobId/accept'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'message': data['message']};
      }
      return {'success': false, 'message': data['message']};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }
}
