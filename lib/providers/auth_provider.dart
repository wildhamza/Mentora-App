import 'package:flutter/material.dart';
import '../data/models/user_model.dart';
import '../data/repositories/auth_repository.dart';
import '../data/datasources/api_service.dart';
import '../core/constants.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository(apiService: ApiService());
  
  UserModel? _user;
  bool _isLoading = false;
  String? _error;
  
  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;
  
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  void setError(String? error) {
    _error = error;
    notifyListeners();
  }
  
  Future<bool> login(String email, String password) async {
    setLoading(true);
    setError(null);
    
    try {
      _user = await _authRepository.login(email, password);
      setLoading(false);
      return true;
    } catch (e) {
      setLoading(false);
      setError(e.toString());
      return false;
    }
  }
  
  Future<bool> register(String name, String email, String password, UserRole role) async {
    setLoading(true);
    setError(null);
    
    try {
      _user = await _authRepository.register(name, email, password, role);
      setLoading(false);
      return true;
    } catch (e) {
      setLoading(false);
      setError(e.toString());
      return false;
    }
  }
  
  Future<bool> logout() async {
    setLoading(true);
    setError(null);
    
    try {
      await _authRepository.logout();
      _user = null;
      setLoading(false);
      return true;
    } catch (e) {
      setLoading(false);
      setError(e.toString());
      return false;
    }
  }
  
  Future<bool> getUserProfile() async {
    setLoading(true);
    setError(null);
    
    try {
      _user = await _authRepository.getUserProfile();
      setLoading(false);
      return true;
    } catch (e) {
      setLoading(false);
      setError(e.toString());
      return false;
    }
  }
  
  Future<bool> updateUserProfile(Map<String, dynamic> data) async {
    setLoading(true);
    setError(null);
    
    try {
      _user = await _authRepository.updateUserProfile(data);
      setLoading(false);
      return true;
    } catch (e) {
      setLoading(false);
      setError(e.toString());
      return false;
    }
  }
  
  Future<bool> changePassword(String currentPassword, String newPassword) async {
    setLoading(true);
    setError(null);
    
    try {
      final result = await _authRepository.changePassword(currentPassword, newPassword);
      setLoading(false);
      return result;
    } catch (e) {
      setLoading(false);
      setError(e.toString());
      return false;
    }
  }
  
  Future<bool> resetPassword(String email) async {
    setLoading(true);
    setError(null);
    
    try {
      final result = await _authRepository.resetPassword(email);
      setLoading(false);
      return result;
    } catch (e) {
      setLoading(false);
      setError(e.toString());
      return false;
    }
  }
}
