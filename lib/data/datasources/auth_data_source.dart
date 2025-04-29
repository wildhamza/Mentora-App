import 'package:injectable/injectable.dart';
import 'package:mentora/core/constants/api_constants.dart';
import 'package:mentora/core/utils/dio_client.dart';

@injectable
class AuthDataSource {
  final DioClient _dioClient;

  AuthDataSource(this._dioClient);

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await _dioClient.post(
      ApiConstants.login,
      data: {
        'email': email,
        'password': password,
      },
    );
    
    return response.data;
  }

  Future<Map<String, dynamic>> register(
    String name,
    String email,
    String password,
    String role,
  ) async {
    final response = await _dioClient.post(
      ApiConstants.register,
      data: {
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': password,
        'role': role,
      },
    );
    
    return response.data;
  }

  Future<void> logout() async {
    await _dioClient.post(ApiConstants.logout);
  }
}
