import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:mentora/core/constants/app_constants.dart';
import 'package:mentora/domain/usecases/course/get_courses_usecase.dart';
import 'package:mentora/presentation/student/bloc/student_dashboard_event.dart';
import 'package:mentora/presentation/student/bloc/student_dashboard_state.dart';

@injectable
class StudentDashboardBloc
    extends Bloc<StudentDashboardEvent, StudentDashboardState> {
  final GetStudentCoursesUseCase _getStudentCoursesUseCase;
  final GetCoursesUseCase _getCoursesUseCase;
  final GetCourseByIdUseCase _getCourseByIdUseCase;
  final EnrollCourseUseCase _enrollCourseUseCase;
  final WaitlistCourseUseCase _waitlistCourseUseCase;

  StudentDashboardBloc(
    this._getStudentCoursesUseCase,
    this._getCoursesUseCase,
    this._getCourseByIdUseCase,
    this._enrollCourseUseCase,
    this._waitlistCourseUseCase,
  ) : super(StudentDashboardInitial()) {
    on<LoadEnrolledCoursesEvent>(_onLoadEnrolledCourses);
    on<LoadAvailableCoursesEvent>(_onLoadAvailableCourses);
    on<LoadCourseDetailsEvent>(_onLoadCourseDetails);
    on<EnrollInCourseEvent>(_onEnrollInCourse);
    on<JoinWaitlistEvent>(_onJoinWaitlist);
  }

  Future<void> _onLoadEnrolledCourses(
      LoadEnrolledCoursesEvent event, Emitter<StudentDashboardState> emit) async {
    emit(StudentDashboardLoading());
    try {
      final courses = await _getStudentCoursesUseCase.execute();
      emit(EnrolledCoursesLoaded(courses));
    } catch (e) {
      emit(StudentDashboardError(e.toString()));
    }
  }

  Future<void> _onLoadAvailableCourses(
      LoadAvailableCoursesEvent event, Emitter<StudentDashboardState> emit) async {
    emit(StudentDashboardLoading());
    try {
      final courses = await _getCoursesUseCase.execute(
        page: event.page,
        limit: AppConstants.defaultPageSize,
        status: event.statusFilter,
        search: event.searchQuery,
      );
      
      // Assume we have more pages if we received the maximum number of items
      final hasMorePages = courses.length >= AppConstants.defaultPageSize;
      
      emit(AvailableCoursesLoaded(
        courses: courses,
        hasMorePages: hasMorePages,
        currentPage: event.page,
        searchQuery: event.searchQuery,
        statusFilter: event.statusFilter,
      ));
    } catch (e) {
      emit(StudentDashboardError(e.toString()));
    }
  }

  Future<void> _onLoadCourseDetails(
      LoadCourseDetailsEvent event, Emitter<StudentDashboardState> emit) async {
    emit(StudentDashboardLoading());
    try {
      final course = await _getCourseByIdUseCase.execute(event.courseId);
      emit(CourseDetailsLoaded(course));
    } catch (e) {
      emit(StudentDashboardError(e.toString()));
    }
  }

  Future<void> _onEnrollInCourse(
      EnrollInCourseEvent event, Emitter<StudentDashboardState> emit) async {
    emit(StudentDashboardLoading());
    try {
      await _enrollCourseUseCase.execute(
        event.courseId,
        paymentIntentId: event.paymentIntentId,
      );
      emit(EnrollmentSuccess(
        courseId: event.courseId,
        message: AppConstants.successEnrollment,
      ));
    } catch (e) {
      emit(StudentDashboardError(e.toString()));
    }
  }

  Future<void> _onJoinWaitlist(
      JoinWaitlistEvent event, Emitter<StudentDashboardState> emit) async {
    emit(StudentDashboardLoading());
    try {
      await _waitlistCourseUseCase.execute(event.courseId);
      emit(WaitlistSuccess(
        courseId: event.courseId,
        message: AppConstants.successWaitlist,
      ));
    } catch (e) {
      emit(StudentDashboardError(e.toString()));
    }
  }
}
