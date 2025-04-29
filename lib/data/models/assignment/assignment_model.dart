import 'package:equatable/equatable.dart';

class AssignmentModel extends Equatable {
  final int id;
  final int courseId;
  final String title;
  final String description;
  final DateTime dueDate;
  final int maxMarks;
  final String? fileUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AssignmentModel({
    required this.id,
    required this.courseId,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.maxMarks,
    this.fileUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  // Convert API response to AssignmentModel
  factory AssignmentModel.fromJson(Map<String, dynamic> json) {
    return AssignmentModel(
      id: json['id'],
      courseId: json['course_id'],
      title: json['title'],
      description: json['description'],
      dueDate: DateTime.parse(json['due_date']),
      maxMarks: json['max_marks'],
      fileUrl: json['file_url'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  // Convert AssignmentModel to JSON for API requests
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'course_id': courseId,
      'title': title,
      'description': description,
      'due_date': dueDate.toIso8601String(),
      'max_marks': maxMarks,
      'file_url': fileUrl,
    };
  }

  // Create a copy of AssignmentModel with some fields changed
  AssignmentModel copyWith({
    int? id,
    int? courseId,
    String? title,
    String? description,
    DateTime? dueDate,
    int? maxMarks,
    String? fileUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AssignmentModel(
      id: id ?? this.id,
      courseId: courseId ?? this.courseId,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      maxMarks: maxMarks ?? this.maxMarks,
      fileUrl: fileUrl ?? this.fileUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        courseId,
        title,
        description,
        dueDate,
        maxMarks,
        fileUrl,
        createdAt,
        updatedAt,
      ];
}

class AssignmentSubmissionModel extends Equatable {
  final int id;
  final int assignmentId;
  final int studentId;
  final String? fileUrl;
  final String? comments;
  final int? marks;
  final String? feedback;
  final DateTime submittedAt;
  final DateTime? gradedAt;

  const AssignmentSubmissionModel({
    required this.id,
    required this.assignmentId,
    required this.studentId,
    this.fileUrl,
    this.comments,
    this.marks,
    this.feedback,
    required this.submittedAt,
    this.gradedAt,
  });

  // Convert API response to AssignmentSubmissionModel
  factory AssignmentSubmissionModel.fromJson(Map<String, dynamic> json) {
    return AssignmentSubmissionModel(
      id: json['id'],
      assignmentId: json['assignment_id'],
      studentId: json['student_id'],
      fileUrl: json['file_url'],
      comments: json['comments'],
      marks: json['marks'],
      feedback: json['feedback'],
      submittedAt: DateTime.parse(json['submitted_at']),
      gradedAt: json['graded_at'] != null
          ? DateTime.parse(json['graded_at'])
          : null,
    );
  }

  // Convert AssignmentSubmissionModel to JSON for API requests
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'assignment_id': assignmentId,
      'student_id': studentId,
      'file_url': fileUrl,
      'comments': comments,
      'marks': marks,
      'feedback': feedback,
      'submitted_at': submittedAt.toIso8601String(),
      'graded_at': gradedAt?.toIso8601String(),
    };
  }

  // Create a copy of AssignmentSubmissionModel with some fields changed
  AssignmentSubmissionModel copyWith({
    int? id,
    int? assignmentId,
    int? studentId,
    String? fileUrl,
    String? comments,
    int? marks,
    String? feedback,
    DateTime? submittedAt,
    DateTime? gradedAt,
  }) {
    return AssignmentSubmissionModel(
      id: id ?? this.id,
      assignmentId: assignmentId ?? this.assignmentId,
      studentId: studentId ?? this.studentId,
      fileUrl: fileUrl ?? this.fileUrl,
      comments: comments ?? this.comments,
      marks: marks ?? this.marks,
      feedback: feedback ?? this.feedback,
      submittedAt: submittedAt ?? this.submittedAt,
      gradedAt: gradedAt ?? this.gradedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        assignmentId,
        studentId,
        fileUrl,
        comments,
        marks,
        feedback,
        submittedAt,
        gradedAt,
      ];
}
