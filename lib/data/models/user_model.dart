import 'package:equatable/equatable.dart';
import '../../core/constants.dart';

class UserModel extends Equatable {
  final int id;
  final String name;
  final String email;
  final UserRole role;
  final String? profileImage;
  final String? phoneNumber;
  final String? token;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.profileImage,
    this.phoneNumber,
    this.token,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    UserRole mapRole(String role) {
      switch (role) {
        case 'admin':
          return UserRole.admin;
        case 'teacher':
          return UserRole.teacher;
        case 'student':
          return UserRole.student;
        default:
          return UserRole.student;
      }
    }

    return UserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      role: mapRole(json['role']),
      profileImage: json['profile_image'],
      phoneNumber: json['phone_number'],
      token: json['token'],
    );
  }

  Map<String, dynamic> toJson() {
    String mapRoleToString(UserRole role) {
      switch (role) {
        case UserRole.admin:
          return 'admin';
        case UserRole.teacher:
          return 'teacher';
        case UserRole.student:
          return 'student';
      }
    }

    return {
      'id': id,
      'name': name,
      'email': email,
      'role': mapRoleToString(role),
      'profile_image': profileImage,
      'phone_number': phoneNumber,
      'token': token,
    };
  }

  UserModel copyWith({
    int? id,
    String? name,
    String? email,
    UserRole? role,
    String? profileImage,
    String? phoneNumber,
    String? token,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      profileImage: profileImage ?? this.profileImage,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      token: token ?? this.token,
    );
  }

  @override
  List<Object?> get props => [id, name, email, role, profileImage, phoneNumber, token];
}
