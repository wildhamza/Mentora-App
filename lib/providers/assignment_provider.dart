import 'package:flutter/material.dart';
import '../data/models/assignment_model.dart';
import '../data/repositories/assignment_repository.dart';
import '../data/datasources/api_service.dart';

class AssignmentProvider extends ChangeNotifier {
  final AssignmentRepository _assignmentRepository = AssignmentRepository(apiService: ApiService());
  
  List<AssignmentModel> _assignments = [];
  AssignmentModel? _selectedAssignment;
  AssignmentModel? _currentAssignment;
  bool _isLoading = false;
  String? _error;
  
  List<AssignmentModel> get assignments => _assignments;
  AssignmentModel? get selectedAssignment => _selectedAssignment;
  AssignmentModel? get currentAssignment => _currentAssignment;
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
  
  void setSelectedAssignment(AssignmentModel assignment) {
    _selectedAssignment = assignment;
    notifyListeners();
  }
  
  // Teacher methods
  Future<bool> fetchCourseAssignments(int courseId) async {
    setLoading(true);
    setError(null);
    
    try {
      _assignments = await _assignmentRepository.getCourseAssignments(courseId);
      setLoading(false);
      return true;
    } catch (e) {
      setLoading(false);
      setError(e.toString());
      return false;
    }
  }
  
  Future<bool> fetchAssignmentDetails(int assignmentId) async {
    setLoading(true);
    setError(null);
    
    try {
      _selectedAssignment = await _assignmentRepository.getAssignmentDetails(assignmentId);
      setLoading(false);
      return true;
    } catch (e) {
      setLoading(false);
      setError(e.toString());
      return false;
    }
  }
  
  Future<bool> createAssignment(Map<String, dynamic> assignmentData) async {
    setLoading(true);
    setError(null);
    
    try {
      final newAssignment = await _assignmentRepository.createAssignment(assignmentData);
      _assignments.add(newAssignment);
      setLoading(false);
      return true;
    } catch (e) {
      setLoading(false);
      setError(e.toString());
      return false;
    }
  }
  
  Future<bool> updateAssignment(int assignmentId, Map<String, dynamic> assignmentData) async {
    setLoading(true);
    setError(null);
    
    try {
      final updatedAssignment = await _assignmentRepository.updateAssignment(assignmentId, assignmentData);
      
      final index = _assignments.indexWhere((assignment) => assignment.id == assignmentId);
      if (index != -1) {
        _assignments[index] = updatedAssignment;
      }
      
      if (_selectedAssignment?.id == assignmentId) {
        _selectedAssignment = updatedAssignment;
      }
      
      setLoading(false);
      return true;
    } catch (e) {
      setLoading(false);
      setError(e.toString());
      return false;
    }
  }
  
  Future<bool> deleteAssignment(int assignmentId) async {
    setLoading(true);
    setError(null);
    
    try {
      final result = await _assignmentRepository.deleteAssignment(assignmentId);
      
      if (result) {
        _assignments.removeWhere((assignment) => assignment.id == assignmentId);
        
        if (_selectedAssignment?.id == assignmentId) {
          _selectedAssignment = null;
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
  
  Future<bool> gradeAssignment(int assignmentId, int studentId, double marks, String feedback) async {
    setLoading(true);
    setError(null);
    
    try {
      final gradedAssignment = await _assignmentRepository.gradeAssignment(assignmentId, studentId, marks, feedback);
      
      if (_selectedAssignment?.id == assignmentId) {
        _selectedAssignment = gradedAssignment;
      }
      
      setLoading(false);
      return true;
    } catch (e) {
      setLoading(false);
      setError(e.toString());
      return false;
    }
  }
  
  // Student methods
  Future<bool> fetchStudentAssignments() async {
    setLoading(true);
    setError(null);
    
    try {
      _assignments = await _assignmentRepository.getStudentAssignments();
      setLoading(false);
      return true;
    } catch (e) {
      setLoading(false);
      setError(e.toString());
      return false;
    }
  }
  
  Future<bool> submitAssignment(int assignmentId, String content, List<String> attachmentUrls) async {
    setLoading(true);
    setError(null);
    
    try {
      final submittedAssignment = await _assignmentRepository.submitAssignment(assignmentId, content, attachmentUrls);
      
      final index = _assignments.indexWhere((assignment) => assignment.id == assignmentId);
      if (index != -1) {
        _assignments[index] = submittedAssignment;
      }
      
      if (_selectedAssignment?.id == assignmentId) {
        _selectedAssignment = submittedAssignment;
      }
      
      setLoading(false);
      return true;
    } catch (e) {
      setLoading(false);
      setError(e.toString());
      return false;
    }
  }
  
  // Methods required by UI
  Future<bool> getAssignmentById(String assignmentId) async {
    setLoading(true);
    setError(null);
    
    try {
      // In a real app, fetch from API
      // Mock data for demo purposes
      _currentAssignment = AssignmentModel(
        id: int.parse(assignmentId),
        courseId: 1,
        title: 'Assignment ${assignmentId}',
        description: 'This is a sample assignment description for assignment ${assignmentId}',
        dueDate: DateTime.parse('2023-12-31'),
        totalMarks: 100,
        attachmentUrls: [],
        courseName: 'Sample Course',
      );
      
      // No need for external setting since courseName is now part of the constructor
      
      setLoading(false);
      return true;
    } catch (e) {
      setLoading(false);
      setError(e.toString());
      return false;
    }
  }
  
  Future<bool> submitAssignmentAnswer(String assignmentId, String answerText) async {
    setLoading(true);
    setError(null);
    
    try {
      // In a real app, send to API
      // For demo purposes, simulate success
      await Future.delayed(const Duration(seconds: 1));
      
      setLoading(false);
      return true;
    } catch (e) {
      setLoading(false);
      setError(e.toString());
      return false;
    }
  }
}
