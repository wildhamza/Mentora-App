import '../models/course_model.dart';
import '../datasources/api_service.dart';

class CourseRepository {
  final ApiService _apiService;

  CourseRepository({required ApiService apiService}) : _apiService = apiService;

  Future<List<CourseModel>> getCourses({Map<String, dynamic>? filters}) async {
    try {
      final response = await _apiService.get('/courses', queryParameters: filters);
      
      final List<dynamic> coursesData = response['data'];
      return coursesData.map((json) => CourseModel.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<CourseModel> getCourseById(int courseId) async {
    try {
      final response = await _apiService.get('/courses/$courseId');
      return CourseModel.fromJson(response['data']);
    } catch (e) {
      rethrow;
    }
  }

  // Admin methods
  Future<CourseModel> createCourse(Map<String, dynamic> courseData) async {
    try {
      final response = await _apiService.post('/courses', data: courseData);
      return CourseModel.fromJson(response['data']);
    } catch (e) {
      rethrow;
    }
  }

  Future<CourseModel> updateCourse(int courseId, Map<String, dynamic> courseData) async {
    try {
      final response = await _apiService.put('/courses/$courseId', data: courseData);
      return CourseModel.fromJson(response['data']);
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> deleteCourse(int courseId) async {
    try {
      await _apiService.delete('/courses/$courseId');
      return true;
    } catch (e) {
      rethrow;
    }
  }

  Future<CourseModel> assignInstructor(int courseId, int instructorId) async {
    try {
      final response = await _apiService.put('/courses/$courseId/assign-instructor', data: {
        'instructor_id': instructorId,
      });
      return CourseModel.fromJson(response['data']);
    } catch (e) {
      rethrow;
    }
  }

  Future<CourseModel> setEnrollmentWindow(int courseId, DateTime startDate, DateTime endDate, int capacity) async {
    try {
      final response = await _apiService.put('/courses/$courseId/enrollment-window', data: {
        'start_date': startDate.toIso8601String(),
        'end_date': endDate.toIso8601String(),
        'capacity': capacity,
      });
      return CourseModel.fromJson(response['data']);
    } catch (e) {
      rethrow;
    }
  }

  // Teacher methods
  Future<List<CourseModel>> getAssignedCourses() async {
    try {
      final response = await _apiService.get('/teacher/courses');
      
      final List<dynamic> coursesData = response['data'];
      return coursesData.map((json) => CourseModel.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  // Student methods
  Future<List<CourseModel>> getEnrolledCourses() async {
    try {
      final response = await _apiService.get('/student/courses');
      
      final List<dynamic> coursesData = response['data'];
      return coursesData.map((json) => CourseModel.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> enrollInCourse(int courseId, String paymentIntentId) async {
    try {
      await _apiService.post('/student/courses/enroll', data: {
        'course_id': courseId,
        'payment_intent_id': paymentIntentId,
      });
      return true;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> joinWaitlist(int courseId) async {
    try {
      await _apiService.post('/student/courses/waitlist', data: {
        'course_id': courseId,
      });
      return true;
    } catch (e) {
      rethrow;
    }
  }
}
