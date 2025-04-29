import 'package:injectable/injectable.dart';
import 'package:mentora/core/constants/api_constants.dart';
import 'package:mentora/core/constants/app_constants.dart';
import 'package:mentora/core/utils/dio_client.dart';

@injectable
class CourseDataSource {
  final DioClient _dioClient;

  CourseDataSource(this._dioClient);

  Future<List<dynamic>> getCourses({
    int page = 1,
    int limit = AppConstants.defaultPageSize,
    String? status,
    String? search,
  }) async {
    final queryParams = {
      'page': page,
      'limit': limit,
    };
    
    if (status != null) {
      queryParams['status'] = status;
    }
    
    if (search != null) {
      queryParams['search'] = search;
    }
    
    final response = await _dioClient.get(
      ApiConstants.courses,
      queryParameters: queryParams,
    );
    
    return response.data['data'];
  }

  Future<Map<String, dynamic>> getCourseById(int courseId) async {
    final response = await _dioClient.get('${ApiConstants.courseDetail}$courseId');
    return response.data;
  }

  Future<Map<String, dynamic>> createCourse(Map<String, dynamic> course) async {
    final response = await _dioClient.post(
      ApiConstants.adminCourses,
      data: course,
    );
    
    return response.data;
  }

  Future<Map<String, dynamic>> updateCourse(int courseId, Map<String, dynamic> course) async {
    final response = await _dioClient.put(
      '${ApiConstants.adminCourseDetail}$courseId',
      data: course,
    );
    
    return response.data;
  }

  Future<void> deleteCourse(int courseId) async {
    await _dioClient.delete('${ApiConstants.adminCourseDetail}$courseId');
  }

  Future<void> assignInstructor(int courseId, int instructorId) async {
    await _dioClient.post(
      ApiConstants.adminAssignInstructor,
      data: {
        'course_id': courseId,
        'instructor_id': instructorId,
      },
    );
  }

  Future<void> enrollCourse(int courseId, {required String paymentIntentId}) async {
    await _dioClient.post(
      '${ApiConstants.enrollCourse}$courseId',
      data: {
        'payment_intent_id': paymentIntentId,
      },
    );
  }

  Future<void> waitlistCourse(int courseId) async {
    await _dioClient.post('${ApiConstants.waitlistCourse}$courseId');
  }

  Future<List<dynamic>> getStudentCourses() async {
    final response = await _dioClient.get(ApiConstants.studentCourses);
    return response.data['data'];
  }

  Future<List<dynamic>> getTeacherCourses() async {
    final response = await _dioClient.get(ApiConstants.teacherCourses);
    return response.data['data'];
  }
}
