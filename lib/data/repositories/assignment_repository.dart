import '../models/assignment_model.dart';
import '../models/quiz_model.dart';
import '../datasources/api_service.dart';

class AssignmentRepository {
  final ApiService _apiService;

  AssignmentRepository({required ApiService apiService}) : _apiService = apiService;

  // Teacher methods
  Future<List<AssignmentModel>> getCourseAssignments(int courseId) async {
    try {
      final response = await _apiService.get('/courses/$courseId/assignments');
      
      final List<dynamic> assignmentsData = response['data'];
      return assignmentsData.map((json) => AssignmentModel.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<AssignmentModel> createAssignment(Map<String, dynamic> assignmentData) async {
    try {
      final response = await _apiService.post('/assignments', data: assignmentData);
      return AssignmentModel.fromJson(response['data']);
    } catch (e) {
      rethrow;
    }
  }

  Future<AssignmentModel> updateAssignment(int assignmentId, Map<String, dynamic> assignmentData) async {
    try {
      final response = await _apiService.put('/assignments/$assignmentId', data: assignmentData);
      return AssignmentModel.fromJson(response['data']);
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> deleteAssignment(int assignmentId) async {
    try {
      await _apiService.delete('/assignments/$assignmentId');
      return true;
    } catch (e) {
      rethrow;
    }
  }

  Future<AssignmentModel> gradeAssignment(int assignmentId, int studentId, double marks, String feedback) async {
    try {
      final response = await _apiService.put('/assignments/$assignmentId/grade', data: {
        'student_id': studentId,
        'marks': marks,
        'feedback': feedback,
      });
      return AssignmentModel.fromJson(response['data']);
    } catch (e) {
      rethrow;
    }
  }

  // Quiz methods (for teacher)
  Future<List<QuizModel>> getCourseQuizzes(int courseId) async {
    try {
      final response = await _apiService.get('/courses/$courseId/quizzes');
      
      final List<dynamic> quizzesData = response['data'];
      return quizzesData.map((json) => QuizModel.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<QuizModel> createQuiz(Map<String, dynamic> quizData) async {
    try {
      final response = await _apiService.post('/quizzes', data: quizData);
      return QuizModel.fromJson(response['data']);
    } catch (e) {
      rethrow;
    }
  }

  Future<QuizModel> updateQuiz(int quizId, Map<String, dynamic> quizData) async {
    try {
      final response = await _apiService.put('/quizzes/$quizId', data: quizData);
      return QuizModel.fromJson(response['data']);
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> deleteQuiz(int quizId) async {
    try {
      await _apiService.delete('/quizzes/$quizId');
      return true;
    } catch (e) {
      rethrow;
    }
  }

  // Student methods
  Future<List<AssignmentModel>> getStudentAssignments() async {
    try {
      final response = await _apiService.get('/student/assignments');
      
      final List<dynamic> assignmentsData = response['data'];
      return assignmentsData.map((json) => AssignmentModel.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<AssignmentModel> getAssignmentDetails(int assignmentId) async {
    try {
      final response = await _apiService.get('/assignments/$assignmentId');
      return AssignmentModel.fromJson(response['data']);
    } catch (e) {
      rethrow;
    }
  }

  Future<AssignmentModel> submitAssignment(int assignmentId, String content, List<String> attachmentUrls) async {
    try {
      final response = await _apiService.post('/student/assignments/$assignmentId/submit', data: {
        'content': content,
        'attachment_urls': attachmentUrls,
      });
      return AssignmentModel.fromJson(response['data']);
    } catch (e) {
      rethrow;
    }
  }

  // Quiz methods (for student)
  Future<List<QuizModel>> getStudentQuizzes() async {
    try {
      final response = await _apiService.get('/student/quizzes');
      
      final List<dynamic> quizzesData = response['data'];
      return quizzesData.map((json) => QuizModel.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<QuizModel> getQuizDetails(int quizId) async {
    try {
      final response = await _apiService.get('/quizzes/$quizId');
      return QuizModel.fromJson(response['data']);
    } catch (e) {
      rethrow;
    }
  }

  Future<QuizModel> submitQuiz(int quizId, List<Map<String, dynamic>> answers) async {
    try {
      final response = await _apiService.post('/student/quizzes/$quizId/submit', data: {
        'answers': answers,
      });
      return QuizModel.fromJson(response['data']);
    } catch (e) {
      rethrow;
    }
  }
}
