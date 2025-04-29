import 'package:equatable/equatable.dart';

abstract class StudentDashboardEvent extends Equatable {
  const StudentDashboardEvent();

  @override
  List<Object?> get props => [];
}

class LoadEnrolledCoursesEvent extends StudentDashboardEvent {}

class LoadAvailableCoursesEvent extends StudentDashboardEvent {
  final String? searchQuery;
  final String? statusFilter;
  final int page;

  const LoadAvailableCoursesEvent({
    this.searchQuery,
    this.statusFilter,
    this.page = 1,
  });

  @override
  List<Object?> get props => [searchQuery, statusFilter, page];
}

class LoadAssignmentsEvent extends StudentDashboardEvent {}

class LoadQuizzesEvent extends StudentDashboardEvent {}

class LoadCourseDetailsEvent extends StudentDashboardEvent {
  final int courseId;

  const LoadCourseDetailsEvent(this.courseId);

  @override
  List<Object?> get props => [courseId];
}

class EnrollInCourseEvent extends StudentDashboardEvent {
  final int courseId;
  final String paymentIntentId;

  const EnrollInCourseEvent({
    required this.courseId,
    required this.paymentIntentId,
  });

  @override
  List<Object?> get props => [courseId, paymentIntentId];
}

class JoinWaitlistEvent extends StudentDashboardEvent {
  final int courseId;

  const JoinWaitlistEvent(this.courseId);

  @override
  List<Object?> get props => [courseId];
}
