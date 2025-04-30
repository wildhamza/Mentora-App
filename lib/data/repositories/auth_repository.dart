import '../models/user_model.dart';
import '../datasources/api_service.dart';
import '../../core/constants.dart';

class AuthRepository {
  final ApiService _apiService;

  AuthRepository({required ApiService apiService}) : _apiService = apiService;

  Future<UserModel> login(String email, String password) async {
    try {
      final response = await _apiService.post('/auth/login', data: {
        'email': email,
        'password': password,
      });
      
      return UserModel.fromJson(response['data']);
    } catch (e) {
      rethrow;
    }
  }

  Future<UserModel> register(String name, String email, String password, UserRole role) async {
    try {
      String roleString = '';
      switch (role) {
        case UserRole.admin:
          roleString = 'admin';
          break;
        case UserRole.teacher:
          roleString = 'teacher';
          break;
        case UserRole.student:
          roleString = 'student';
          break;
      }
      
      final response = await _apiService.post('/auth/register', data: {
        'name': name,
        'email': email,
        'password': password,
        'role': roleString,
      });
      
      return UserModel.fromJson(response['data']);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await _apiService.post('/auth/logout');
    } catch (e) {
      rethrow;
    }
  }

  Future<UserModel> getUserProfile() async {
    try {
      final response = await _apiService.get('/user/profile');
      return UserModel.fromJson(response['data']);
    } catch (e) {
      rethrow;
    }
  }

  Future<UserModel> updateUserProfile(Map<String, dynamic> data) async {
    try {
      final response = await _apiService.put('/user/profile', data: data);
      return UserModel.fromJson(response['data']);
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> changePassword(String currentPassword, String newPassword) async {
    try {
      await _apiService.put('/user/change-password', data: {
        'current_password': currentPassword,
        'new_password': newPassword,
      });
      return true;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> resetPassword(String email) async {
    try {
      await _apiService.post('/auth/reset-password', data: {
        'email': email,
      });
      return true;
    } catch (e) {
      rethrow;
    }
  }
}
