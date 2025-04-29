import 'dart:convert';
import 'package:mentora/core/constants/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:injectable/injectable.dart';

@singleton
class SharedPrefs {
  late SharedPreferences _prefs;
  
  @factoryMethod
  static Future<SharedPrefs> create() async {
    final instance = SharedPrefs();
    await instance._init();
    return instance;
  }
  
  Future<void> _init() async {
    _prefs = await SharedPreferences.getInstance();
  }
  
  // Auth Token
  Future<String?> getAuthToken() async {
    return _prefs.getString(AppConstants.prefKeyToken);
  }
  
  Future<bool> setAuthToken(String token) async {
    return _prefs.setString(AppConstants.prefKeyToken, token);
  }
  
  // User Role
  Future<String?> getUserRole() async {
    return _prefs.getString(AppConstants.prefKeyRole);
  }
  
  Future<bool> setUserRole(String role) async {
    return _prefs.setString(AppConstants.prefKeyRole, role);
  }
  
  // User Data (as JSON)
  Future<Map<String, dynamic>?> getUserData() async {
    final data = _prefs.getString(AppConstants.prefKeyUser);
    if (data != null) {
      try {
        return json.decode(data) as Map<String, dynamic>;
      } catch (e) {
        return null;
      }
    }
    return null;
  }
  
  Future<bool> setUserData(Map<String, dynamic> userData) async {
    return _prefs.setString(AppConstants.prefKeyUser, json.encode(userData));
  }
  
  // Clear Auth Data
  Future<void> clearAuthData() async {
    await _prefs.remove(AppConstants.prefKeyToken);
    await _prefs.remove(AppConstants.prefKeyUser);
    await _prefs.remove(AppConstants.prefKeyRole);
  }
  
  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await getAuthToken();
    return token != null && token.isNotEmpty;
  }
}
