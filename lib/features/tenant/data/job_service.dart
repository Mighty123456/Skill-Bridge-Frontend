import 'dart:convert';
import 'package:skillbridge_mobile/core/config/api_config.dart';
import '../../auth/data/auth_service.dart';
import 'package:http/http.dart' as http;

class JobService {
  static Future<Map<String, dynamic>> createJob({
    required String title,
    required String description,
    required String skill,
    required Map<String, dynamic> location,
    required String urgency,
    int quotationWindowDays = 1,

  }) async {
    final token = await AuthService.getToken();
    if (token == null) return {'success': false, 'message': 'Not authenticated'};

    try {
      // Map frontend args to new Backend Schema
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/jobs'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'job_title': title,
          'job_description': description,
          'skill_required': skill,
          'location': {
             'lat': location['coordinates'][1], // Frontend sends [lng, lat], Model wants lat, lng
             'lng': location['coordinates'][0],
             'address_text': location['address']
          },
          'urgency_level': urgency,

          'quotation_window_hours': quotationWindowDays * 24, // Convert days to hours
        }),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 201) {
        return {'success': true, 'data': data['data']};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Failed to create job'};
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }
}
