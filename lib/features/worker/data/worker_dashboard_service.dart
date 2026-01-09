import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/config/api_config.dart';
import '../../../../features/auth/data/auth_service.dart';

class WorkerDashboardService {
  static Future<Map<String, dynamic>> getWorkerFeed() async {
    final token = await AuthService.getToken();
    if (token == null) return {'success': false, 'message': 'Not authenticated'};

    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/jobs/feed'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'data': data['data']};
      }
      return {'success': false, 'message': data['message'] ?? 'Failed to load jobs'};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> getMyJobs({String? status}) async {
    final token = await AuthService.getToken();
    if (token == null) return {'success': false, 'message': 'Not authenticated'};

    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/jobs/my-jobs').replace(queryParameters: status != null ? {'status': status} : null);
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'data': data['data']};
      }
      return {'success': false, 'message': data['message'] ?? 'Failed to load jobs'};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }
}
