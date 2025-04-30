class ApiConstants {
  static const String baseUrl = 'https://api.mentora.com/api';
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String courses = '/courses';
  static const String assignments = '/assignments';
  static const String quizzes = '/quizzes';
  static const String attendance = '/attendance';
  static const String materials = '/materials';
  static const String users = '/users';
}

class AssetConstants {
  // Local assets
  static const String logoPath = 'assets/logo.svg';
  
  // Remote images
  static const String splashImage = 'https://images.unsplash.com/photo-1497633762265-9d179a990aa6';
  static const String loginBackground = 'https://images.unsplash.com/photo-1519452575417-564c1401ecc0';
  static const String studentDashboardImage = 'https://images.unsplash.com/photo-1503676260728-1c00da094a0b';
  static const String teacherDashboardImage = 'https://images.unsplash.com/photo-1546410531-bb4caa6b424d';
  static const String adminDashboardImage = 'https://images.unsplash.com/photo-1529390079861-591de354faf5';
  static const String studyImage = 'https://images.unsplash.com/photo-1516979187457-637abb4f9353';
  static const String classroomImage1 = 'https://images.unsplash.com/photo-1522202176988-66273c2fd55f';
  static const String classroomImage2 = 'https://images.unsplash.com/photo-1523240795612-9a054b0db644';
  static const String learningImage = 'https://images.unsplash.com/photo-1517245386807-bb43f82c33c4';
  static const String teamworkImage = 'https://images.unsplash.com/photo-1552664730-d307ca884978';
  static const String courseInterface1 = 'https://images.unsplash.com/photo-1484807352052-23338990c6c6';
  static const String courseInterface2 = 'https://images.unsplash.com/photo-1557804483-ef3ae78eca57';
  static const String onlineClass = 'https://images.unsplash.com/photo-1588196749597-9ff075ee6b5b';
  static const String groupStudy = 'https://images.unsplash.com/photo-1517048676732-d65bc937f952';
}

enum UserRole {
  admin,
  teacher,
  student,
}

class ErrorMessages {
  static const String networkError = 'Network error. Please check your internet connection.';
  static const String serverError = 'Server error. Please try again later.';
  static const String authError = 'Authentication failed. Please check your credentials.';
  static const String unknownError = 'An unexpected error occurred. Please try again.';
  static const String emptyFieldError = 'This field cannot be empty';
  static const String invalidEmailError = 'Please enter a valid email address';
  static const String passwordLengthError = 'Password must be at least 6 characters long';
}
