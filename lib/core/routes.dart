import 'package:flutter/material.dart';
import '../presentation/splash/splash_screen.dart';
import '../presentation/auth/login_screen.dart';
import '../presentation/auth/signup_screen.dart';
import '../presentation/auth/role_selection_screen.dart';
import '../presentation/admin/screens/admin_dashboard.dart';
import '../presentation/admin/screens/course_list_screen.dart';
import '../presentation/admin/screens/add_edit_course_screen.dart';
import '../presentation/admin/screens/assign_instructor_screen.dart';
import '../presentation/teacher/screens/teacher_dashboard.dart';
import '../presentation/teacher/screens/assignment_management_screen.dart';
import '../presentation/teacher/screens/attendance_screen.dart';
import '../presentation/teacher/screens/schedule_session_screen.dart';
import '../presentation/student/screens/student_dashboard.dart';
import '../presentation/student/screens/course_browse_screen.dart';

class Routes {
  static const String splash = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String roleSelection = '/role-selection';

  // Admin routes
  static const String adminDashboard = '/admin/dashboard';
  static const String courseList = '/admin/courses';
  static const String addEditCourse = '/admin/courses/edit';
  static const String assignInstructor = '/admin/courses/assign-instructor';

  // Teacher routes
  static const String teacherDashboard = '/teacher/dashboard';
  static const String assignmentManagement = '/teacher/assignments';
  static const String attendance = '/teacher/attendance';
  static const String scheduleSession = '/teacher/schedule-session';

  // Student routes
  static const String studentDashboard = '/student/dashboard';
  static const String courseBrowse = '/student/courses';
  static const String assignmentSubmission = '/student/assignments';
  static const String quiz = '/student/quiz';
  static const String materials = '/student/materials';
  static const String payment = '/student/payment';
}

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case Routes.login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case Routes.signup:
        return MaterialPageRoute(builder: (_) => const SignupScreen());
      case Routes.roleSelection:
        return MaterialPageRoute(builder: (_) => const RoleSelectionScreen());

      // Admin routes
      case Routes.adminDashboard:
        return MaterialPageRoute(builder: (_) => const AdminDashboard());
      case Routes.courseList:
        return MaterialPageRoute(builder: (_) => const CourseListScreen());
      case Routes.addEditCourse:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => AddEditCourseScreen(courseId: args?['courseId']),
        );
      case Routes.assignInstructor:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => AssignInstructorScreen(courseId: args['courseId']),
        );

      // Teacher routes
      case Routes.teacherDashboard:
        return MaterialPageRoute(builder: (_) => const TeacherDashboard());
      case Routes.assignmentManagement:
        return MaterialPageRoute(
          builder: (_) => const AssignmentManagementScreen(),
        );
      case Routes.attendance:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => AttendanceScreen(courseId: args['courseId']),
        );
      case Routes.scheduleSession:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => ScheduleSessionScreen(courseId: args['courseId']),
        );

      // Student routes
      case Routes.studentDashboard:
        return MaterialPageRoute(builder: (_) => const StudentDashboard());
      case Routes.courseBrowse:
        return MaterialPageRoute(builder: (_) => const CourseBrowseScreen());
      // case Routes.assignmentSubmission:
      //   final args = settings.arguments as Map<String, dynamic>;
      //   return MaterialPageRoute(
      //     builder:
      //         (_) => AssignmentSubmissionScreen(
      //           assignmentId: args['assignmentId'],
      //         ),
      //   );
      // case Routes.quiz:
      //   final args = settings.arguments as Map<String, dynamic>;
      //   return MaterialPageRoute(
      //     builder: (_) => QuizScreen(quizId: args['quizId']),
      //   );
      // case Routes.materials:
      //   final args = settings.arguments as Map<String, dynamic>;
      //   return MaterialPageRoute(
      //     builder: (_) => MaterialsScreen(courseId: args['courseId']),
      //   );
      // case Routes.payment:
      //   final args = settings.arguments as Map<String, dynamic>;
      //   return MaterialPageRoute(
      //     builder: (_) => PaymentScreen(courseId: args['courseId']),
      //   );

      default:
        return MaterialPageRoute(
          builder:
              (_) => Scaffold(
                body: Center(
                  child: Text('No route defined for ${settings.name}'),
                ),
              ),
        );
    }
  }
}
