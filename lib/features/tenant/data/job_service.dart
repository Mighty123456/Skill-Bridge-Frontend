import 'dart:io';
import 'dart:convert';
import 'package:http_parser/http_parser.dart';
import 'package:skillbridge_mobile/core/config/api_config.dart';
import '../../auth/data/auth_service.dart';
import 'package:http/http.dart' as http;

class JobService {
  static Future<Map<String, dynamic>> createJob({
    required String title,
    required String description,
    String? materialRequirements, 
    required String skill,
    required Map<String, dynamic> location,
    required String urgency,
    int quotationWindowDays = 1,
    List<File>? images,
  }) async {
    final token = await AuthService.getToken();
    if (token == null) return {'success': false, 'message': 'Not authenticated'};

    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/jobs');
      final request = http.MultipartRequest('POST', uri);
      
      // Add Headers
      request.headers.addAll({
        'Authorization': 'Bearer $token',
      });

      // Add Fields
      request.fields['job_title'] = title;
      request.fields['job_description'] = description;
      if (materialRequirements != null && materialRequirements.isNotEmpty) {
        request.fields['material_requirements'] = materialRequirements;
      }
      request.fields['skill_required'] = skill;
      request.fields['urgency_level'] = urgency;
      request.fields['quotation_window_hours'] = (quotationWindowDays * 24).toString();
      
      // Send location as JSON string
      request.fields['location'] = jsonEncode({
        'lat': location['coordinates'][1],
        'lng': location['coordinates'][0],
        'address_text': location['address']
      });

      // Add Images
      if (images != null && images.isNotEmpty) {
        for (var image in images) {
          final stream = http.ByteStream(image.openRead());
          final length = await image.length();
          final multipartFile = http.MultipartFile(
            'issue_photos',
            stream,
            length,
            filename: image.path.split('/').last,
            contentType: MediaType('image', 'jpeg'), // Defaulting to jpeg
          );
          request.files.add(multipartFile);
        }
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

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
