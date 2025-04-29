import 'package:injectable/injectable.dart';
import 'package:mentora/domain/entities/course.dart';
import 'package:mentora/domain/repositories/course_repository.dart';

@injectable
class GetCoursesUseCase {
  final CourseRepository _repository;

  GetCoursesUseCase(this._repository);

  Future<List<Course>> execute({
    int page = 1,
    int limit = 10,
    String? status,
    String? search,
  }) {
    return _repository.getCourses(
      page: page,
      limit: limit,
      status: status,
      search: search,
    );
  }
}

@injectable
class GetCourseByIdUseCase {
  final CourseRepository _repository;

  GetCourseByIdUseCase(this._repository);

  Future<Course> execute(int courseId) {
    return _repository.getCourseById(courseId);
  }
}

@injectable
class CreateCourseUseCase {
  final CourseRepository _repository;

  CreateCourseUseCase(this._repository);

  Future<Course> execute(Course course) {
    return _repository.createCourse(course);
  }
}

@injectable
class UpdateCourseUseCase {
  final CourseRepository _repository;

  UpdateCourseUseCase(this._repository);

  Future<Course> execute(Course course) {
    return _repository.updateCourse(course);
  }
}

@injectable
class DeleteCourseUseCase {
  final CourseRepository _repository;

  DeleteCourseUseCase(this._repository);

  Future<bool> execute(int courseId) {
    return _repository.deleteCourse(courseId);
  }
}

@injectable
class AssignInstructorUseCase {
  final CourseRepository _repository;

  AssignInstructorUseCase(this._repository);

  Future<bool> execute(int courseId, int instructorId) {
    return _repository.assignInstructor(courseId, instructorId);
  }
}

@injectable
class EnrollCourseUseCase {
  final CourseRepository _repository;

  EnrollCourseUseCase(this._repository);

  Future<bool> execute(int courseId, {required String paymentIntentId}) {
    return _repository.enrollCourse(courseId, paymentIntentId: paymentIntentId);
  }
}

@injectable
class WaitlistCourseUseCase {
  final CourseRepository _repository;

  WaitlistCourseUseCase(this._repository);

  Future<bool> execute(int courseId) {
    return _repository.waitlistCourse(courseId);
  }
}

@injectable
class GetStudentCoursesUseCase {
  final CourseRepository _repository;

  GetStudentCoursesUseCase(this._repository);

  Future<List<Course>> execute() {
    return _repository.getStudentCourses();
  }
}

@injectable
class GetTeacherCoursesUseCase {
  final CourseRepository _repository;

  GetTeacherCoursesUseCase(this._repository);

  Future<List<Course>> execute() {
    return _repository.getTeacherCourses();
  }
}
