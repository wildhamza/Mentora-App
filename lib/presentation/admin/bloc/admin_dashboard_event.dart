import 'package:equatable/equatable.dart';
import 'package:mentora/domain/entities/course.dart';

abstract class AdminDashboardEvent extends Equatable {
  const AdminDashboardEvent();

  @override
  List<Object?> get props => [];
}

class LoadDashboardDataEvent extends AdminDashboardEvent {
  const LoadDashboardDataEvent();
}

class LoadCoursesEvent extends AdminDashboardEvent {
  final String? searchQuery;
  final String? statusFilter;
  final int page;

  const LoadCoursesEvent({
    this.searchQuery,
    this.statusFilter,
    this.page = 1,
  });

  @override
  List<Object?> get props => [searchQuery, statusFilter, page];
}

class LoadCourseDetailsEvent extends AdminDashboardEvent {
  final int courseId;

  const LoadCourseDetailsEvent(this.courseId);

  @override
  List<Object?> get props => [courseId];
}

class CreateCourseEvent extends AdminDashboardEvent {
  final Course course;

  const CreateCourseEvent(this.course);

  @override
  List<Object?> get props => [course];
}

class UpdateCourseEvent extends AdminDashboardEvent {
  final Course course;

  const UpdateCourseEvent(this.course);

  @override
  List<Object?> get props => [course];
}

class DeleteCourseEvent extends AdminDashboardEvent {
  final int courseId;

  const DeleteCourseEvent(this.courseId);

  @override
  List<Object?> get props => [courseId];
}

class AssignInstructorEvent extends AdminDashboardEvent {
  final int courseId;
  final int instructorId;

  const AssignInstructorEvent({
    required this.courseId,
    required this.instructorId,
  });

  @override
  List<Object?> get props => [courseId, instructorId];
}
