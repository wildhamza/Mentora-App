import 'package:equatable/equatable.dart';
import 'package:mentora/domain/entities/course.dart';

abstract class TeacherDashboardState extends Equatable {
  const TeacherDashboardState();

  @override
  List<Object?> get props => [];
}

class TeacherDashboardInitial extends TeacherDashboardState {}

class TeacherDashboardLoading extends TeacherDashboardState {}

class TeacherCoursesLoaded extends TeacherDashboardState {
  final List<Course> courses;

  const TeacherCoursesLoaded(this.courses);

  @override
  List<Object?> get props => [courses];
}

class CourseDetailsLoaded extends TeacherDashboardState {
  final Course course;

  const CourseDetailsLoaded(this.course);

  @override
  List<Object?> get props => [course];
}

class AssignmentCreated extends TeacherDashboardState {
  final String message;

  const AssignmentCreated(this.message);

  @override
  List<Object?> get props => [message];
}

class AttendanceMarked extends TeacherDashboardState {
  final String message;

  const AttendanceMarked(this.message);

  @override
  List<Object?> get props => [message];
}

class SessionScheduled extends TeacherDashboardState {
  final String message;

  const SessionScheduled(this.message);

  @override
  List<Object?> get props => [message];
}

class MaterialUploaded extends TeacherDashboardState {
  final String message;

  const MaterialUploaded(this.message);

  @override
  List<Object?> get props => [message];
}

class TeacherDashboardError extends TeacherDashboardState {
  final String message;

  const TeacherDashboardError(this.message);

  @override
  List<Object?> get props => [message];
}
