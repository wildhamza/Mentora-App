class AppConstants {
  // App details
  static const String appName = 'Mentora';
  static const String appVersion = '1.0.0';
  
  // User roles
  static const String roleAdmin = 'admin';
  static const String roleTeacher = 'teacher';
  static const String roleStudent = 'student';
  
  // SharedPreferences keys
  static const String prefKeyToken = 'auth_token';
  static const String prefKeyUser = 'user_data';
  static const String prefKeyRole = 'user_role';
  
  // Course status
  static const String courseStatusActive = 'active';
  static const String courseStatusClosed = 'closed';
  static const String courseStatusUpcoming = 'upcoming';
  
  // Assignment status
  static const String assignmentStatusDue = 'due';
  static const String assignmentStatusSubmitted = 'submitted';
  static const String assignmentStatusGraded = 'graded';
  static const String assignmentStatusLate = 'late';
  
  // Payment status
  static const String paymentStatusPending = 'pending';
  static const String paymentStatusCompleted = 'completed';
  static const String paymentStatusFailed = 'failed';
  
  // Enrollment status
  static const String enrollmentStatusActive = 'active';
  static const String enrollmentStatusWaitlisted = 'waitlisted';
  
  // Pagination
  static const int defaultPageSize = 10;
  
  // Timeouts
  static const int connectionTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000; // 30 seconds
  
  // Error messages
  static const String errorGeneric = 'Something went wrong. Please try again later.';
  static const String errorConnection = 'Connection error. Please check your internet connection.';
  static const String errorTimeout = 'Request timed out. Please try again.';
  static const String errorNotFound = 'The requested resource was not found.';
  static const String errorServer = 'Server error. Please try again later.';
  static const String errorUnauthorized = 'You are not authorized to perform this action.';
  static const String errorInvalidCredentials = 'Invalid email or password.';
  
  // Success messages
  static const String successLogin = 'Login successful!';
  static const String successSignup = 'Account created successfully!';
  static const String successCourseCreated = 'Course created successfully!';
  static const String successCourseUpdated = 'Course updated successfully!';
  static const String successEnrollment = 'Successfully enrolled in the course!';
  static const String successWaitlist = 'You have been added to the waitlist!';
  static const String successAssignmentSubmit = 'Assignment submitted successfully!';
  static const String successQuizSubmit = 'Quiz submitted successfully!';
  static const String successPayment = 'Payment successful!';
}
