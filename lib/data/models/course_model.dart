import 'package:equatable/equatable.dart';

import '../../domain/entities/course.dart';

class CourseModel extends Equatable {
  final int id;
  final String title;
  final String description;
  final int durationMinutes;
  final double fee;
  final int capacity;
  final String status;
  final String? thumbnailUrl;
  final int? instructorId;
  final String? instructorName;
  final DateTime? enrollmentStartDate;
  final DateTime? enrollmentEndDate;
  final int enrolledStudents;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CourseModel({
    required this.id,
    required this.title,
    required this.description,
    required this.durationMinutes,
    required this.fee,
    required this.capacity,
    required this.status,
    this.thumbnailUrl,
    this.instructorId,
    this.instructorName,
    this.enrollmentStartDate,
    this.enrollmentEndDate,
    required this.enrolledStudents,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      durationMinutes: json['duration_minutes'],
      fee: json['fee'].toDouble(),
      capacity: json['capacity'],
      status: json['status'],
      thumbnailUrl: json['thumbnail_url'],
      instructorId: json['instructor_id'],
      instructorName: json['instructor_name'],
      enrollmentStartDate: json['enrollment_start_date'] != null 
          ? DateTime.parse(json['enrollment_start_date']) 
          : null,
      enrollmentEndDate: json['enrollment_end_date'] != null 
          ? DateTime.parse(json['enrollment_end_date']) 
          : null,
      enrolledStudents: json['enrolled_students'] ?? 0,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'duration_minutes': durationMinutes,
      'fee': fee,
      'capacity': capacity,
      'status': status,
      'thumbnail_url': thumbnailUrl,
      'instructor_id': instructorId,
      'instructor_name': instructorName,
      'enrollment_start_date': enrollmentStartDate?.toIso8601String(),
      'enrollment_end_date': enrollmentEndDate?.toIso8601String(),
      'enrolled_students': enrolledStudents,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Convert to domain entity
  Course toEntity() {
    return Course(
      id: id,
      title: title,
      description: description,
      durationMinutes: durationMinutes,
      fee: fee,
      capacity: capacity,
      status: status,
      thumbnailUrl: thumbnailUrl,
      instructorId: instructorId,
      instructorName: instructorName,
      enrollmentStartDate: enrollmentStartDate,
      enrollmentEndDate: enrollmentEndDate,
      enrolledStudents: enrolledStudents,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  // Create model from entity
  factory CourseModel.fromEntity(Course course) {
    return CourseModel(
      id: course.id,
      title: course.title,
      description: course.description,
      durationMinutes: course.durationMinutes,
      fee: course.fee,
      capacity: course.capacity,
      status: course.status,
      thumbnailUrl: course.thumbnailUrl,
      instructorId: course.instructorId,
      instructorName: course.instructorName,
      enrollmentStartDate: course.enrollmentStartDate,
      enrollmentEndDate: course.enrollmentEndDate,
      enrolledStudents: course.enrolledStudents,
      createdAt: course.createdAt,
      updatedAt: course.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        durationMinutes,
        fee,
        capacity,
        status,
        thumbnailUrl,
        instructorId,
        instructorName,
        enrollmentStartDate,
        enrollmentEndDate,
        enrolledStudents,
        createdAt,
        updatedAt,
      ];
}

class CourseResponseModel extends Equatable {
  final List<CourseModel> courses;
  final int total;
  final int page;
  final int limit;

  const CourseResponseModel({
    required this.courses,
    required this.total,
    required this.page,
    required this.limit,
  });

  factory CourseResponseModel.fromJson(Map<String, dynamic> json) {
    return CourseResponseModel(
      courses: (json['data'] as List)
          .map((courseJson) => CourseModel.fromJson(courseJson))
          .toList(),
      total: json['meta']['total'],
      page: json['meta']['page'],
      limit: json['meta']['limit'],
    );
  }

  @override
  List<Object?> get props => [courses, total, page, limit];
}
