import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/auth_service.dart';

// Simple provider to access AuthService
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

// FutureProvider to get the current user profile (Phase 1 Status check)
final currentUserProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final authService = ref.read(authServiceProvider);
  return await authService.getMe();
});
