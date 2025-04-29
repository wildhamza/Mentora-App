import 'package:equatable/equatable.dart';

class AssignmentModel extends Equatable {
  final int id;
  final int courseId;
  final String title;
  final String description;
  final DateTime dueDate;
  final List<String>? attachmentUrls;
  final int? maxScore;
  final String status; // DRAFT, PUBLISHED
  final DateTime createdAt;
  final DateTime updatedAt;

  const AssignmentModel({
    required this.id,
    required this.courseId,
    required this.title,
    required this.description,
    required this.dueDate,
    this.attachmentUrls,
    this.maxScore,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AssignmentModel.fromJson(Map<String, dynamic> json) {
    return AssignmentModel(
      id: json['id'],
      courseId: json['course_id'],
      title: json['title'],
      description: json['description'],
      dueDate: DateTime.parse(json['due_date']),
      attachmentUrls: json['attachment_urls'] != null
          ? List<String>.from(json['attachment_urls'])
          : null,
      maxScore: json['max_score'],
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
      'due_date': dueDate.toIso8601String(),
      'attachment_urls': attachmentUrls,
      'max_score': maxScore,
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
        dueDate,
        attachmentUrls,
        maxScore,
        status,
        createdAt,
        updatedAt,
      ];
}

class AssignmentSubmissionModel extends Equatable {
  final int id;
  final int assignmentId;
  final int studentId;
  final String studentName;
  final String? text;
  final List<String>? attachmentUrls;
  final int? score;
  final String? feedback;
  final String status; // PENDING, SUBMITTED, GRADED
  final DateTime? submittedAt;
  final DateTime? gradedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AssignmentSubmissionModel({
    required this.id,
    required this.assignmentId,
    required this.studentId,
    required this.studentName,
    this.text,
    this.attachmentUrls,
    this.score,
    this.feedback,
    required this.status,
    this.submittedAt,
    this.gradedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AssignmentSubmissionModel.fromJson(Map<String, dynamic> json) {
    return AssignmentSubmissionModel(
      id: json['id'],
      assignmentId: json['assignment_id'],
      studentId: json['student_id'],
      studentName: json['student_name'],
      text: json['text'],
      attachmentUrls: json['attachment_urls'] != null
          ? List<String>.from(json['attachment_urls'])
          : null,
      score: json['score'],
      feedback: json['feedback'],
      status: json['status'],
      submittedAt: json['submitted_at'] != null
          ? DateTime.parse(json['submitted_at'])
          : null,
      gradedAt:
          json['graded_at'] != null ? DateTime.parse(json['graded_at']) : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'assignment_id': assignmentId,
      'student_id': studentId,
      'student_name': studentName,
      'text': text,
      'attachment_urls': attachmentUrls,
      'score': score,
      'feedback': feedback,
      'status': status,
      'submitted_at': submittedAt?.toIso8601String(),
      'graded_at': gradedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        assignmentId,
        studentId,
        studentName,
        text,
        attachmentUrls,
        score,
        feedback,
        status,
        submittedAt,
        gradedAt,
        createdAt,
        updatedAt,
      ];
}
