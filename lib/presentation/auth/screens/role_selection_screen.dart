import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mentora/app_router.dart';
import 'package:mentora/core/constants/app_constants.dart';
import 'package:mentora/core/themes/app_theme.dart';
import 'package:mentora/core/widgets/app_button.dart';
import 'package:mentora/presentation/auth/bloc/auth_bloc.dart';
import 'package:mentora/presentation/auth/bloc/auth_event.dart';
import 'package:mentora/presentation/auth/bloc/auth_state.dart';

@RoutePage()
class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({Key? key}) : super(key: key);

  @override
  _RoleSelectionScreenState createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  String _selectedRole = AppConstants.roleStudent;
  
  void _navigateBasedOnRole() {
    switch (_selectedRole) {
      case AppConstants.roleAdmin:
        context.router.replace(const AdminDashboardRoute());
        break;
      case AppConstants.roleTeacher:
        context.router.replace(const TeacherDashboardRoute());
        break;
      case AppConstants.roleStudent:
        context.router.replace(const StudentDashboardRoute());
        break;
      default:
        context.router.replace(const LoginRoute());
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Your Role'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthBloc>().add(LogoutEvent());
              context.router.replace(const LoginRoute());
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Welcome to Mentora!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Please select your role to continue:',
                style: TextStyle(
                  fontSize: 16,
                  color: AppTheme.textSecondaryColor,
                ),
              ),
              const SizedBox(height: 24),
              
              // Role selection cards
              Expanded(
                child: ListView(
                  children: [
                    _buildRoleCard(
                      title: 'Student',
                      description: 'Browse and enroll in courses, submit assignments, and track your progress.',
                      iconData: Icons.school,
                      color: AppTheme.studentColor,
                      role: AppConstants.roleStudent,
                    ),
                    const SizedBox(height: 16),
                    _buildRoleCard(
                      title: 'Teacher',
                      description: 'Create course materials, manage assignments, and monitor student progress.',
                      iconData: Icons.cast_for_education,
                      color: AppTheme.teacherColor,
                      role: AppConstants.roleTeacher,
                    ),
                    const SizedBox(height: 16),
                    _buildRoleCard(
                      title: 'Admin',
                      description: 'Manage courses, users, and enrollment settings for the platform.',
                      iconData: Icons.admin_panel_settings,
                      color: AppTheme.adminColor,
                      role: AppConstants.roleAdmin,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Continue button
              AppButton(
                text: 'Continue as ${_getRoleDisplayName(_selectedRole)}',
                onPressed: _navigateBasedOnRole,
                isFullWidth: true,
                size: AppButtonSize.large,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard({
    required String title,
    required String description,
    required IconData iconData,
    required Color color,
    required String role,
  }) {
    final isSelected = _selectedRole == role;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedRole = role;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : AppTheme.dividerColor,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                iconData,
                color: color,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? color : AppTheme.textPrimaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondaryColor,
                    ),
                  ),
                ],
              ),
            ),
            Radio<String>(
              value: role,
              groupValue: _selectedRole,
              activeColor: color,
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedRole = value;
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }
  
  String _getRoleDisplayName(String role) {
    switch (role) {
      case AppConstants.roleAdmin:
        return 'Admin';
      case AppConstants.roleTeacher:
        return 'Teacher';
      case AppConstants.roleStudent:
        return 'Student';
      default:
        return role;
    }
  }
}
