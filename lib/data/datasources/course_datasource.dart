import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../models/course_model.dart';
import '../../core/constants/api_constants.dart';
import '../../core/constants/app_constants.dart';
import '../../core/services/api_service.dart';

@injectable
class CourseDataSource {
  final ApiService _apiService;

  CourseDataSource(this._apiService);

  // Get all courses (paginated)
  Future<CourseResponseModel> getCourses({
    int page = 1,
    int limit = AppConstants.defaultPageSize,
    String? search,
    String? filter,
    String? sort,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        ApiConstants.page: page,
        ApiConstants.limit: limit,
      };
      
      if (search != null && search.isNotEmpty) {
        queryParams[ApiConstants.search] = search;
      }
      
      if (filter != null && filter.isNotEmpty) {
        queryParams[ApiConstants.filter] = filter;
      }
      
      if (sort != null && sort.isNotEmpty) {
        queryParams[ApiConstants.sort] = sort;
      }
      
      final response = await _apiService.get(
        ApiConstants.studentCourses,
        queryParameters: queryParams,
      );
      
      return CourseResponseModel.fromJson(response.data);
    } catch (e) {
      if (e is DioException) {
        final errorMessage = _apiService.handleError(e);
        throw Exception(errorMessage);
      }
      throw Exception('Failed to fetch courses: ${e.toString()}');
    }
  }

  // Get course details
  Future<CourseModel> getCourseDetails(int courseId) async {
    try {
      final response = await _apiService.get('${ApiConstants.studentCourses}/$courseId');
      return CourseModel.fromJson(response.data['data']);
    } catch (e) {
      if (e is DioException) {
        final errorMessage = _apiService.handleError(e);
        throw Exception(errorMessage);
      }
      throw Exception('Failed to fetch course details: ${e.toString()}');
    }
  }

  // Admin: Create course
  Future<CourseModel> createCourse(Map<String, dynamic> courseData) async {
    try {
      final response = await _apiService.post(
        ApiConstants.adminCourses,
        data: courseData,
      );
      return CourseModel.fromJson(response.data['data']);
    } catch (e) {
      if (e is DioException) {
        final errorMessage = _apiService.handleError(e);
        throw Exception(errorMessage);
      }
      throw Exception('Failed to create course: ${e.toString()}');
    }
  }

  // Admin: Update course
  Future<CourseModel> updateCourse(int courseId, Map<String, dynamic> courseData) async {
    try {
      final response = await _apiService.put(
        '${ApiConstants.adminCourses}/$courseId',
        data: courseData,
      );
      return CourseModel.fromJson(response.data['data']);
    } catch (e) {
      if (e is DioException) {
        final errorMessage = _apiService.handleError(e);
        throw Exception(errorMessage);
      }
      throw Exception('Failed to update course: ${e.toString()}');
    }
  }

  // Admin: Delete course
  Future<void> deleteCourse(int courseId) async {
    try {
      await _apiService.delete('${ApiConstants.adminCourses}/$courseId');
    } catch (e) {
      if (e is DioException) {
        final errorMessage = _apiService.handleError(e);
        throw Exception(errorMessage);
      }
      throw Exception('Failed to delete course: ${e.toString()}');
    }
  }

  // Admin: Assign instructor to course
  Future<CourseModel> assignInstructor(int courseId, int instructorId) async {
    try {
      final response = await _apiService.post(
        '${ApiConstants.adminCourses}/$courseId/instructor',
        data: {
          'instructor_id': instructorId,
        },
      );
      return CourseModel.fromJson(response.data['data']);
    } catch (e) {
      if (e is DioException) {
        final errorMessage = _apiService.handleError(e);
        throw Exception(errorMessage);
      }
      throw Exception('Failed to assign instructor: ${e.toString()}');
    }
  }

  // Admin: Set enrollment window
  Future<CourseModel> setEnrollmentWindow(
    int courseId, 
    DateTime startDate, 
    DateTime endDate, 
    double fee, 
    int capacity
  ) async {
    try {
      final response = await _apiService.post(
        '${ApiConstants.adminCourses}/$courseId/enrollment-window',
        data: {
          'enrollment_start_date': startDate.toIso8601String(),
          'enrollment_end_date': endDate.toIso8601String(),
          'fee': fee,
          'capacity': capacity,
        },
      );
      return CourseModel.fromJson(response.data['data']);
    } catch (e) {
      if (e is DioException) {
        final errorMessage = _apiService.handleError(e);
        throw Exception(errorMessage);
      }
      throw Exception('Failed to set enrollment window: ${e.toString()}');
    }
  }

  // Student: Enroll in course
  Future<void> enrollInCourse(int courseId, String paymentIntentId) async {
    try {
      await _apiService.post(
        '${ApiConstants.studentCourses}/$courseId/enroll',
        data: {
          'payment_intent_id': paymentIntentId,
        },
      );
    } catch (e) {
      if (e is DioException) {
        final errorMessage = _apiService.handleError(e);
        throw Exception(errorMessage);
      }
      throw Exception('Failed to enroll in course: ${e.toString()}');
    }
  }

  // Student: Join waitlist
  Future<void> joinWaitlist(int courseId) async {
    try {
      await _apiService.post(
        '${ApiConstants.studentWaitlist}/$courseId',
      );
    } catch (e) {
      if (e is DioException) {
        final errorMessage = _apiService.handleError(e);
        throw Exception(errorMessage);
      }
      throw Exception('Failed to join waitlist: ${e.toString()}');
    }
  }

  // Teacher: Get assigned courses
  Future<CourseResponseModel> getAssignedCourses({
    int page = 1,
    int limit = AppConstants.defaultPageSize,
  }) async {
    try {
      final response = await _apiService.get(
        ApiConstants.teacherCourses,
        queryParameters: {
          ApiConstants.page: page,
          ApiConstants.limit: limit,
        },
      );
      return CourseResponseModel.fromJson(response.data);
    } catch (e) {
      if (e is DioException) {
        final errorMessage = _apiService.handleError(e);
        throw Exception(errorMessage);
      }
      throw Exception('Failed to fetch assigned courses: ${e.toString()}');
    }
  }

  // Admin: Get enrolled students for a course
  Future<List<dynamic>> getEnrolledStudents(int courseId) async {
    try {
      final response = await _apiService.get(
        '${ApiConstants.adminCourses}/$courseId/students',
      );
      return response.data['data'];
    } catch (e) {
      if (e is DioException) {
        final errorMessage = _apiService.handleError(e);
        throw Exception(errorMessage);
      }
      throw Exception('Failed to fetch enrolled students: ${e.toString()}');
    }
  }
}
