import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // Get headers for JSON requests
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Get headers for multipart/form-data (file uploads)
  Map<String, String> get _multipartHeaders => {
    'Accept': 'application/json',
  };

  // Handle API response
  Map<String, dynamic> _handleResponse(http.Response response) {
    try {
      final data = json.decode(response.body);
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {
          'success': true,
          'data': data,
          'message': data['message'] ?? 'Success',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'An error occurred',
          'errors': data['errors'] ?? [],
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to parse response: $e',
      };
    }
  }

  // GET request
  Future<Map<String, dynamic>> get(String endpoint, {String? baseUrl}) async {
    try {
      final url = Uri.parse('${baseUrl ?? ApiConfig.authBaseUrl}$endpoint');
      final response = await http.get(url, headers: _headers).timeout(ApiConfig.timeout);
      return _handleResponse(response);
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // POST request
  Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> data, {
    String? baseUrl,
  }) async {
    try {
      final url = Uri.parse('${baseUrl ?? ApiConfig.authBaseUrl}$endpoint');
      final response = await http.post(
        url,
        headers: _headers,
        body: json.encode(data),
      ).timeout(ApiConfig.timeout);
      
      return _handleResponse(response);
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // POST request with file upload (multipart)
  Future<Map<String, dynamic>> postWithFile(
    String endpoint,
    Map<String, String> fields,
    String fileField,
    List<int> fileBytes,
    String fileName, {
    String? baseUrl,
    String? token,
  }) async {
    try {
      final url = Uri.parse('${baseUrl ?? ApiConfig.uploadBaseUrl}$endpoint');
      
      var request = http.MultipartRequest('POST', url);
      request.headers.addAll(_multipartHeaders);
      
      // Add authorization token if provided
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      
      // Add fields
      fields.forEach((key, value) {
        if (key != 'Authorization') { // Don't add Authorization as a field
          request.fields[key] = value;
        }
      });
      
      // Add file
      request.files.add(
        http.MultipartFile.fromBytes(
          fileField,
          fileBytes,
          filename: fileName,
        ),
      );
      
      final streamedResponse = await request.send().timeout(ApiConfig.timeout);
      final response = await http.Response.fromStream(streamedResponse);
      
      return _handleResponse(response);
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }
}

