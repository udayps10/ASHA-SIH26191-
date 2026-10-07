import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/config/api_config.dart';
import '../models/app_user.dart';

class UserRepository {
  final String _baseUrl = ApiConfig.matchingBaseUrl;

  Future<void> createUserProfile(AppUser user) async {
    // User is already created during registration via /api/auth/register
    // This method is kept for compatibility but is now a no-op
  }

  Future<AppUser?> getUserProfile(String uid) async {
    // User profile is returned during login via JWT token
    // This method is kept for compatibility
    return null;
  }
}
