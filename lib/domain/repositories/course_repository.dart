import 'package:mentora/domain/entities/course.dart';

abstract class CourseRepository {
  // Get all courses with optional filtering
  Future<List<Course>> getCourses({
    int page = 1,
    int limit = 10,
    String? status,
    String? search,
  });
  
  // Get a specific course by ID
  Future<Course> getCourseById(int courseId);
  
  // Admin: Create a new course
  Future<Course> createCourse(Course course);
  
  // Admin: Update an existing course
  Future<Course> updateCourse(Course course);
  
  // Admin: Delete a course
  Future<bool> deleteCourse(int courseId);
  
  // Admin: Assign an instructor to a course
  Future<bool> assignInstructor(int courseId, int instructorId);
  
  // Student: Enroll in a course
  Future<bool> enrollCourse(int courseId, {required String paymentIntentId});
  
  // Student: Join waitlist for a full course
  Future<bool> waitlistCourse(int courseId);
  
  // Student: Get courses enrolled by the current student
  Future<List<Course>> getStudentCourses();
  
  // Teacher: Get courses assigned to the current teacher
  Future<List<Course>> getTeacherCourses();
}
