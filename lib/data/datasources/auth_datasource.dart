import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../models/user_model.dart';
import '../../core/constants/api_constants.dart';
import '../../core/services/api_service.dart';

@injectable
class AuthDataSource {
  final ApiService _apiService;

  AuthDataSource(this._apiService);

  Future<AuthResponseModel> login(String email, String password) async {
    try {
      final response = await _apiService.post(
        ApiConstants.login,
        data: {
          'email': email,
          'password': password,
        },
      );
      
      return AuthResponseModel.fromJson(response.data);
    } catch (e) {
      if (e is DioException) {
        final errorMessage = _apiService.handleError(e);
        throw Exception(errorMessage);
      }
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  Future<AuthResponseModel> register(String name, String email, String password, String role) async {
    try {
      final response = await _apiService.post(
        ApiConstants.register,
        data: {
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': password,
          'role': role,
        },
      );
      
      return AuthResponseModel.fromJson(response.data);
    } catch (e) {
      if (e is DioException) {
        final errorMessage = _apiService.handleError(e);
        throw Exception(errorMessage);
      }
      throw Exception('Registration failed: ${e.toString()}');
    }
  }

  Future<UserModel> getProfile() async {
    try {
      final response = await _apiService.get(ApiConstants.profile);
      return UserModel.fromJson(response.data['data']);
    } catch (e) {
      if (e is DioException) {
        final errorMessage = _apiService.handleError(e);
        throw Exception(errorMessage);
      }
      throw Exception('Failed to get profile: ${e.toString()}');
    }
  }

  Future<void> logout() async {
    try {
      await _apiService.post(ApiConstants.logout);
    } catch (e) {
      if (e is DioException) {
        final errorMessage = _apiService.handleError(e);
        throw Exception(errorMessage);
      }
      throw Exception('Logout failed: ${e.toString()}');
    }
  }
}
