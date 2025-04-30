import 'package:flutter/material.dart';
import '../data/models/course_model.dart';
import '../data/repositories/course_repository.dart';
import '../data/datasources/api_service.dart';

class CourseProvider extends ChangeNotifier {
  final CourseRepository _courseRepository =
      CourseRepository(apiService: ApiService());

  List<CourseModel> _courses = [];
  List<CourseModel> _enrolledCourses = [];
  List<CourseModel> _availableCourses = [];
  CourseModel? _selectedCourse;
  CourseModel? _currentCourse;
  List<dynamic> _courseMaterials = [];
  bool _isLoading = false;
  String? _error;

  List<CourseModel> get courses => _courses;
  List<CourseModel> get enrolledCourses => _enrolledCourses;
  List<CourseModel> get availableCourses => _availableCourses;
  CourseModel? get selectedCourse => _selectedCourse;
  CourseModel? get currentCourse => _currentCourse;
  List<dynamic> get courseMaterials => _courseMaterials;
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

  void setSelectedCourse(CourseModel course) {
    _selectedCourse = course;
    notifyListeners();
  }

  // Admin methods
  Future<bool> fetchAllCourses({Map<String, dynamic>? filters}) async {
    setLoading(true);
    setError(null);

    try {
      _courses = await _courseRepository.getCourses(filters: filters);
      setLoading(false);
      return true;
    } catch (e) {
      setLoading(false);
      setError(e.toString());
      return false;
    }
  }

  Future<bool> fetchCourseById(int courseId) async {
    setLoading(true);
    setError(null);

    try {
      _selectedCourse = await _courseRepository.getCourseById(courseId);
      setLoading(false);
      return true;
    } catch (e) {
      setLoading(false);
      setError(e.toString());
      return false;
    }
  }

  Future<bool> createCourse(Map<String, dynamic> courseData) async {
    setLoading(true);
    setError(null);

    try {
      final newCourse = await _courseRepository.createCourse(courseData);
      _courses.add(newCourse);
      setLoading(false);
      return true;
    } catch (e) {
      setLoading(false);
      setError(e.toString());
      return false;
    }
  }

  Future<bool> updateCourse(
      int courseId, Map<String, dynamic> courseData) async {
    setLoading(true);
    setError(null);

    try {
      final updatedCourse =
          await _courseRepository.updateCourse(courseId, courseData);

      final index = _courses.indexWhere((course) => course.id == courseId);
      if (index != -1) {
        _courses[index] = updatedCourse;
      }

      if (_selectedCourse?.id == courseId) {
        _selectedCourse = updatedCourse;
      }

      setLoading(false);
      return true;
    } catch (e) {
      setLoading(false);
      setError(e.toString());
      return false;
    }
  }

  Future<bool> deleteCourse(int courseId) async {
    setLoading(true);
    setError(null);

    try {
      final result = await _courseRepository.deleteCourse(courseId);

      if (result) {
        _courses.removeWhere((course) => course.id == courseId);

        if (_selectedCourse?.id == courseId) {
          _selectedCourse = null;
        }
      }

      setLoading(false);
      return result;
    } catch (e) {
      setLoading(false);
      setError(e.toString());
      return false;
    }
  }

  Future<bool> assignInstructor(int courseId, int instructorId) async {
    setLoading(true);
    setError(null);

    try {
      final updatedCourse =
          await _courseRepository.assignInstructor(courseId, instructorId);

      final index = _courses.indexWhere((course) => course.id == courseId);
      if (index != -1) {
        _courses[index] = updatedCourse;
      }

      if (_selectedCourse?.id == courseId) {
        _selectedCourse = updatedCourse;
      }

      setLoading(false);
      return true;
    } catch (e) {
      setLoading(false);
      setError(e.toString());
      return false;
    }
  }

  Future<bool> setEnrollmentWindow(
      int courseId, DateTime startDate, DateTime endDate, int capacity) async {
    setLoading(true);
    setError(null);

    try {
      final updatedCourse = await _courseRepository.setEnrollmentWindow(
          courseId, startDate, endDate, capacity);

      final index = _courses.indexWhere((course) => course.id == courseId);
      if (index != -1) {
        _courses[index] = updatedCourse;
      }

      if (_selectedCourse?.id == courseId) {
        _selectedCourse = updatedCourse;
      }

      setLoading(false);
      return true;
    } catch (e) {
      setLoading(false);
      setError(e.toString());
      return false;
    }
  }

  // Teacher methods
  Future<bool> fetchAssignedCourses() async {
    setLoading(true);
    setError(null);

    try {
      _courses = await _courseRepository.getAssignedCourses();
      setLoading(false);
      return true;
    } catch (e) {
      setLoading(false);
      setError(e.toString());
      return false;
    }
  }

  // Student methods
  Future<bool> fetchEnrolledCourses() async {
    setLoading(true);
    setError(null);

    try {
      _courses = await _courseRepository.getEnrolledCourses();
      setLoading(false);
      return true;
    } catch (e) {
      setLoading(false);
      setError(e.toString());
      return false;
    }
  }

  Future<bool> getEnrolledCourses() async {
    setLoading(true);
    setError(null);

    try {
      _enrolledCourses = await _courseRepository.getEnrolledCourses();
      setLoading(false);
      return true;
    } catch (e) {
      setLoading(false);
      setError(e.toString());
      return false;
    }
  }

  Future<bool> getAvailableCourses() async {
    setLoading(true);
    setError(null);

    try {
      _availableCourses = await _courseRepository.getAvailableCourses();
      setLoading(false);
      return true;
    } catch (e) {
      setLoading(false);
      setError(e.toString());
      return false;
    }
  }

  Future<bool> getCourseById(String courseId) async {
    setLoading(true);
    setError(null);

    try {
      _currentCourse =
          await _courseRepository.getCourseById(int.parse(courseId));
      setLoading(false);
      return true;
    } catch (e) {
      setLoading(false);
      setError(e.toString());
      return false;
    }
  }

  Future<bool> getCourseMaterials(String courseId) async {
    setLoading(true);
    setError(null);

    try {
      _courseMaterials =
          await _courseRepository.getCourseMaterials(int.parse(courseId));
      setLoading(false);
      return true;
    } catch (e) {
      setLoading(false);
      setError(e.toString());
      return false;
    }
  }

  Future<bool> enrollInCourse(int courseId, String paymentIntentId) async {
    setLoading(true);
    setError(null);

    try {
      final result =
          await _courseRepository.enrollInCourse(courseId, paymentIntentId);

      if (result) {
        // Refresh the course list after enrollment
        await fetchEnrolledCourses();
      }

      setLoading(false);
      return result;
    } catch (e) {
      setLoading(false);
      setError(e.toString());
      return false;
    }
  }

  Future<bool> enrollCourseWithPayment(
      String courseId, Map<String, dynamic> paymentData) async {
    setLoading(true);
    setError(null);

    try {
      // In a real implementation, this would process payment data via a payment processor
      // For now, we're just simulating with a fake payment intent
      final paymentIntentId = "pi_${DateTime.now().millisecondsSinceEpoch}";

      final result = await _courseRepository.enrollInCourse(
          int.parse(courseId), paymentIntentId);

      if (result) {
        // Refresh the course list after enrollment
        await getEnrolledCourses();
      }

      setLoading(false);
      return result;
    } catch (e) {
      setLoading(false);
      setError(e.toString());
      return false;
    }
  }

  Future<bool> joinWaitlist(int courseId) async {
    setLoading(true);
    setError(null);

    try {
      final result = await _courseRepository.joinWaitlist(courseId);
      setLoading(false);
      return result;
    } catch (e) {
      setLoading(false);
      setError(e.toString());
      return false;
    }
  }

  Future<bool> joinCourseWaitlist(String courseId) async {
    setLoading(true);
    setError(null);

    try {
      final result = await _courseRepository.joinWaitlist(int.parse(courseId));
      setLoading(false);
      return result;
    } catch (e) {
      setLoading(false);
      setError(e.toString());
      return false;
    }
  }
}
