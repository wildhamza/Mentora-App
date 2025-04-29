import 'package:equatable/equatable.dart';
import 'package:mentora/domain/entities/course.dart';

class CourseModel extends Equatable {
  final int id;
  final String title;
  final String description;
  final String status;
  final int duration; // in days
  final double fee;
  final int capacity;
  final int? instructorId;
  final String? instructorName;
  final DateTime? enrollmentStartDate;
  final DateTime? enrollmentEndDate;
  final int enrolledStudents;
  final String? thumbnailUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CourseModel({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.duration,
    required this.fee,
    required this.capacity,
    this.instructorId,
    this.instructorName,
    this.enrollmentStartDate,
    this.enrollmentEndDate,
    required this.enrolledStudents,
    this.thumbnailUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  // Convert API response to CourseModel
  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      status: json['status'],
      duration: json['duration'],
      fee: json['fee'].toDouble(),
      capacity: json['capacity'],
      instructorId: json['instructor_id'],
      instructorName: json['instructor_name'],
      enrollmentStartDate: json['enrollment_start_date'] != null
          ? DateTime.parse(json['enrollment_start_date'])
          : null,
      enrollmentEndDate: json['enrollment_end_date'] != null
          ? DateTime.parse(json['enrollment_end_date'])
          : null,
      enrolledStudents: json['enrolled_students'] ?? 0,
      thumbnailUrl: json['thumbnail_url'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  // Convert CourseModel to JSON for API requests
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'status': status,
      'duration': duration,
      'fee': fee,
      'capacity': capacity,
      'instructor_id': instructorId,
      'enrollment_start_date': enrollmentStartDate?.toIso8601String(),
      'enrollment_end_date': enrollmentEndDate?.toIso8601String(),
      'thumbnail_url': thumbnailUrl,
    };
  }

  // Convert CourseModel to Course entity
  Course toEntity() {
    return Course(
      id: id,
      title: title,
      description: description,
      status: status,
      duration: duration,
      fee: fee,
      capacity: capacity,
      instructorId: instructorId,
      instructorName: instructorName,
      enrollmentStartDate: enrollmentStartDate,
      enrollmentEndDate: enrollmentEndDate,
      enrolledStudents: enrolledStudents,
      thumbnailUrl: thumbnailUrl,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  // Create a copy of CourseModel with some fields changed
  CourseModel copyWith({
    int? id,
    String? title,
    String? description,
    String? status,
    int? duration,
    double? fee,
    int? capacity,
    int? instructorId,
    String? instructorName,
    DateTime? enrollmentStartDate,
    DateTime? enrollmentEndDate,
    int? enrolledStudents,
    String? thumbnailUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CourseModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      duration: duration ?? this.duration,
      fee: fee ?? this.fee,
      capacity: capacity ?? this.capacity,
      instructorId: instructorId ?? this.instructorId,
      instructorName: instructorName ?? this.instructorName,
      enrollmentStartDate: enrollmentStartDate ?? this.enrollmentStartDate,
      enrollmentEndDate: enrollmentEndDate ?? this.enrollmentEndDate,
      enrolledStudents: enrolledStudents ?? this.enrolledStudents,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        status,
        duration,
        fee,
        capacity,
        instructorId,
        instructorName,
        enrollmentStartDate,
        enrollmentEndDate,
        enrolledStudents,
        thumbnailUrl,
        createdAt,
        updatedAt,
      ];
}
