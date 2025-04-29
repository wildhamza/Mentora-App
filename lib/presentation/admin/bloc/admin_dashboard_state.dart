import 'package:equatable/equatable.dart';
import 'package:mentora/domain/entities/course.dart';

abstract class AdminDashboardState extends Equatable {
  const AdminDashboardState();

  @override
  List<Object?> get props => [];
}

class AdminDashboardInitial extends AdminDashboardState {}

class AdminDashboardLoading extends AdminDashboardState {}

class DashboardDataLoaded extends AdminDashboardState {
  final List<Course> courses;
  final int totalStudents;
  final int totalTeachers;
  final int totalEnrollments;

  const DashboardDataLoaded({
    required this.courses,
    required this.totalStudents,
    required this.totalTeachers,
    required this.totalEnrollments,
  });

  @override
  List<Object?> get props => [courses, totalStudents, totalTeachers, totalEnrollments];
}

class CoursesLoaded extends AdminDashboardState {
  final List<Course> courses;
  final bool hasMorePages;
  final int currentPage;
  final String? searchQuery;
  final String? statusFilter;

  const CoursesLoaded({
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

class CourseDetailsLoaded extends AdminDashboardState {
  final Course course;

  const CourseDetailsLoaded(this.course);

  @override
  List<Object?> get props => [course];
}

class CourseCreated extends AdminDashboardState {
  final Course course;
  final String message;

  const CourseCreated({
    required this.course,
    required this.message,
  });

  @override
  List<Object?> get props => [course, message];
}

class CourseUpdated extends AdminDashboardState {
  final Course course;
  final String message;

  const CourseUpdated({
    required this.course,
    required this.message,
  });

  @override
  List<Object?> get props => [course, message];
}

class CourseDeleted extends AdminDashboardState {
  final int courseId;
  final String message;

  const CourseDeleted({
    required this.courseId,
    required this.message,
  });

  @override
  List<Object?> get props => [courseId, message];
}

class InstructorAssigned extends AdminDashboardState {
  final int courseId;
  final int instructorId;
  final String message;

  const InstructorAssigned({
    required this.courseId,
    required this.instructorId,
    required this.message,
  });

  @override
  List<Object?> get props => [courseId, instructorId, message];
}

class AdminDashboardError extends AdminDashboardState {
  final String message;

  const AdminDashboardError(this.message);

  @override
  List<Object?> get props => [message];
}
