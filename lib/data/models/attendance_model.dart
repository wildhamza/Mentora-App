import 'package:equatable/equatable.dart';

class AttendanceSessionModel extends Equatable {
  final int id;
  final int courseId;
  final String title;
  final DateTime sessionDate;
  final String status; // PENDING, ACTIVE, COMPLETED
  final DateTime createdAt;
  final DateTime updatedAt;

  const AttendanceSessionModel({
    required this.id,
    required this.courseId,
    required this.title,
    required this.sessionDate,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AttendanceSessionModel.fromJson(Map<String, dynamic> json) {
    return AttendanceSessionModel(
      id: json['id'],
      courseId: json['course_id'],
      title: json['title'],
      sessionDate: DateTime.parse(json['session_date']),
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
      'session_date': sessionDate.toIso8601String(),
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
        sessionDate,
        status,
        createdAt,
        updatedAt,
      ];
}

class AttendanceRecordModel extends Equatable {
  final int id;
  final int sessionId;
  final int studentId;
  final String studentName;
  final String status; // PRESENT, ABSENT, LATE
  final String? remarks;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AttendanceRecordModel({
    required this.id,
    required this.sessionId,
    required this.studentId,
    required this.studentName,
    required this.status,
    this.remarks,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AttendanceRecordModel.fromJson(Map<String, dynamic> json) {
    return AttendanceRecordModel(
      id: json['id'],
      sessionId: json['session_id'],
      studentId: json['student_id'],
      studentName: json['student_name'],
      status: json['status'],
      remarks: json['remarks'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'session_id': sessionId,
      'student_id': studentId,
      'student_name': studentName,
      'status': status,
      'remarks': remarks,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        sessionId,
        studentId,
        studentName,
        status,
        remarks,
        createdAt,
        updatedAt,
      ];
}

class AttendanceSessionWithRecordsModel extends Equatable {
  final AttendanceSessionModel session;
  final List<AttendanceRecordModel> records;

  const AttendanceSessionWithRecordsModel({
    required this.session,
    required this.records,
  });

  factory AttendanceSessionWithRecordsModel.fromJson(Map<String, dynamic> json) {
    return AttendanceSessionWithRecordsModel(
      session: AttendanceSessionModel.fromJson(json['session']),
      records: (json['records'] as List)
          .map((record) => AttendanceRecordModel.fromJson(record))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'session': session.toJson(),
      'records': records.map((record) => record.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [session, records];
}

class StudentAttendanceSummaryModel extends Equatable {
  final int courseId;
  final String courseName;
  final int totalSessions;
  final int presentCount;
  final int absentCount;
  final int lateCount;
  final double attendancePercentage;

  const StudentAttendanceSummaryModel({
    required this.courseId,
    required this.courseName,
    required this.totalSessions,
    required this.presentCount,
    required this.absentCount,
    required this.lateCount,
    required this.attendancePercentage,
  });

  factory StudentAttendanceSummaryModel.fromJson(Map<String, dynamic> json) {
    return StudentAttendanceSummaryModel(
      courseId: json['course_id'],
      courseName: json['course_name'],
      totalSessions: json['total_sessions'],
      presentCount: json['present_count'],
      absentCount: json['absent_count'],
      lateCount: json['late_count'],
      attendancePercentage: json['attendance_percentage'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'course_id': courseId,
      'course_name': courseName,
      'total_sessions': totalSessions,
      'present_count': presentCount,
      'absent_count': absentCount,
      'late_count': lateCount,
      'attendance_percentage': attendancePercentage,
    };
  }

  @override
  List<Object?> get props => [
        courseId,
        courseName,
        totalSessions,
        presentCount,
        absentCount,
        lateCount,
        attendancePercentage,
      ];
}
