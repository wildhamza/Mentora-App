import 'package:equatable/equatable.dart';

class Course extends Equatable {
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

  const Course({
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

  // Check if course is full
  bool get isFull => enrolledStudents >= capacity;

  // Check if enrollment is currently open
  bool get isEnrollmentOpen {
    final now = DateTime.now();
    return enrollmentStartDate != null &&
        enrollmentEndDate != null &&
        now.isAfter(enrollmentStartDate!) &&
        now.isBefore(enrollmentEndDate!) &&
        status == 'active' &&
        !isFull;
  }

  // Check if course is active
  bool get isActive => status == 'active';

  // Get enrollment status text
  String get enrollmentStatusText {
    final now = DateTime.now();
    
    if (status != 'active') {
      return 'Not Available';
    }
    
    if (isFull) {
      return 'Full';
    }
    
    if (enrollmentStartDate != null && now.isBefore(enrollmentStartDate!)) {
      return 'Enrollment starts on ${_formatDate(enrollmentStartDate!)}';
    }
    
    if (enrollmentEndDate != null && now.isAfter(enrollmentEndDate!)) {
      return 'Enrollment closed';
    }
    
    return 'Open for Enrollment';
  }

  // Format date to readable string
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
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
