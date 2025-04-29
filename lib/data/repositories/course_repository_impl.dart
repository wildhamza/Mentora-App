import 'package:injectable/injectable.dart';
import 'package:mentora/core/constants/app_constants.dart';
import 'package:mentora/data/datasources/course_data_source.dart';
import 'package:mentora/data/models/course/course_model.dart';
import 'package:mentora/domain/entities/course.dart';
import 'package:mentora/domain/repositories/course_repository.dart';

@Singleton(as: CourseRepository)
class CourseRepositoryImpl implements CourseRepository {
  final CourseDataSource _dataSource;

  CourseRepositoryImpl(this._dataSource);

  @override
  Future<List<Course>> getCourses({
    int page = 1,
    int limit = AppConstants.defaultPageSize,
    String? status,
    String? search,
  }) async {
    final response = await _dataSource.getCourses(
      page: page,
      limit: limit,
      status: status,
      search: search,
    );
    
    return response.map((courseJson) => CourseModel.fromJson(courseJson).toEntity()).toList();
  }

  @override
  Future<Course> getCourseById(int courseId) async {
    final response = await _dataSource.getCourseById(courseId);
    return CourseModel.fromJson(response).toEntity();
  }

  @override
  Future<Course> createCourse(Course course) async {
    final courseModel = CourseModel(
      id: 0, // Will be assigned by the server
      title: course.title,
      description: course.description,
      status: course.status,
      duration: course.duration,
      fee: course.fee,
      capacity: course.capacity,
      instructorId: course.instructorId,
      enrollmentStartDate: course.enrollmentStartDate,
      enrollmentEndDate: course.enrollmentEndDate,
      enrolledStudents: 0,
      thumbnailUrl: course.thumbnailUrl,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    
    final response = await _dataSource.createCourse(courseModel.toJson());
    return CourseModel.fromJson(response).toEntity();
  }

  @override
  Future<Course> updateCourse(Course course) async {
    final courseModel = CourseModel(
      id: course.id,
      title: course.title,
      description: course.description,
      status: course.status,
      duration: course.duration,
      fee: course.fee,
      capacity: course.capacity,
      instructorId: course.instructorId,
      instructorName: course.instructorName,
      enrollmentStartDate: course.enrollmentStartDate,
      enrollmentEndDate: course.enrollmentEndDate,
      enrolledStudents: course.enrolledStudents,
      thumbnailUrl: course.thumbnailUrl,
      createdAt: course.createdAt,
      updatedAt: DateTime.now(),
    );
    
    final response = await _dataSource.updateCourse(course.id, courseModel.toJson());
    return CourseModel.fromJson(response).toEntity();
  }

  @override
  Future<bool> deleteCourse(int courseId) async {
    await _dataSource.deleteCourse(courseId);
    return true;
  }

  @override
  Future<bool> assignInstructor(int courseId, int instructorId) async {
    await _dataSource.assignInstructor(courseId, instructorId);
    return true;
  }

  @override
  Future<bool> enrollCourse(int courseId, {required String paymentIntentId}) async {
    await _dataSource.enrollCourse(courseId, paymentIntentId: paymentIntentId);
    return true;
  }

  @override
  Future<bool> waitlistCourse(int courseId) async {
    await _dataSource.waitlistCourse(courseId);
    return true;
  }

  @override
  Future<List<Course>> getStudentCourses() async {
    final response = await _dataSource.getStudentCourses();
    return response.map((courseJson) => CourseModel.fromJson(courseJson).toEntity()).toList();
  }

  @override
  Future<List<Course>> getTeacherCourses() async {
    final response = await _dataSource.getTeacherCourses();
    return response.map((courseJson) => CourseModel.fromJson(courseJson).toEntity()).toList();
  }
}
