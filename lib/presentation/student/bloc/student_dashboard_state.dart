import 'package:equatable/equatable.dart';
import 'package:mentora/domain/entities/course.dart';

abstract class StudentDashboardState extends Equatable {
  const StudentDashboardState();

  @override
  List<Object?> get props => [];
}

class StudentDashboardInitial extends StudentDashboardState {}

class StudentDashboardLoading extends StudentDashboardState {}

class EnrolledCoursesLoaded extends StudentDashboardState {
  final List<Course> courses;

  const EnrolledCoursesLoaded(this.courses);

  @override
  List<Object?> get props => [courses];
}

class AvailableCoursesLoaded extends StudentDashboardState {
  final List<Course> courses;
  final bool hasMorePages;
  final int currentPage;
  final String? searchQuery;
  final String? statusFilter;

  const AvailableCoursesLoaded({
    required this.courses,
    this.hasMorePages = false,
    this.currentPage = 1,
    this.searchQuery,
    this.statusFilter,
  });

  @override
  List<Object?> get props => [
        courses,
        hasMorePages,
        currentPage,
        searchQuery,
        statusFilter,
      ];
}

class CourseDetailsLoaded extends StudentDashboardState {
  final Course course;

  const CourseDetailsLoaded(this.course);

  @override
  List<Object?> get props => [course];
}

class EnrollmentSuccess extends StudentDashboardState {
  final int courseId;
  final String message;

  const EnrollmentSuccess({
    required this.courseId,
    required this.message,
  });

  @override
  List<Object?> get props => [courseId, message];
}

class WaitlistSuccess extends StudentDashboardState {
  final int courseId;
  final String message;

  const WaitlistSuccess({
    required this.courseId,
    required this.message,
  });

  @override
  List<Object?> get props => [courseId, message];
}

class StudentDashboardError extends StudentDashboardState {
  final String message;

  const StudentDashboardError(this.message);

  @override
  List<Object?> get props => [message];
}
