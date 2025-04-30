import 'package:flutter/material.dart';
import '../data/models/quiz_model.dart';
import '../data/repositories/assignment_repository.dart';
import '../data/datasources/api_service.dart';

class QuizProvider extends ChangeNotifier {
  final AssignmentRepository _assignmentRepository = AssignmentRepository(apiService: ApiService());
  
  List<QuizModel> _quizzes = [];
  QuizModel? _selectedQuiz;
  QuizModel? _currentQuiz;
  Map<String, dynamic>? _quizResult;
  bool _isLoading = false;
  String? _error;
  
  List<QuizModel> get quizzes => _quizzes;
  QuizModel? get selectedQuiz => _selectedQuiz;
  QuizModel? get currentQuiz => _currentQuiz;
  Map<String, dynamic>? get quizResult => _quizResult;
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
  
  // Additional Methods required by UI
  Future<bool> getQuizById(String quizId) async {
    setLoading(true);
    setError(null);
    
    try {
      // In a real implementation, fetch from API
      // For demo purposes, create a mock quiz
      _currentQuiz = QuizModel(
        id: int.parse(quizId),
        courseId: 1,
        title: 'Quiz ${quizId}',
        description: 'This is a sample quiz to test your knowledge',
        startTime: DateTime.now().subtract(const Duration(days: 1)),
        endTime: DateTime.now().add(const Duration(days: 7)),
        durationMinutes: 60,
        totalMarks: 100,
        questions: [
          QuestionModel(
            id: 1,
            question: 'What is the capital of Pakistan?',
            options: ['Lahore', 'Karachi', 'Islamabad', 'Peshawar'],
            correctOptionIndex: 2,
            marks: 10,
          ),
          QuestionModel(
            id: 2,
            question: 'Which programming language is Flutter based on?',
            options: ['Java', 'Dart', 'C++', 'JavaScript'],
            correctOptionIndex: 1,
            marks: 10,
          ),
        ],
      );
      
      setLoading(false);
      return true;
    } catch (e) {
      setLoading(false);
      setError(e.toString());
      return false;
    }
  }
  
  Future<bool> submitQuizAnswers(String quizId, List<Map<String, dynamic>> answers) async {
    setLoading(true);
    setError(null);
    
    try {
      // In a real implementation, this would call the API
      // For demo purposes, we'll simulate a success
      await Future.delayed(const Duration(seconds: 1));
      
      // Set quiz result
      _quizResult = {
        'quiz_id': quizId,
        'score': 85, // Sample score
        'total': 100,
        'passing_score': 60,
        'passed': true,
        'correct_answers': 17,
        'total_questions': 20,
        'time_taken': '10:25',
        'feedback': 'Excellent work! You have a good understanding of the subject.',
      };
      
      setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      setLoading(false);
      setError(e.toString());
      return false;
    }
  }
  
  // For compatibility with UI expecting a quiz ID as String and Map<int, int> answers
  Future<bool> submitQuizWithAnswerMap(String quizId, Map<int, int> answers) async {
    setLoading(true);
    setError(null);
    
    try {
      // Convert Map<int, int> to List<Map<String, dynamic>> format
      List<Map<String, dynamic>> formattedAnswers = [];
      
      answers.forEach((questionId, answerId) {
        formattedAnswers.add({
          'question_id': questionId,
          'selected_option': answerId,
        });
      });
      
      // Call the existing method with the formatted data
      await submitQuizAnswers(quizId, formattedAnswers);
      
      setLoading(false);
      return true;
    } catch (e) {
      setLoading(false);
      setError(e.toString());
      return false;
    }
  }
}
