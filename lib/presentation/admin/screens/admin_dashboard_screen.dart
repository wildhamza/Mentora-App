import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mentora/app_router.dart';
import 'package:mentora/core/themes/app_theme.dart';
import 'package:mentora/core/widgets/loading_indicator.dart';
import 'package:mentora/di/injection.dart';
import 'package:mentora/domain/entities/course.dart';
import 'package:mentora/presentation/admin/bloc/admin_dashboard_bloc.dart';
import 'package:mentora/presentation/admin/bloc/admin_dashboard_event.dart';
import 'package:mentora/presentation/admin/bloc/admin_dashboard_state.dart';
import 'package:mentora/presentation/auth/bloc/auth_bloc.dart';
import 'package:mentora/presentation/auth/bloc/auth_event.dart';
import 'package:mentora/presentation/auth/bloc/auth_state.dart';
import 'package:mentora/presentation/common/widgets/error_widget.dart';

@RoutePage()
class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  _AdminDashboardScreenState createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  late AdminDashboardBloc _dashboardBloc;
  
  @override
  void initState() {
    super.initState();
    _dashboardBloc = getIt<AdminDashboardBloc>();
    _dashboardBloc.add(const LoadDashboardDataEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _dashboardBloc,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Admin Dashboard'),
          backgroundColor: AppTheme.adminColor,
          actions: [
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'logout') {
                  context.read<AuthBloc>().add(LogoutEvent());
                  context.router.replace(const LoginRoute());
                } else if (value == 'profile') {
                  // Navigate to profile page
                }
              },
              itemBuilder: (BuildContext context) {
                return [
                  const PopupMenuItem(
                    value: 'profile',
                    child: Row(
                      children: [
                        Icon(Icons.person, color: AppTheme.textPrimaryColor),
                        SizedBox(width: 8),
                        Text('My Profile'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(Icons.logout, color: AppTheme.textPrimaryColor),
                        SizedBox(width: 8),
                        Text('Logout'),
                      ],
                    ),
                  ),
                ];
              },
            ),
          ],
        ),
        body: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, authState) {
            if (authState is AuthSuccess) {
              return BlocConsumer<AdminDashboardBloc, AdminDashboardState>(
                listener: (context, state) {
                  if (state is AdminDashboardError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: AppTheme.errorColor,
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  if (state is AdminDashboardLoading) {
                    return const LoadingIndicator(
                      message: 'Loading dashboard data...',
                    );
                  } else if (state is DashboardDataLoaded) {
                    return _buildDashboardContent(
                      context, 
                      authState.user.name,
                      state.courses,
                      state.totalStudents,
                      state.totalTeachers,
                      state.totalEnrollments
                    );
                  } else if (state is AdminDashboardError) {
                    return ErrorView(
                      message: state.message,
                      onRetry: () {
                        _dashboardBloc.add(const LoadDashboardDataEvent());
                      },
                    );
                  }
                  return const LoadingIndicator();
                },
              );
            }
            return const Center(child: Text('User data not available.'));
          },
        ),
        drawer: _buildAdminDrawer(context),
        floatingActionButton: FloatingActionButton(
          backgroundColor: AppTheme.adminColor,
          child: const Icon(Icons.add),
          onPressed: () {
            context.router.push(const AddEditCourseRoute());
          },
        ),
      ),
    );
  }

  Widget _buildAdminDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: AppTheme.adminColor,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.admin_panel_settings,
                  color: Colors.white,
                  size: 64,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Mentora Admin',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Control your e-learning platform',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          _buildDrawerItem(
            context,
            icon: Icons.dashboard,
            title: 'Dashboard',
            onTap: () {
              context.router.pop();
            },
            isSelected: true,
          ),
          _buildDrawerItem(
            context,
            icon: Icons.school,
            title: 'Manage Courses',
            onTap: () {
              context.router.push(const CourseManagementRoute());
            },
          ),
          _buildDrawerItem(
            context,
            icon: Icons.person,
            title: 'Assign Instructors',
            onTap: () {
              context.router.push(const AssignInstructorRoute());
            },
          ),
          const Divider(),
          _buildDrawerItem(
            context,
            icon: Icons.people,
            title: 'Manage Users',
            onTap: () {
              // Navigate to users management
            },
          ),
          _buildDrawerItem(
            context,
            icon: Icons.settings,
            title: 'Settings',
            onTap: () {
              // Navigate to settings
            },
          ),
          const Divider(),
          _buildDrawerItem(
            context,
            icon: Icons.logout,
            title: 'Logout',
            onTap: () {
              context.read<AuthBloc>().add(LogoutEvent());
              context.router.replace(const LoginRoute());
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isSelected = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? AppTheme.adminColor : AppTheme.textSecondaryColor,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? AppTheme.adminColor : AppTheme.textPrimaryColor,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      onTap: onTap,
      selected: isSelected,
      selectedTileColor: AppTheme.adminColor.withOpacity(0.1),
    );
  }

  Widget _buildDashboardContent(
    BuildContext context,
    String adminName,
    List<Course> recentCourses,
    int totalStudents,
    int totalTeachers,
    int totalEnrollments,
  ) {
    return RefreshIndicator(
      onRefresh: () async {
        _dashboardBloc.add(const LoadDashboardDataEvent());
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome section
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: AppTheme.adminColor,
                      child: const Icon(
                        Icons.admin_panel_settings,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome back,',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: AppTheme.textSecondaryColor,
                                ),
                          ),
                          Text(
                            adminName,
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Stats section
            Text(
              'Platform Overview',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                _buildStatCard(
                  context,
                  title: 'Courses',
                  value: recentCourses.length.toString(),
                  icon: Icons.school,
                  color: AppTheme.primaryColor,
                ),
                const SizedBox(width: 16),
                _buildStatCard(
                  context,
                  title: 'Students',
                  value: totalStudents.toString(),
                  icon: Icons.people,
                  color: Colors.orange,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildStatCard(
                  context,
                  title: 'Teachers',
                  value: totalTeachers.toString(),
                  icon: Icons.person,
                  color: Colors.teal,
                ),
                const SizedBox(width: 16),
                _buildStatCard(
                  context,
                  title: 'Enrollments',
                  value: totalEnrollments.toString(),
                  icon: Icons.how_to_reg,
                  color: Colors.purple,
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Quick actions section
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                _buildActionCard(
                  context,
                  title: 'Create Course',
                  icon: Icons.add_circle,
                  color: AppTheme.successColor,
                  onTap: () {
                    context.router.push(const AddEditCourseRoute());
                  },
                ),
                const SizedBox(width: 16),
                _buildActionCard(
                  context,
                  title: 'Assign Instructor',
                  icon: Icons.person_add,
                  color: AppTheme.adminColor,
                  onTap: () {
                    context.router.push(const AssignInstructorRoute());
                  },
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Recent courses section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Courses',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                TextButton.icon(
                  icon: const Icon(Icons.view_list),
                  label: const Text('View All'),
                  onPressed: () {
                    context.router.push(const CourseManagementRoute());
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            if (recentCourses.isEmpty)
              EmptyStateView(
                title: 'No Courses Yet',
                message: 'You haven\'t created any courses yet. Create your first course now!',
                icon: Icons.school,
                actionText: 'Create Course',
                onActionPressed: () {
                  context.router.push(const AddEditCourseRoute());
                },
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: recentCourses.length.clamp(0, 3), // Show max 3 recent courses
                itemBuilder: (context, index) {
                  final course = recentCourses[index];
                  return _buildCourseListItem(context, course);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      color: color,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondaryColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                value,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCourseListItem(BuildContext context, Course course) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: AppTheme.adminColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Center(
            child: Icon(
              Icons.school,
              color: AppTheme.adminColor,
            ),
          ),
        ),
        title: Text(
          course.title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              course.instructorName ?? 'No instructor assigned',
              style: TextStyle(
                fontSize: 12,
                color: course.instructorName != null
                    ? AppTheme.textSecondaryColor
                    : AppTheme.errorColor,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getStatusColor(course.status).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    course.status.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: _getStatusColor(course.status),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${course.enrolledStudents}/${course.capacity} students',
                  style: const TextStyle(
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'edit') {
              context.router.push(AddEditCourseRoute(courseId: course.id));
            } else if (value == 'assign') {
              context.router.push(AssignInstructorRoute(courseId: course.id));
            } else if (value == 'delete') {
              _showDeleteConfirmation(context, course);
            }
          },
          itemBuilder: (BuildContext context) {
            return [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, size: 18),
                    SizedBox(width: 8),
                    Text('Edit'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'assign',
                child: Row(
                  children: [
                    Icon(Icons.person_add, size: 18),
                    SizedBox(width: 8),
                    Text('Assign Instructor'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, size: 18, color: AppTheme.errorColor),
                    SizedBox(width: 8),
                    Text('Delete', style: TextStyle(color: AppTheme.errorColor)),
                  ],
                ),
              ),
            ];
          },
        ),
        onTap: () {
          context.router.push(AddEditCourseRoute(courseId: course.id));
        },
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Course course) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Course'),
          content: Text('Are you sure you want to delete "${course.title}"? This action cannot be undone.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text(
                'Delete',
                style: TextStyle(color: AppTheme.errorColor),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                _dashboardBloc.add(DeleteCourseEvent(course.id));
              },
            ),
          ],
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'active':
        return AppTheme.successColor;
      case 'closed':
        return AppTheme.errorColor;
      case 'upcoming':
        return AppTheme.warningColor;
      default:
        return AppTheme.textSecondaryColor;
    }
  }
}
