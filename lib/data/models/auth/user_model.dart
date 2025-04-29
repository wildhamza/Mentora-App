import 'package:equatable/equatable.dart';
import 'package:mentora/domain/entities/user.dart';

class UserModel extends Equatable {
  final int id;
  final String name;
  final String email;
  final String role;
  final String? profileImage;
  final String? phoneNumber;
  final String? bio;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.profileImage,
    this.phoneNumber,
    this.bio,
    required this.createdAt,
    required this.updatedAt,
  });

  // Convert API response to UserModel
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      role: json['role'],
      profileImage: json['profile_image'],
      phoneNumber: json['phone_number'],
      bio: json['bio'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  // Convert UserModel to JSON for API requests
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'profile_image': profileImage,
      'phone_number': phoneNumber,
      'bio': bio,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Convert UserModel to User entity
  User toEntity() {
    return User(
      id: id,
      name: name,
      email: email,
      role: role,
      profileImage: profileImage,
      phoneNumber: phoneNumber,
      bio: bio,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  // Create a copy of UserModel with some fields changed
  UserModel copyWith({
    int? id,
    String? name,
    String? email,
    String? role,
    String? profileImage,
    String? phoneNumber,
    String? bio,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      profileImage: profileImage ?? this.profileImage,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      bio: bio ?? this.bio,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        role,
        profileImage,
        phoneNumber,
        bio,
        createdAt,
        updatedAt,
      ];
}
