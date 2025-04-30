import 'package:equatable/equatable.dart';

class AttendanceModel extends Equatable {
  final int id;
  final int courseId;
  final String courseName;
  final DateTime date;
  final List<StudentAttendance> students;

  const AttendanceModel({
    required this.id,
    required this.courseId,
    required this.courseName,
    required this.date,
    required this.students,
  });

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      id: json['id'],
      courseId: json['course_id'],
      courseName: json['course_name'],
      date: DateTime.parse(json['date']),
      students: json['students'] != null
          ? List<StudentAttendance>.from(
              json['students'].map((s) => StudentAttendance.fromJson(s)))
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'course_id': courseId,
      'course_name': courseName,
      'date': date.toIso8601String(),
      'students': students.map((s) => s.toJson()).toList(),
    };
  }

  int get presentCount => students.where((s) => s.isPresent).length;
  int get absentCount => students.where((s) => !s.isPresent).length;
  double get attendancePercentage => students.isEmpty ? 0 : (presentCount / students.length) * 100;

  AttendanceModel copyWith({
    int? id,
    int? courseId,
    String? courseName,
    DateTime? date,
    List<StudentAttendance>? students,
  }) {
    return AttendanceModel(
      id: id ?? this.id,
      courseId: courseId ?? this.courseId,
      courseName: courseName ?? this.courseName,
      date: date ?? this.date,
      students: students ?? this.students,
    );
  }

  @override
  List<Object?> get props => [id, courseId, courseName, date, students];
}

class StudentAttendance extends Equatable {
  final int studentId;
  final String studentName;
  final bool isPresent;

  const StudentAttendance({
    required this.studentId,
    required this.studentName,
    required this.isPresent,
  });

  factory StudentAttendance.fromJson(Map<String, dynamic> json) {
    return StudentAttendance(
      studentId: json['student_id'],
      studentName: json['student_name'],
      isPresent: json['is_present'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'student_id': studentId,
      'student_name': studentName,
      'is_present': isPresent,
    };
  }

  StudentAttendance copyWith({
    int? studentId,
    String? studentName,
    bool? isPresent,
  }) {
    return StudentAttendance(
      studentId: studentId ?? this.studentId,
      studentName: studentName ?? this.studentName,
      isPresent: isPresent ?? this.isPresent,
    );
  }

  @override
  List<Object?> get props => [studentId, studentName, isPresent];
}

class StudentAttendanceSummary extends Equatable {
  final int studentId;
  final String studentName;
  final int totalClasses;
  final int presentCount;

  const StudentAttendanceSummary({
    required this.studentId,
    required this.studentName,
    required this.totalClasses,
    required this.presentCount,
  });

  factory StudentAttendanceSummary.fromJson(Map<String, dynamic> json) {
    return StudentAttendanceSummary(
      studentId: json['student_id'],
      studentName: json['student_name'],
      totalClasses: json['total_classes'],
      presentCount: json['present_count'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'student_id': studentId,
      'student_name': studentName,
      'total_classes': totalClasses,
      'present_count': presentCount,
    };
  }

  double get attendancePercentage => totalClasses > 0 ? (presentCount / totalClasses) * 100 : 0;

  @override
  List<Object?> get props => [studentId, studentName, totalClasses, presentCount];
}
