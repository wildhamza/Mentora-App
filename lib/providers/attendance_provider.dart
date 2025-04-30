import 'package:flutter/material.dart';
import '../data/models/attendance_model.dart';
import '../data/repositories/attendance_repository.dart';
import '../data/datasources/api_service.dart';

class AttendanceProvider extends ChangeNotifier {
  final AttendanceRepository _attendanceRepository = AttendanceRepository(apiService: ApiService());
  
  List<AttendanceModel> _attendanceRecords = [];
  AttendanceModel? _selectedAttendance;
  List<StudentAttendanceSummary> _attendanceSummary = [];
  bool _isLoading = false;
  String? _error;
  
  List<AttendanceModel> get attendanceRecords => _attendanceRecords;
  AttendanceModel? get selectedAttendance => _selectedAttendance;
  List<StudentAttendanceSummary> get attendanceSummary => _attendanceSummary;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  void setError(String? error) {
    _error = error;
    notifyListeners();
  }
  
  // Teacher methods
  Future<bool> markAttendance(int courseId, DateTime date, List<Map<String, dynamic>> studentAttendance) async {
    setLoading(true);
    setError(null);
    
    try {
      final attendance = await _attendanceRepository.markAttendance(courseId, date, studentAttendance);
      
      // Check if we're updating an existing record
      final index = _attendanceRecords.indexWhere((record) => 
        record.courseId == courseId && record.date.year == date.year && 
        record.date.month == date.month && record.date.day == date.day);
      
      if (index != -1) {
        _attendanceRecords[index] = attendance;
      } else {
        _attendanceRecords.add(attendance);
      }
      
      _selectedAttendance = attendance;
      
      setLoading(false);
      return true;
    } catch (e) {
      setLoading(false);
      setError(e.toString());
      return false;
    }
  }
  
  Future<bool> updateAttendance(int attendanceId, List<Map<String, dynamic>> studentAttendance) async {
    setLoading(true);
    setError(null);
    
    try {
      final attendance = await _attendanceRepository.updateAttendance(attendanceId, studentAttendance);
      
      final index = _attendanceRecords.indexWhere((record) => record.id == attendanceId);
      if (index != -1) {
        _attendanceRecords[index] = attendance;
      }
      
      if (_selectedAttendance?.id == attendanceId) {
        _selectedAttendance = attendance;
      }
      
      setLoading(false);
      return true;
    } catch (e) {
      setLoading(false);
      setError(e.toString());
      return false;
    }
  }
  
  Future<bool> fetchCourseAttendanceRecords(int courseId) async {
    setLoading(true);
    setError(null);
    
    try {
      _attendanceRecords = await _attendanceRepository.getCourseAttendanceRecords(courseId);
      setLoading(false);
      return true;
    } catch (e) {
      setLoading(false);
      setError(e.toString());
      return false;
    }
  }
  
  Future<bool> fetchAttendanceById(int attendanceId) async {
    setLoading(true);
    setError(null);
    
    try {
      _selectedAttendance = await _attendanceRepository.getAttendanceById(attendanceId);
      setLoading(false);
      return true;
    } catch (e) {
      setLoading(false);
      setError(e.toString());
      return false;
    }
  }
  
  Future<bool> fetchCourseAttendanceSummary(int courseId) async {
    setLoading(true);
    setError(null);
    
    try {
      _attendanceSummary = await _attendanceRepository.getCourseAttendanceSummary(courseId);
      setLoading(false);
      return true;
    } catch (e) {
      setLoading(false);
      setError(e.toString());
      return false;
    }
  }
  
  // Student methods
  Future<bool> fetchStudentAttendance(int courseId) async {
    setLoading(true);
    setError(null);
    
    try {
      _attendanceRecords = await _attendanceRepository.getStudentAttendance(courseId);
      setLoading(false);
      return true;
    } catch (e) {
      setLoading(false);
      setError(e.toString());
      return false;
    }
  }
  
  Future<bool> fetchStudentAttendanceSummary(int courseId) async {
    setLoading(true);
    setError(null);
    
    try {
      final summary = await _attendanceRepository.getStudentAttendanceSummary(courseId);
      _attendanceSummary = [summary];
      setLoading(false);
      return true;
    } catch (e) {
      setLoading(false);
      setError(e.toString());
      return false;
    }
  }
}
