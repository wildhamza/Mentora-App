import 'package:equatable/equatable.dart';

class QuizModel extends Equatable {
  final int id;
  final int courseId;
  final String title;
  final String description;
  final DateTime startTime;
  final DateTime endTime;
  final int durationMinutes;
  final int totalQuestions;
  final int totalMarks;
  final String status; // DRAFT, PUBLISHED
  final DateTime createdAt;
  final DateTime updatedAt;

  const QuizModel({
    required this.id,
    required this.courseId,
    required this.title,
    required this.description,
    required this.startTime,
    required this.endTime,
    required this.durationMinutes,
    required this.totalQuestions,
    required this.totalMarks,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory QuizModel.fromJson(Map<String, dynamic> json) {
    return QuizModel(
      id: json['id'],
      courseId: json['course_id'],
      title: json['title'],
      description: json['description'],
      startTime: DateTime.parse(json['start_time']),
      endTime: DateTime.parse(json['end_time']),
      durationMinutes: json['duration_minutes'],
      totalQuestions: json['total_questions'],
      totalMarks: json['total_marks'],
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'course_id': courseId,
      'title': title,
      'description': description,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'duration_minutes': durationMinutes,
      'total_questions': totalQuestions,
      'total_marks': totalMarks,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        courseId,
        title,
        description,
        startTime,
        endTime,
        durationMinutes,
        totalQuestions,
        totalMarks,
        status,
        createdAt,
        updatedAt,
      ];
}

class QuizQuestionModel extends Equatable {
  final int id;
  final int quizId;
  final String question;
  final String questionType; // MCQ, TRUE_FALSE, SHORT_ANSWER
  final List<QuizOptionModel>? options;
  final String? correctAnswer;
  final int marks;

  const QuizQuestionModel({
    required this.id,
    required this.quizId,
    required this.question,
    required this.questionType,
    this.options,
    this.correctAnswer,
    required this.marks,
  });

  factory QuizQuestionModel.fromJson(Map<String, dynamic> json) {
    return QuizQuestionModel(
      id: json['id'],
      quizId: json['quiz_id'],
      question: json['question'],
      questionType: json['question_type'],
      options: json['options'] != null
          ? (json['options'] as List)
              .map((option) => QuizOptionModel.fromJson(option))
              .toList()
          : null,
      correctAnswer: json['correct_answer'],
      marks: json['marks'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'quiz_id': quizId,
      'question': question,
      'question_type': questionType,
      'options': options?.map((option) => option.toJson()).toList(),
      'correct_answer': correctAnswer,
      'marks': marks,
    };
  }

  @override
  List<Object?> get props => [
        id,
        quizId,
        question,
        questionType,
        options,
        correctAnswer,
        marks,
      ];
}

class QuizOptionModel extends Equatable {
  final String id;
  final String text;

  const QuizOptionModel({
    required this.id,
    required this.text,
  });

  factory QuizOptionModel.fromJson(Map<String, dynamic> json) {
    return QuizOptionModel(
      id: json['id'],
      text: json['text'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
    };
  }

  @override
  List<Object?> get props => [id, text];
}

class QuizAttemptModel extends Equatable {
  final int id;
  final int quizId;
  final int studentId;
  final DateTime startTime;
  final DateTime? endTime;
  final int obtainedMarks;
  final int totalMarks;
  final String status; // IN_PROGRESS, COMPLETED, TIMEOUT
  final DateTime createdAt;
  final DateTime updatedAt;

  const QuizAttemptModel({
    required this.id,
    required this.quizId,
    required this.studentId,
    required this.startTime,
    this.endTime,
    required this.obtainedMarks,
    required this.totalMarks,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory QuizAttemptModel.fromJson(Map<String, dynamic> json) {
    return QuizAttemptModel(
      id: json['id'],
      quizId: json['quiz_id'],
      studentId: json['student_id'],
      startTime: DateTime.parse(json['start_time']),
      endTime: json['end_time'] != null
          ? DateTime.parse(json['end_time'])
          : null,
      obtainedMarks: json['obtained_marks'],
      totalMarks: json['total_marks'],
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'quiz_id': quizId,
      'student_id': studentId,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime?.toIso8601String(),
      'obtained_marks': obtainedMarks,
      'total_marks': totalMarks,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        quizId,
        studentId,
        startTime,
        endTime,
        obtainedMarks,
        totalMarks,
        status,
        createdAt,
        updatedAt,
      ];
}
