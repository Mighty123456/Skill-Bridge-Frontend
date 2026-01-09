import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../../core/config/api_config.dart';
import '../../auth/data/auth_service.dart';

class TenantJobService {
  static Future<Map<String, dynamic>> getPostedJobs({String status = 'open'}) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        return {'success': false, 'message': 'Authentication required'};
      }

      final uri = Uri.parse('${ApiConfig.baseUrl}/jobs/posted-jobs?status=$status');
      
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      debugPrint('Get Posted Jobs (${status.toUpperCase()}): ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'data': data['data'],
        };
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'message': error['message'] ?? 'Failed to fetch jobs',
        };
      }
    } catch (e) {
      debugPrint('Error fetching posted jobs: $e');
      return {'success': false, 'message': 'Connection error'};
    }
  }
}
