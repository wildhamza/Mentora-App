import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';
import '../../data/models/user_model.dart';

@singleton
class StorageService {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  late SharedPreferences _preferences;

  StorageService() {
    _initPreferences();
  }

  Future<void> _initPreferences() async {
    _preferences = await SharedPreferences.getInstance();
  }

  // Token management (secure storage)
  Future<void> saveToken(String token) async {
    await _secureStorage.write(key: AppConstants.tokenKey, value: token);
  }

  Future<String?> getToken() async {
    return await _secureStorage.read(key: AppConstants.tokenKey);
  }

  Future<void> clearToken() async {
    await _secureStorage.delete(key: AppConstants.tokenKey);
  }

  // User info management
  Future<void> saveUser(UserModel user) async {
    await _preferences.setString(AppConstants.userInfoKey, jsonEncode(user.toJson()));
  }

  Future<UserModel?> getUser() async {
    final userString = _preferences.getString(AppConstants.userInfoKey);
    if (userString != null) {
      return UserModel.fromJson(jsonDecode(userString));
    }
    return null;
  }

  Future<void> saveUserRole(String role) async {
    await _preferences.setString(AppConstants.userRoleKey, role);
  }

  Future<String?> getUserRole() async {
    return _preferences.getString(AppConstants.userRoleKey);
  }

  // Clear all user data
  Future<void> clearUserData() async {
    await clearToken();
    await _preferences.remove(AppConstants.userInfoKey);
    await _preferences.remove(AppConstants.userRoleKey);
  }

  // General preferences
  Future<void> setBool(String key, bool value) async {
    await _preferences.setBool(key, value);
  }

  bool? getBool(String key) {
    return _preferences.getBool(key);
  }

  Future<void> setString(String key, String value) async {
    await _preferences.setString(key, value);
  }

  String? getString(String key) {
    return _preferences.getString(key);
  }

  Future<void> setInt(String key, int value) async {
    await _preferences.setInt(key, value);
  }

  int? getInt(String key) {
    return _preferences.getInt(key);
  }

  Future<void> removeKey(String key) async {
    await _preferences.remove(key);
  }

  Future<void> clearAll() async {
    await _preferences.clear();
    await _secureStorage.deleteAll();
  }
}
