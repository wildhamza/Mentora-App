import 'package:flutter/material.dart';
import '../data/models/course_model.dart';
import '../data/repositories/course_repository.dart';
import '../data/datasources/api_service.dart';

class CourseProvider extends ChangeNotifier {
  final CourseRepository _courseRepository = CourseRepository(apiService: ApiService());
  
  List<CourseModel> _courses = [];
  CourseModel? _selectedCourse;
  bool _isLoading = false;
  String? _error;
  
  List<CourseModel> get courses => _courses;
  CourseModel? get selectedCourse => _selectedCourse;
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
  
  Future<bool> updateCourse(int courseId, Map<String, dynamic> courseData) async {
    setLoading(true);
    setError(null);
    
    try {
      final updatedCourse = await _courseRepository.updateCourse(courseId, courseData);
      
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
      final updatedCourse = await _courseRepository.assignInstructor(courseId, instructorId);
      
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
  
  Future<bool> setEnrollmentWindow(int courseId, DateTime startDate, DateTime endDate, int capacity) async {
    setLoading(true);
    setError(null);
    
    try {
      final updatedCourse = await _courseRepository.setEnrollmentWindow(courseId, startDate, endDate, capacity);
      
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
  
  Future<bool> enrollInCourse(int courseId, String paymentIntentId) async {
    setLoading(true);
    setError(null);
    
    try {
      final result = await _courseRepository.enrollInCourse(courseId, paymentIntentId);
      
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
}
