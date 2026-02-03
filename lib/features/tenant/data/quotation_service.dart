import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../../core/config/api_config.dart';
import '../../../core/services/api_service.dart';
import '../../../features/auth/data/auth_service.dart';

class QuotationService {
  final ApiService _apiService = ApiService();

  // Submit a quotation (Worker)
  Future<Map<String, dynamic>> submitQuotation({
    required String jobId,
    required double laborCost,
    required double materialCost,
    required int estimatedDays,
    required String notes,
    List<String>? tags,
    File? videoPitch,
  }) async {
    final token = await AuthService.getToken();
    if (token == null) return {'success': false, 'message': 'Not authenticated'};

    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/quotations');
      final request = http.MultipartRequest('POST', uri);
      
      request.headers['Authorization'] = 'Bearer $token';

      // Fields
      request.fields['job_id'] = jobId;
      request.fields['labor_cost'] = laborCost.toString();
      request.fields['material_cost'] = materialCost.toString();
      request.fields['estimated_days'] = estimatedDays.toString();
      request.fields['notes'] = notes;
      
      if (tags != null) {
        request.fields['tags'] = jsonEncode(tags);
      }

      // File
      if (videoPitch != null) {
        final stream = http.ByteStream(videoPitch.openRead());
        final length = await videoPitch.length();
        final multipartFile = http.MultipartFile(
          'video_pitch',
          stream,
          length,
          filename: videoPitch.path.split('/').last,
        );
        request.files.add(multipartFile);
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final data = jsonDecode(response.body);
      
      if (response.statusCode == 201) {
        return {'success': true, 'data': data['data']};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Failed to submit'};
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // Get Statistical Data for AI Warning
  Future<Map<String, dynamic>> getQuotationStats(String skill) async {
    final token = await AuthService.getToken();
    if (token == null) return {'success': false};

    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/quotations/stats?skill=$skill'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data['data']};
      }
      return {'success': false};
    } catch (e) {
      return {'success': false};
    }
  }

  // Get quotations for a job (Tenant)
  Future<Map<String, dynamic>> getQuotations(String jobId) async {
    final token = await AuthService.getToken();
    return await _apiService.get(
      '/quotations/job/$jobId',
      token: token,
    );
  }

  // Accept a quotation (Tenant)
  Future<Map<String, dynamic>> acceptQuotation(String quotationId) async {
    final token = await AuthService.getToken();
    return await _apiService.patch(
      '/quotations/$quotationId/accept',
      {},
      token: token,
    );
  }
}
