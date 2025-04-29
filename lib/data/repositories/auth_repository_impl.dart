import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:mentora/core/constants/api_constants.dart';
import 'package:mentora/core/constants/app_constants.dart';
import 'package:mentora/core/utils/dio_client.dart';
import 'package:mentora/core/utils/shared_prefs.dart';
import 'package:mentora/data/datasources/auth_data_source.dart';
import 'package:mentora/data/models/auth/user_model.dart';
import 'package:mentora/domain/entities/user.dart';
import 'package:mentora/domain/repositories/auth_repository.dart';

@Singleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final AuthDataSource _dataSource;
  final SharedPrefs _sharedPrefs;

  AuthRepositoryImpl(this._dataSource, this._sharedPrefs);

  @override
  Future<User> login(String email, String password) async {
    try {
      final response = await _dataSource.login(email, password);
      
      // Save auth token
      await _sharedPrefs.setAuthToken(response['token']);
      
      // Save user data
      final userModel = UserModel.fromJson(response['user']);
      await _sharedPrefs.setUserData(userModel.toJson());
      await _sharedPrefs.setUserRole(userModel.role);
      
      return userModel.toEntity();
    } catch (e) {
      if (e is DioException) {
        if (e.response?.statusCode == 401) {
          throw Exception(AppConstants.errorInvalidCredentials);
        }
      }
      rethrow;
    }
  }
  
  @override
  Future<User> register(String name, String email, String password, String role) async {
    try {
      final response = await _dataSource.register(name, email, password, role);
      
      // Save auth token
      await _sharedPrefs.setAuthToken(response['token']);
      
      // Save user data
      final userModel = UserModel.fromJson(response['user']);
      await _sharedPrefs.setUserData(userModel.toJson());
      await _sharedPrefs.setUserRole(userModel.role);
      
      return userModel.toEntity();
    } catch (e) {
      if (e is DioException) {
        if (e.response?.statusCode == 422) {
          final errors = e.response?.data['errors'];
          if (errors != null && errors['email'] != null) {
            throw Exception(errors['email'][0]);
          }
        }
      }
      rethrow;
    }
  }
  
  @override
  Future<void> logout() async {
    try {
      await _dataSource.logout();
    } finally {
      // Clear local auth data regardless of API response
      await _sharedPrefs.clearAuthData();
    }
  }
  
  @override
  Future<bool> isLoggedIn() async {
    final token = await _sharedPrefs.getAuthToken();
    return token != null && token.isNotEmpty;
  }
  
  @override
  Future<String?> getUserRole() async {
    return _sharedPrefs.getUserRole();
  }
  
  @override
  Future<User?> getCurrentUser() async {
    final userData = await _sharedPrefs.getUserData();
    if (userData != null) {
      try {
        final userModel = UserModel.fromJson(userData);
        return userModel.toEntity();
      } catch (e) {
        return null;
      }
    }
    return null;
  }
}
