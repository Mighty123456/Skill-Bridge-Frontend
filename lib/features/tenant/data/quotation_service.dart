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
    String? notes,
  }) async {
    final token = await AuthService.getToken();
    return await _apiService.post(
      '/quotations',
      {
        'job_id': jobId,
        'labor_cost': laborCost,
        'material_cost': materialCost,
        'estimated_days': estimatedDays,
        'notes': notes,
      },
      token: token,
    );
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
