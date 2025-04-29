import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';

import '../../presentation/splash/splash_screen.dart';
import '../../presentation/auth/screens/login_screen.dart';
import '../../presentation/auth/screens/signup_screen.dart';
import '../../presentation/auth/screens/role_selection_screen.dart';
import '../../presentation/student/screens/student_dashboard_screen.dart';
import '../../presentation/student/screens/course_browse_screen.dart';
import '../../presentation/student/screens/course_detail_screen.dart';
import '../../presentation/student/screens/payment_screen.dart';
import '../../presentation/student/screens/assignment_list_screen.dart';
import '../../presentation/student/screens/assignment_detail_screen.dart';
import '../../presentation/student/screens/quiz_list_screen.dart';
import '../../presentation/student/screens/quiz_attempt_screen.dart';
import '../../presentation/student/screens/live_session_screen.dart';
import '../../presentation/student/screens/materials_screen.dart';
import '../../presentation/teacher/screens/teacher_dashboard_screen.dart';
import '../../presentation/teacher/screens/assignment_creation_screen.dart';
import '../../presentation/teacher/screens/quiz_creation_screen.dart';
import '../../presentation/teacher/screens/attendance_screen.dart';
import '../../presentation/teacher/screens/schedule_session_screen.dart';
import '../../presentation/teacher/screens/upload_material_screen.dart';
import '../../presentation/admin/screens/admin_dashboard_screen.dart';
import '../../presentation/admin/screens/course_list_screen.dart';
import '../../presentation/admin/screens/course_form_screen.dart';
import '../../presentation/admin/screens/instructor_assignment_screen.dart';
import '../../presentation/admin/screens/enrollment_window_screen.dart';

@MaterialAutoRouter(
  replaceInRouteName: 'Screen,Route',
  routes: <AutoRoute>[
    AutoRoute(page: SplashScreen, initial: true),
    AutoRoute(page: LoginScreen),
    AutoRoute(page: SignupScreen),
    AutoRoute(page: RoleSelectionScreen),
    
    // Student routes
    AutoRoute(
      page: StudentDashboardScreen,
      children: [
        AutoRoute(page: CourseBrowseScreen, initial: true),
        AutoRoute(page: AssignmentListScreen),
        AutoRoute(page: QuizListScreen),
        AutoRoute(page: MaterialsScreen),
      ],
    ),
    AutoRoute(page: CourseDetailScreen),
    AutoRoute(page: PaymentScreen),
    AutoRoute(page: AssignmentDetailScreen),
    AutoRoute(page: QuizAttemptScreen),
    AutoRoute(page: LiveSessionScreen),
    
    // Teacher routes
    AutoRoute(
      page: TeacherDashboardScreen,
      children: [
        AutoRoute(page: AttendanceScreen, initial: true),
        AutoRoute(page: AssignmentCreationScreen),
        AutoRoute(page: QuizCreationScreen),
        AutoRoute(page: ScheduleSessionScreen),
        AutoRoute(page: UploadMaterialScreen),
      ],
    ),
    
    // Admin routes
    AutoRoute(
      page: AdminDashboardScreen,
      children: [
        AutoRoute(page: CourseListScreen, initial: true),
        AutoRoute(page: InstructorAssignmentScreen),
        AutoRoute(page: EnrollmentWindowScreen),
      ],
    ),
    AutoRoute(page: CourseFormScreen),
  ],
)
class $AppRouter {}

@singleton
class AppRouter extends _$AppRouter {}
