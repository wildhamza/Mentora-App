import '../models/attendance_model.dart';
import '../datasources/api_service.dart';

class AttendanceRepository {
  final ApiService _apiService;

  AttendanceRepository({required ApiService apiService}) : _apiService = apiService;

  // Teacher methods
  Future<AttendanceModel> markAttendance(int courseId, DateTime date, List<Map<String, dynamic>> studentAttendance) async {
    try {
      final response = await _apiService.post('/attendance', data: {
        'course_id': courseId,
        'date': date.toIso8601String(),
        'students': studentAttendance,
      });
      
      return AttendanceModel.fromJson(response['data']);
    } catch (e) {
      rethrow;
    }
  }

  Future<AttendanceModel> updateAttendance(int attendanceId, List<Map<String, dynamic>> studentAttendance) async {
    try {
      final response = await _apiService.put('/attendance/$attendanceId', data: {
        'students': studentAttendance,
      });
      
      return AttendanceModel.fromJson(response['data']);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<AttendanceModel>> getCourseAttendanceRecords(int courseId) async {
    try {
      final response = await _apiService.get('/courses/$courseId/attendance');
      
      final List<dynamic> attendanceData = response['data'];
      return attendanceData.map((json) => AttendanceModel.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<AttendanceModel> getAttendanceById(int attendanceId) async {
    try {
      final response = await _apiService.get('/attendance/$attendanceId');
      return AttendanceModel.fromJson(response['data']);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<StudentAttendanceSummary>> getCourseAttendanceSummary(int courseId) async {
    try {
      final response = await _apiService.get('/courses/$courseId/attendance/summary');
      
      final List<dynamic> summaryData = response['data'];
      return summaryData.map((json) => StudentAttendanceSummary.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  // Student methods
  Future<List<AttendanceModel>> getStudentAttendance(int courseId) async {
    try {
      final response = await _apiService.get('/student/courses/$courseId/attendance');
      
      final List<dynamic> attendanceData = response['data'];
      return attendanceData.map((json) => AttendanceModel.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<StudentAttendanceSummary> getStudentAttendanceSummary(int courseId) async {
    try {
      final response = await _apiService.get('/student/courses/$courseId/attendance/summary');
      return StudentAttendanceSummary.fromJson(response['data']);
    } catch (e) {
      rethrow;
    }
  }
}
