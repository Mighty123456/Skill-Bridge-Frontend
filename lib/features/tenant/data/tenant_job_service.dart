import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:skillbridge_mobile/core/config/api_config.dart';
import 'package:skillbridge_mobile/features/auth/data/auth_service.dart';

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

  static Future<Map<String, dynamic>> getJobDetails(String jobId) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) return {'success': false, 'message': 'Authentication required'};

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
      return {'success': false, 'message': data['message'] ?? 'Failed to fetch job details'};
    } catch (e) {
      debugPrint('Error fetching job details: $e');
      return {'success': false, 'message': 'Connection error'};
    }
  }

  // Phase 4: Start Job (Worker)
  Future<Map<String, dynamic>> startJob(String jobId, String otp) async {
    final token = await AuthService.getToken();
    if (token == null) return {'success': false, 'message': 'Not authenticated'};

    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/jobs/$jobId/start'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'otp': otp}),
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

  // Phase 4: Submit Completion (Worker)
  Future<Map<String, dynamic>> submitCompletion(String jobId, List<File> photos) async {
    final token = await AuthService.getToken();
    if (token == null) return {'success': false, 'message': 'Not authenticated'};

    try {
       final uri = Uri.parse('${ApiConfig.baseUrl}/jobs/$jobId/complete');
       final request = http.MultipartRequest('POST', uri);
       request.headers['Authorization'] = 'Bearer $token';

       for (var photo in photos) {
          final stream = http.ByteStream(photo.openRead());
          final length = await photo.length();
          final multipartFile = http.MultipartFile(
            'photos',
            stream,
            length,
            filename: photo.path.split('/').last,
          );
          request.files.add(multipartFile);
       }

       final streamedResponse = await request.send();
       final response = await http.Response.fromStream(streamedResponse);
       final data = jsonDecode(response.body);

       if (response.statusCode == 200) {
         return {'success': true, 'data': data['data']};
       }
       return {'success': false, 'message': data['message']};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // Phase 4: Confirm Completion (Tenant)
  Future<Map<String, dynamic>> confirmCompletion(String jobId) async {
    final token = await AuthService.getToken();
    if (token == null) return {'success': false, 'message': 'Not authenticated'};

    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/jobs/$jobId/confirm-completion'), // Assuming route exists or will be added
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
}
