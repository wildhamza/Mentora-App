import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:mentora/presentation/admin/screens/add_edit_course_screen.dart';
import 'package:mentora/presentation/admin/screens/admin_dashboard_screen.dart';
import 'package:mentora/presentation/admin/screens/assign_instructor_screen.dart';
import 'package:mentora/presentation/admin/screens/course_management_screen.dart';
import 'package:mentora/presentation/auth/screens/login_screen.dart';
import 'package:mentora/presentation/auth/screens/role_selection_screen.dart';
import 'package:mentora/presentation/auth/screens/signup_screen.dart';
import 'package:mentora/presentation/student/screens/assignments_screen.dart';
import 'package:mentora/presentation/student/screens/course_browse_screen.dart';
import 'package:mentora/presentation/student/screens/course_detail_screen.dart';
import 'package:mentora/presentation/student/screens/payment_screen.dart';
import 'package:mentora/presentation/student/screens/quiz_attempt_screen.dart';
import 'package:mentora/presentation/student/screens/student_dashboard_screen.dart';
import 'package:mentora/presentation/teacher/screens/attendance_screen.dart';
import 'package:mentora/presentation/teacher/screens/create_assignment_screen.dart';
import 'package:mentora/presentation/teacher/screens/schedule_session_screen.dart';
import 'package:mentora/presentation/teacher/screens/teacher_dashboard_screen.dart';

@MaterialAutoRouter(
  replaceInRouteName: 'Screen,Route',
  routes: <AutoRoute>[
    // Auth routes
    AutoRoute(path: '/', page: LoginScreen, initial: true),
    AutoRoute(path: '/signup', page: SignupScreen),
    AutoRoute(path: '/role-selection', page: RoleSelectionScreen),
    
    // Student routes
    AutoRoute(path: '/student/dashboard', page: StudentDashboardScreen),
    AutoRoute(path: '/student/courses', page: CourseBrowseScreen),
    AutoRoute(path: '/student/course/:id', page: CourseDetailScreen),
    AutoRoute(path: '/student/payment', page: PaymentScreen),
    AutoRoute(path: '/student/assignments', page: AssignmentsScreen),
    AutoRoute(path: '/student/quiz/:id', page: QuizAttemptScreen),
    
    // Teacher routes
    AutoRoute(path: '/teacher/dashboard', page: TeacherDashboardScreen),
    AutoRoute(path: '/teacher/create-assignment', page: CreateAssignmentScreen),
    AutoRoute(path: '/teacher/attendance', page: AttendanceScreen),
    AutoRoute(path: '/teacher/schedule-session', page: ScheduleSessionScreen),
    
    // Admin routes
    AutoRoute(path: '/admin/dashboard', page: AdminDashboardScreen),
    AutoRoute(path: '/admin/courses', page: CourseManagementScreen),
    AutoRoute(path: '/admin/course/add', page: AddEditCourseScreen),
    AutoRoute(path: '/admin/course/edit/:id', page: AddEditCourseScreen),
    AutoRoute(path: '/admin/assign-instructor', page: AssignInstructorScreen),
  ],
)
class $AppRouter {}
