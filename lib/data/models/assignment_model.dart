import 'package:equatable/equatable.dart';

class AssignmentModel extends Equatable {
  final int id;
  final int courseId;
  final String title;
  final String description;
  final DateTime dueDate;
  final double totalMarks;
  final List<String>? attachmentUrls;
  final DateTime? submissionDate;
  final String? submissionContent;
  final List<String>? submissionAttachments;
  final double? obtainedMarks;
  final String? feedback;

  const AssignmentModel({
    required this.id,
    required this.courseId,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.totalMarks,
    this.attachmentUrls,
    this.submissionDate,
    this.submissionContent,
    this.submissionAttachments,
    this.obtainedMarks,
    this.feedback,
    this.courseName,
  });

  factory AssignmentModel.fromJson(Map<String, dynamic> json) {
    return AssignmentModel(
      id: json['id'],
      courseId: json['course_id'],
      title: json['title'],
      description: json['description'],
      dueDate: DateTime.parse(json['due_date']),
      totalMarks: json['total_marks'].toDouble(),
      attachmentUrls: json['attachment_urls'] != null 
          ? List<String>.from(json['attachment_urls']) 
          : null,
      submissionDate: json['submission_date'] != null 
          ? DateTime.parse(json['submission_date']) 
          : null,
      submissionContent: json['submission_content'],
      submissionAttachments: json['submission_attachments'] != null 
          ? List<String>.from(json['submission_attachments']) 
          : null,
      obtainedMarks: json['obtained_marks']?.toDouble(),
      feedback: json['feedback'],
      courseName: json['course_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'course_id': courseId,
      'title': title,
      'description': description,
      'due_date': dueDate.toIso8601String(),
      'total_marks': totalMarks,
      'attachment_urls': attachmentUrls,
      'submission_date': submissionDate?.toIso8601String(),
      'submission_content': submissionContent,
      'submission_attachments': submissionAttachments,
      'obtained_marks': obtainedMarks,
      'feedback': feedback,
      'course_name': courseName,
    };
  }

  bool get isSubmitted => submissionDate != null;
  bool get isOverdue => DateTime.now().isAfter(dueDate) && !isSubmitted;
  bool get isEvaluated => obtainedMarks != null;
  
  // Aliases for UI compatibility
  List<String>? get attachments => attachmentUrls;
  double? get totalPoints => totalMarks;
  
  // For UI compatibility
  final String? courseName;
  
  // Format due date as string
  String get dueDateFormatted => "${dueDate.day}/${dueDate.month}/${dueDate.year}";
  
  // Convert due date to string for display
  String get dueDate2 => dueDateFormatted;

  AssignmentModel copyWith({
    int? id,
    int? courseId,
    String? title,
    String? description,
    DateTime? dueDate,
    double? totalMarks,
    List<String>? attachmentUrls,
    DateTime? submissionDate,
    String? submissionContent,
    List<String>? submissionAttachments,
    double? obtainedMarks,
    String? feedback,
    String? courseName,
  }) {
    return AssignmentModel(
      id: id ?? this.id,
      courseId: courseId ?? this.courseId,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      totalMarks: totalMarks ?? this.totalMarks,
      attachmentUrls: attachmentUrls ?? this.attachmentUrls,
      submissionDate: submissionDate ?? this.submissionDate,
      submissionContent: submissionContent ?? this.submissionContent,
      submissionAttachments: submissionAttachments ?? this.submissionAttachments,
      obtainedMarks: obtainedMarks ?? this.obtainedMarks,
      feedback: feedback ?? this.feedback,
      courseName: courseName ?? this.courseName,
    );
  }

  @override
  List<Object?> get props => [
    id, courseId, title, description, dueDate, totalMarks,
    attachmentUrls, submissionDate, submissionContent,
    submissionAttachments, obtainedMarks, feedback, courseName
  ];
}
