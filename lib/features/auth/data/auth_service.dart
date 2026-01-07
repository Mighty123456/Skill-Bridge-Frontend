import 'dart:io';
import 'dart:convert';
import '../../../core/services/api_service.dart';
import '../../../core/config/api_config.dart';

class AuthService {
  final ApiService _apiService = ApiService();

  // Register user
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String role,
    required String name,
    required String phone,
    required DateTime dateOfBirth,
    Map<String, dynamic>? address,
    List<String>? services,
    List<String>? skills,
    int? experience,
    File? governmentId,
    File? selfie,
  }) async {
    final Map<String, String> fields = {
      'email': email,
      'password': password,
      'role': role,
      'name': name,
      'phone': phone,
      'dateOfBirth': dateOfBirth.toIso8601String().split('T')[0],
      if (address != null) 'address': json.encode(address),
      if (services != null && services.isNotEmpty) 'services': json.encode(services),
      if (skills != null && skills.isNotEmpty) 'skills': json.encode(skills),
      if (experience != null) 'experience': experience.toString(),
    };

    if (governmentId != null || selfie != null) {
      final Map<String, File> files = {
        if (governmentId != null) 'governmentId': governmentId,
        if (selfie != null) 'selfie': selfie,
      };
      return await _apiService.postWithFiles('/auth/register', fields, files);
    }

    // Fallback to regular JSON post if no files
    return await _apiService.post('/auth/register', {
      ...fields,
      if (address != null) 'address': address,
      if (services != null && services.isNotEmpty) 'services': services,
      if (skills != null && skills.isNotEmpty) 'skills': skills,
      if (experience != null) 'experience': int.tryParse(experience.toString()),
    });
  }

  // Login with email and password
  Future<Map<String, dynamic>> login(String email, String password) async {
    final data = {
      'email': email,
      'password': password,
    };

    return await _apiService.post('/auth/login', data);
  }

  // Send OTP for login
  Future<Map<String, dynamic>> sendLoginOTP(String email) async {
    final data = {
      'email': email,
    };

    return await _apiService.post('/auth/send-otp', data);
  }

  // Login with OTP
  Future<Map<String, dynamic>> loginWithOTP(String email, String otp) async {
    final data = {
      'email': email,
      'otp': otp,
    };

    return await _apiService.post('/auth/login-otp', data);
  }

  // Upload profile image
  Future<Map<String, dynamic>> uploadProfileImage(
    String token,
    File imageFile,
  ) async {
    final fileBytes = await imageFile.readAsBytes();
    final fileName = imageFile.path.split('/').last;

    return await _apiService.postWithFile(
      '/auth/upload-profile-image',
      {},
      'image',
      fileBytes,
      fileName,
      baseUrl: ApiConfig.uploadBaseUrl,
      token: token,
    );
  }

  // Forgot password - send OTP
  Future<Map<String, dynamic>> forgotPassword(String email) async {
    final data = {
      'email': email,
    };

    return await _apiService.post('/auth/forgot-password', data);
  }

  // Verify reset OTP
  Future<Map<String, dynamic>> verifyResetOTP(String email, String otp) async {
    final data = {
      'email': email,
      'otp': otp,
    };

    return await _apiService.post('/auth/verify-reset-otp', data);
  }

  // Reset password
  Future<Map<String, dynamic>> resetPassword(
    String email,
    String otp,
    String newPassword,
  ) async {
    final data = {
      'email': email,
      'otp': otp,
      'newPassword': newPassword,
    };

    return await _apiService.post('/auth/reset-password', data);
  }
  // Verify registration OTP
  Future<Map<String, dynamic>> verifyRegistrationOTP(String email, String otp) async {
    final data = {
      'email': email,
      'otp': otp,
    };
    return await _apiService.post('/auth/verify-registration', data);
  }

  // Resend OTP
  Future<Map<String, dynamic>> resendOTP(String email) async {
    final data = {
      'email': email,
    };
    return await _apiService.post('/auth/resend-otp', data);
  }
}

