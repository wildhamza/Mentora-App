import 'package:equatable/equatable.dart';

class QuizModel extends Equatable {
  final int id;
  final int courseId;
  final String title;
  final String description;
  final DateTime startTime;
  final DateTime endTime;
  final int durationMinutes;
  final double totalMarks;
  final List<QuestionModel> questions;
  final double? obtainedMarks;
  final DateTime? attemptedAt;

  const QuizModel({
    required this.id,
    required this.courseId,
    required this.title,
    required this.description,
    required this.startTime,
    required this.endTime,
    required this.durationMinutes,
    required this.totalMarks,
    required this.questions,
    this.obtainedMarks,
    this.attemptedAt,
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
      totalMarks: json['total_marks'].toDouble(),
      questions: json['questions'] != null
          ? List<QuestionModel>.from(
              json['questions'].map((q) => QuestionModel.fromJson(q)))
          : [],
      obtainedMarks: json['obtained_marks']?.toDouble(),
      attemptedAt: json['attempted_at'] != null
          ? DateTime.parse(json['attempted_at'])
          : null,
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
      'total_marks': totalMarks,
      'questions': questions.map((q) => q.toJson()).toList(),
      'obtained_marks': obtainedMarks,
      'attempted_at': attemptedAt?.toIso8601String(),
    };
  }

  bool get isAttempted => attemptedAt != null;
  bool get isActive => DateTime.now().isAfter(startTime) && DateTime.now().isBefore(endTime);
  bool get isUpcoming => DateTime.now().isBefore(startTime);
  bool get isExpired => DateTime.now().isAfter(endTime);

  QuizModel copyWith({
    int? id,
    int? courseId,
    String? title,
    String? description,
    DateTime? startTime,
    DateTime? endTime,
    int? durationMinutes,
    double? totalMarks,
    List<QuestionModel>? questions,
    double? obtainedMarks,
    DateTime? attemptedAt,
  }) {
    return QuizModel(
      id: id ?? this.id,
      courseId: courseId ?? this.courseId,
      title: title ?? this.title,
      description: description ?? this.description,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      totalMarks: totalMarks ?? this.totalMarks,
      questions: questions ?? this.questions,
      obtainedMarks: obtainedMarks ?? this.obtainedMarks,
      attemptedAt: attemptedAt ?? this.attemptedAt,
    );
  }

  @override
  List<Object?> get props => [
    id, courseId, title, description, startTime, endTime,
    durationMinutes, totalMarks, questions, obtainedMarks, attemptedAt
  ];
}

class QuestionModel extends Equatable {
  final int id;
  final String question;
  final List<String> options;
  final int correctOptionIndex;
  final double marks;
  final int? selectedOptionIndex;

  const QuestionModel({
    required this.id,
    required this.question,
    required this.options,
    required this.correctOptionIndex,
    required this.marks,
    this.selectedOptionIndex,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      id: json['id'],
      question: json['question'],
      options: List<String>.from(json['options']),
      correctOptionIndex: json['correct_option_index'],
      marks: json['marks'].toDouble(),
      selectedOptionIndex: json['selected_option_index'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'options': options,
      'correct_option_index': correctOptionIndex,
      'marks': marks,
      'selected_option_index': selectedOptionIndex,
    };
  }

  bool get isAnswered => selectedOptionIndex != null;
  bool get isCorrect => selectedOptionIndex == correctOptionIndex;

  QuestionModel copyWith({
    int? id,
    String? question,
    List<String>? options,
    int? correctOptionIndex,
    double? marks,
    int? selectedOptionIndex,
  }) {
    return QuestionModel(
      id: id ?? this.id,
      question: question ?? this.question,
      options: options ?? this.options,
      correctOptionIndex: correctOptionIndex ?? this.correctOptionIndex,
      marks: marks ?? this.marks,
      selectedOptionIndex: selectedOptionIndex ?? this.selectedOptionIndex,
    );
  }

  @override
  List<Object?> get props => [
    id, question, options, correctOptionIndex, marks, selectedOptionIndex
  ];
}
