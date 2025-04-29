class ApiConstants {
  // Base URLs
  static const String baseUrl = 'https://api.mentora.com/api/v1';
  
  // Auth endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh';
  
  // Course endpoints
  static const String courses = '/courses';
  static const String courseDetail = '/courses/'; // + courseId
  static const String enrollCourse = '/courses/enroll/'; // + courseId
  static const String waitlistCourse = '/courses/waitlist/'; // + courseId
  
  // Admin endpoints
  static const String adminCourses = '/admin/courses';
  static const String adminCourseDetail = '/admin/courses/'; // + courseId
  static const String adminAssignInstructor = '/admin/courses/assign-instructor';
  
  // Teacher endpoints
  static const String teacherCourses = '/teacher/courses';
  static const String teacherCourseDetail = '/teacher/courses/'; // + courseId
  static const String teacherCreateAssignment = '/teacher/assignments';
  static const String teacherAttendance = '/teacher/attendance';
  static const String teacherScheduleSession = '/teacher/sessions';
  
  // Student endpoints
  static const String studentCourses = '/student/courses';
  static const String studentCourseDetail = '/student/courses/'; // + courseId
  static const String studentAssignments = '/student/assignments';
  static const String studentQuizzes = '/student/quizzes';
  static const String studentSubmitAssignment = '/student/assignments/submit/'; // + assignmentId
  static const String studentAttemptQuiz = '/student/quizzes/attempt/'; // + quizId
  
  // Payment endpoints
  static const String createPaymentIntent = '/payments/create-intent';
  static const String confirmPayment = '/payments/confirm';
  
  // Material endpoints
  static const String courseMaterials = '/materials/course/'; // + courseId
  
  // Session endpoints
  static const String liveSessions = '/sessions';
  static const String joinSession = '/sessions/join/'; // + sessionId
  
  // Notification endpoints
  static const String notifications = '/notifications';
  static const String markNotificationRead = '/notifications/read/'; // + notificationId
  
  // Headers
  static const String contentType = 'Content-Type';
  static const String applicationJson = 'application/json';
  static const String authorization = 'Authorization';
  static const String bearer = 'Bearer ';
  
  // Error codes
  static const int badRequest = 400;
  static const int unauthorized = 401;
  static const int forbidden = 403;
  static const int notFound = 404;
  static const int methodNotAllowed = 405;
  static const int internalServerError = 500;
}
