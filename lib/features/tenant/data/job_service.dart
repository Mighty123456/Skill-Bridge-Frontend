import 'dart:convert';
import 'package:skillbridge_mobile/core/config/api_config.dart';
import '../../auth/data/auth_service.dart';
import 'package:http/http.dart' as http;

class JobService {
  static Future<Map<String, dynamic>> createJob({
    required String title,
    required String description,
    required String skill,
    required String urgency,
    required Map<String, dynamic> location,
    Map<String, dynamic>? budget,
    int quotationWindowDays = 1,
  }) async {
    final token = AuthService.token;
    if (token == null) {
      return {'success': false, 'message': 'Not authenticated'};
    }

    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/jobs'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'title': title,
          'description': description,
          'skill': skill,
          'urgency': urgency.toLowerCase(),
          'location': location,
          'quotationWindowDays': quotationWindowDays,
          if (budget != null) 'budget': budget,
        }),
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 201) {
         return {'success': true, 'data': data['data']};
      } else {
         return {'success': false, 'message': data['message'] ?? 'Failed to post job'};
      }

    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }
}
