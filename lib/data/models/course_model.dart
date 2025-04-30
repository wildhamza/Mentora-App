import 'package:equatable/equatable.dart';

class CourseModel extends Equatable {
  final int id;
  final String title;
  final String description;
  final double fees;
  final int capacity;
  final DateTime? startDate;
  final DateTime? endDate;
  final int? instructorId;
  final String? instructorName;
  final int enrolledCount;
  final bool isEnrollmentOpen;
  final String? thumbnail;

  const CourseModel({
    required this.id,
    required this.title,
    required this.description,
    required this.fees,
    required this.capacity,
    this.startDate,
    this.endDate,
    this.instructorId,
    this.instructorName,
    this.enrolledCount = 0,
    this.isEnrollmentOpen = false,
    this.thumbnail,
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      fees: json['fees'].toDouble(),
      capacity: json['capacity'],
      startDate: json['start_date'] != null ? DateTime.parse(json['start_date']) : null,
      endDate: json['end_date'] != null ? DateTime.parse(json['end_date']) : null,
      instructorId: json['instructor_id'],
      instructorName: json['instructor_name'],
      enrolledCount: json['enrolled_count'] ?? 0,
      isEnrollmentOpen: json['is_enrollment_open'] ?? false,
      thumbnail: json['thumbnail'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'fees': fees,
      'capacity': capacity,
      'start_date': startDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'instructor_id': instructorId,
      'instructor_name': instructorName,
      'enrolled_count': enrolledCount,
      'is_enrollment_open': isEnrollmentOpen,
      'thumbnail': thumbnail,
    };
  }

  bool get isFull => enrolledCount >= capacity;

  bool get hasInstructor => instructorId != null;
  
  int? get currentEnrollment => enrolledCount;
  
  int? get maxCapacity => capacity;
  
  double? get fee => fees;
  
  String? get duration {
    if (startDate != null && endDate != null) {
      final difference = endDate!.difference(startDate!);
      final days = difference.inDays;
      if (days > 30) {
        final months = (days / 30).floor();
        return '$months months';
      } else {
        return '$days days';
      }
    }
    return 'Not specified';
  }

  CourseModel copyWith({
    int? id,
    String? title,
    String? description,
    double? fees,
    int? capacity,
    DateTime? startDate,
    DateTime? endDate,
    int? instructorId,
    String? instructorName,
    int? enrolledCount,
    bool? isEnrollmentOpen,
    String? thumbnail,
  }) {
    return CourseModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      fees: fees ?? this.fees,
      capacity: capacity ?? this.capacity,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      instructorId: instructorId ?? this.instructorId,
      instructorName: instructorName ?? this.instructorName,
      enrolledCount: enrolledCount ?? this.enrolledCount,
      isEnrollmentOpen: isEnrollmentOpen ?? this.isEnrollmentOpen,
      thumbnail: thumbnail ?? this.thumbnail,
    );
  }

  @override
  List<Object?> get props => [
    id, title, description, fees, capacity, startDate,
    endDate, instructorId, instructorName, enrolledCount,
    isEnrollmentOpen, thumbnail
  ];
}
