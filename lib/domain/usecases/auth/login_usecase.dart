import 'package:injectable/injectable.dart';
import 'package:mentora/domain/entities/user.dart';
import 'package:mentora/domain/repositories/auth_repository.dart';

@injectable
class LoginUseCase {
  final AuthRepository _repository;

  LoginUseCase(this._repository);

  Future<User> execute(String email, String password) {
    return _repository.login(email, password);
  }
}

@injectable
class RegisterUseCase {
  final AuthRepository _repository;

  RegisterUseCase(this._repository);

  Future<User> execute(String name, String email, String password, String role) {
    return _repository.register(name, email, password, role);
  }
}

@injectable
class LogoutUseCase {
  final AuthRepository _repository;

  LogoutUseCase(this._repository);

  Future<void> execute() {
    return _repository.logout();
  }
}

@injectable
class GetCurrentUserUseCase {
  final AuthRepository _repository;

  GetCurrentUserUseCase(this._repository);

  Future<User?> execute() {
    return _repository.getCurrentUser();
  }
}

@injectable
class IsLoggedInUseCase {
  final AuthRepository _repository;

  IsLoggedInUseCase(this._repository);

  Future<bool> execute() {
    return _repository.isLoggedIn();
  }
}

@injectable
class GetUserRoleUseCase {
  final AuthRepository _repository;

  GetUserRoleUseCase(this._repository);

  Future<String?> execute() {
    return _repository.getUserRole();
  }
}
