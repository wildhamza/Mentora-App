import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:mentora/domain/usecases/course/get_courses_usecase.dart';
import 'package:mentora/presentation/teacher/bloc/teacher_dashboard_event.dart';
import 'package:mentora/presentation/teacher/bloc/teacher_dashboard_state.dart';

@injectable
class TeacherDashboardBloc
    extends Bloc<TeacherDashboardEvent, TeacherDashboardState> {
  final GetTeacherCoursesUseCase _getTeacherCoursesUseCase;
  final GetCourseByIdUseCase _getCourseByIdUseCase;

  TeacherDashboardBloc(
    this._getTeacherCoursesUseCase,
    this._getCourseByIdUseCase,
  ) : super(TeacherDashboardInitial()) {
    on<LoadTeacherCoursesEvent>(_onLoadTeacherCourses);
    on<LoadCourseDetailsEvent>(_onLoadCourseDetails);
    on<CreateAssignmentEvent>(_onCreateAssignment);
    on<MarkAttendanceEvent>(_onMarkAttendance);
    on<ScheduleSessionEvent>(_onScheduleSession);
    on<UploadMaterialEvent>(_onUploadMaterial);
  }

  Future<void> _onLoadTeacherCourses(
      LoadTeacherCoursesEvent event, Emitter<TeacherDashboardState> emit) async {
    emit(TeacherDashboardLoading());
    try {
      final courses = await _getTeacherCoursesUseCase.execute();
      emit(TeacherCoursesLoaded(courses));
    } catch (e) {
      emit(TeacherDashboardError(e.toString()));
    }
  }

  Future<void> _onLoadCourseDetails(
      LoadCourseDetailsEvent event, Emitter<TeacherDashboardState> emit) async {
    emit(TeacherDashboardLoading());
    try {
      final course = await _getCourseByIdUseCase.execute(event.courseId);
      emit(CourseDetailsLoaded(course));
    } catch (e) {
      emit(TeacherDashboardError(e.toString()));
    }
  }

  Future<void> _onCreateAssignment(
      CreateAssignmentEvent event, Emitter<TeacherDashboardState> emit) async {
    emit(TeacherDashboardLoading());
    try {
      // TODO: Implement assignment creation with proper UseCase
      await Future.delayed(const Duration(seconds: 1)); // Mock API call
      emit(const AssignmentCreated('Assignment created successfully'));
    } catch (e) {
      emit(TeacherDashboardError(e.toString()));
    }
  }

  Future<void> _onMarkAttendance(
      MarkAttendanceEvent event, Emitter<TeacherDashboardState> emit) async {
    emit(TeacherDashboardLoading());
    try {
      // TODO: Implement attendance marking with proper UseCase
      await Future.delayed(const Duration(seconds: 1)); // Mock API call
      emit(const AttendanceMarked('Attendance marked successfully'));
    } catch (e) {
      emit(TeacherDashboardError(e.toString()));
    }
  }

  Future<void> _onScheduleSession(
      ScheduleSessionEvent event, Emitter<TeacherDashboardState> emit) async {
    emit(TeacherDashboardLoading());
    try {
      // TODO: Implement session scheduling with proper UseCase
      await Future.delayed(const Duration(seconds: 1)); // Mock API call
      emit(const SessionScheduled('Session scheduled successfully'));
    } catch (e) {
      emit(TeacherDashboardError(e.toString()));
    }
  }

  Future<void> _onUploadMaterial(
      UploadMaterialEvent event, Emitter<TeacherDashboardState> emit) async {
    emit(TeacherDashboardLoading());
    try {
      // TODO: Implement material upload with proper UseCase
      await Future.delayed(const Duration(seconds: 1)); // Mock API call
      emit(const MaterialUploaded('Material uploaded successfully'));
    } catch (e) {
      emit(TeacherDashboardError(e.toString()));
    }
  }
}
