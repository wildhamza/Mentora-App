import 'package:mentora/domain/entities/user.dart';

abstract class AuthRepository {
  Future<User> login(String email, String password);
  
  Future<User> register(String name, String email, String password, String role);
  
  Future<void> logout();
  
  Future<bool> isLoggedIn();
  
  Future<String?> getUserRole();
  
  Future<User?> getCurrentUser();
}
