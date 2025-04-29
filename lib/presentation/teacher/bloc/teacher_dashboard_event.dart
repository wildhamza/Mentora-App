import 'package:equatable/equatable.dart';

abstract class TeacherDashboardEvent extends Equatable {
  const TeacherDashboardEvent();

  @override
  List<Object?> get props => [];
}

class LoadTeacherCoursesEvent extends TeacherDashboardEvent {}

class LoadCourseDetailsEvent extends TeacherDashboardEvent {
  final int courseId;

  const LoadCourseDetailsEvent(this.courseId);

  @override
  List<Object?> get props => [courseId];
}

class LoadCourseStudentsEvent extends TeacherDashboardEvent {
  final int courseId;

  const LoadCourseStudentsEvent(this.courseId);

  @override
  List<Object?> get props => [courseId];
}

class CreateAssignmentEvent extends TeacherDashboardEvent {
  final int courseId;
  final String title;
  final String description;
  final DateTime dueDate;
  final int maxMarks;
  final String? fileUrl;

  const CreateAssignmentEvent({
    required this.courseId,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.maxMarks,
    this.fileUrl,
  });

  @override
  List<Object?> get props => [courseId, title, description, dueDate, maxMarks, fileUrl];
}

class MarkAttendanceEvent extends TeacherDashboardEvent {
  final int courseId;
  final DateTime date;
  final Map<int, bool> studentAttendance; // studentId -> isPresent

  const MarkAttendanceEvent({
    required this.courseId,
    required this.date,
    required this.studentAttendance,
  });

  @override
  List<Object?> get props => [courseId, date, studentAttendance];
}

class ScheduleSessionEvent extends TeacherDashboardEvent {
  final int courseId;
  final String title;
  final String description;
  final DateTime startTime;
  final int durationMinutes;
  final String meetingLink;

  const ScheduleSessionEvent({
    required this.courseId,
    required this.title,
    required this.description,
    required this.startTime,
    required this.durationMinutes,
    required this.meetingLink,
  });

  @override
  List<Object?> get props => [
        courseId,
        title,
        description,
        startTime,
        durationMinutes,
        meetingLink,
      ];
}

class UploadMaterialEvent extends TeacherDashboardEvent {
  final int courseId;
  final String title;
  final String description;
  final String fileUrl;
  final String fileType;

  const UploadMaterialEvent({
    required this.courseId,
    required this.title,
    required this.description,
    required this.fileUrl,
    required this.fileType,
  });

  @override
  List<Object?> get props => [courseId, title, description, fileUrl, fileType];
}
