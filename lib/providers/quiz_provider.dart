import 'package:flutter/material.dart';
import '../data/models/quiz_model.dart';
import '../data/repositories/assignment_repository.dart';
import '../data/datasources/api_service.dart';

class QuizProvider extends ChangeNotifier {
  final AssignmentRepository _assignmentRepository = AssignmentRepository(apiService: ApiService());
  
  List<QuizModel> _quizzes = [];
  QuizModel? _selectedQuiz;
  bool _isLoading = false;
  String? _error;
  
  List<QuizModel> get quizzes => _quizzes;
  QuizModel? get selectedQuiz => _selectedQuiz;
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
  
  void setSelectedQuiz(QuizModel quiz) {
    _selectedQuiz = quiz;
    notifyListeners();
  }
  
  // Teacher methods
  Future<bool> fetchCourseQuizzes(int courseId) async {
    setLoading(true);
    setError(null);
    
    try {
      _quizzes = await _assignmentRepository.getCourseQuizzes(courseId);
      setLoading(false);
      return true;
    } catch (e) {
      setLoading(false);
      setError(e.toString());
      return false;
    }
  }
  
  Future<bool> fetchQuizDetails(int quizId) async {
    setLoading(true);
    setError(null);
    
    try {
      _selectedQuiz = await _assignmentRepository.getQuizDetails(quizId);
      setLoading(false);
      return true;
    } catch (e) {
      setLoading(false);
      setError(e.toString());
      return false;
    }
  }
  
  Future<bool> createQuiz(Map<String, dynamic> quizData) async {
    setLoading(true);
    setError(null);
    
    try {
      final newQuiz = await _assignmentRepository.createQuiz(quizData);
      _quizzes.add(newQuiz);
      setLoading(false);
      return true;
    } catch (e) {
      setLoading(false);
      setError(e.toString());
      return false;
    }
  }
  
  Future<bool> updateQuiz(int quizId, Map<String, dynamic> quizData) async {
    setLoading(true);
    setError(null);
    
    try {
      final updatedQuiz = await _assignmentRepository.updateQuiz(quizId, quizData);
      
      final index = _quizzes.indexWhere((quiz) => quiz.id == quizId);
      if (index != -1) {
        _quizzes[index] = updatedQuiz;
      }
      
      if (_selectedQuiz?.id == quizId) {
        _selectedQuiz = updatedQuiz;
      }
      
      setLoading(false);
      return true;
    } catch (e) {
      setLoading(false);
      setError(e.toString());
      return false;
    }
  }
  
  Future<bool> deleteQuiz(int quizId) async {
    setLoading(true);
    setError(null);
    
    try {
      final result = await _assignmentRepository.deleteQuiz(quizId);
      
      if (result) {
        _quizzes.removeWhere((quiz) => quiz.id == quizId);
        
        if (_selectedQuiz?.id == quizId) {
          _selectedQuiz = null;
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
  
  // Student methods
  Future<bool> fetchStudentQuizzes() async {
    setLoading(true);
    setError(null);
    
    try {
      _quizzes = await _assignmentRepository.getStudentQuizzes();
      setLoading(false);
      return true;
    } catch (e) {
      setLoading(false);
      setError(e.toString());
      return false;
    }
  }
  
  Future<bool> submitQuiz(int quizId, List<Map<String, dynamic>> answers) async {
    setLoading(true);
    setError(null);
    
    try {
      final submittedQuiz = await _assignmentRepository.submitQuiz(quizId, answers);
      
      final index = _quizzes.indexWhere((quiz) => quiz.id == quizId);
      if (index != -1) {
        _quizzes[index] = submittedQuiz;
      }
      
      if (_selectedQuiz?.id == quizId) {
        _selectedQuiz = submittedQuiz;
      }
      
      setLoading(false);
      return true;
    } catch (e) {
      setLoading(false);
      setError(e.toString());
      return false;
    }
  }
}
