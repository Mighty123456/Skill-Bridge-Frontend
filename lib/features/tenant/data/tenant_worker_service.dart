import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:skillbridge_mobile/core/config/api_config.dart';
import 'package:skillbridge_mobile/features/auth/data/auth_service.dart';

class TenantWorkerService {
  static Future<Map<String, dynamic>> getNearbyWorkers({
    required double lat,
    required double lng,
    double radius = 8.0,
    String? skill,
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        return {'success': false, 'message': 'Authentication required'};
      }

      String url = '${ApiConfig.baseUrl}/workers/nearby?lat=$lat&lng=$lng&radius=$radius';
      if (skill != null && skill.isNotEmpty && skill != 'All') {
        url += '&skill=$skill';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data['data'], 'count': data['count']};
      } else {
        final error = jsonDecode(response.body);
        return {'success': false, 'message': error['message'] ?? 'Failed to fetch workers'};
      }
    } catch (e) {
      debugPrint('Error fetching nearby workers: $e');
      return {'success': false, 'message': 'Connection error'};
    }
  }
}
