import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mentora/app_router.dart';
import 'package:mentora/core/themes/app_theme.dart';
import 'package:mentora/core/widgets/loading_indicator.dart';
import 'package:mentora/di/injection.dart';
import 'package:mentora/domain/entities/course.dart';
import 'package:mentora/presentation/auth/bloc/auth_bloc.dart';
import 'package:mentora/presentation/auth/bloc/auth_event.dart';
import 'package:mentora/presentation/auth/bloc/auth_state.dart';
import 'package:mentora/presentation/common/widgets/course_card.dart';
import 'package:mentora/presentation/common/widgets/error_widget.dart';
import 'package:mentora/presentation/teacher/bloc/teacher_dashboard_bloc.dart';
import 'package:mentora/presentation/teacher/bloc/teacher_dashboard_event.dart';
import 'package:mentora/presentation/teacher/bloc/teacher_dashboard_state.dart';

@RoutePage()
class TeacherDashboardScreen extends StatefulWidget {
  const TeacherDashboardScreen({Key? key}) : super(key: key);

  @override
  _TeacherDashboardScreenState createState() => _TeacherDashboardScreenState();
}

class _TeacherDashboardScreenState extends State<TeacherDashboardScreen> {
  late TeacherDashboardBloc _dashboardBloc;
  
  @override
  void initState() {
    super.initState();
    _dashboardBloc = getIt<TeacherDashboardBloc>();
    _dashboardBloc.add(LoadTeacherCoursesEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _dashboardBloc,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Teacher Dashboard'),
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
              return BlocConsumer<TeacherDashboardBloc, TeacherDashboardState>(
                listener: (context, state) {
                  if (state is TeacherDashboardError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: AppTheme.errorColor,
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  if (state is TeacherDashboardLoading) {
                    return const LoadingIndicator(
                      message: 'Loading your dashboard...',
                    );
                  } else if (state is TeacherCoursesLoaded) {
                    return _buildDashboardContent(context, authState.user.name, state.courses);
                  } else if (state is TeacherDashboardError) {
                    return ErrorView(
                      message: state.message,
                      onRetry: () {
                        _dashboardBloc.add(LoadTeacherCoursesEvent());
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
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: 0,
          selectedItemColor: AppTheme.teacherColor,
          unselectedItemColor: Colors.grey,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.assignment),
              label: 'Assignments',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people),
              label: 'Attendance',
            ),
          ],
          onTap: (index) {
            switch (index) {
              case 0:
                // Already on dashboard
                break;
              case 1:
                context.router.push(const CreateAssignmentRoute());
                break;
              case 2:
                context.router.push(const AttendanceRoute());
                break;
            }
          },
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: AppTheme.teacherColor,
          child: const Icon(Icons.video_call),
          onPressed: () {
            context.router.push(const ScheduleSessionRoute());
          },
        ),
      ),
    );
  }

  Widget _buildDashboardContent(
      BuildContext context, String userName, List<Course> teacherCourses) {
    return RefreshIndicator(
      onRefresh: () async {
        _dashboardBloc.add(LoadTeacherCoursesEvent());
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
                      backgroundColor: AppTheme.teacherColor,
                      child: const Icon(
                        Icons.person,
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
                            userName,
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
            
            // Quick actions
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            
            Row(
              children: [
                _buildActionCard(
                  context,
                  'Create Assignment',
                  Icons.assignment,
                  AppTheme.teacherColor,
                  () {
                    context.router.push(const CreateAssignmentRoute());
                  },
                ),
                const SizedBox(width: 16),
                _buildActionCard(
                  context,
                  'Mark Attendance',
                  Icons.people,
                  Colors.deepOrange,
                  () {
                    context.router.push(const AttendanceRoute());
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildActionCard(
                  context,
                  'Schedule Session',
                  Icons.video_call,
                  Colors.purple,
                  () {
                    context.router.push(const ScheduleSessionRoute());
                  },
                ),
                const SizedBox(width: 16),
                _buildActionCard(
                  context,
                  'Upload Materials',
                  Icons.upload_file,
                  Colors.teal,
                  () {
                    // Navigate to upload materials screen
                  },
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // My courses section
            Text(
              'My Courses',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            
            const SizedBox(height: 12),
            
            if (teacherCourses.isEmpty)
              EmptyStateView(
                title: 'No Courses Yet',
                message: 'You haven\'t been assigned to any courses yet. Please contact the admin if this is unexpected.',
                icon: Icons.school,
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: teacherCourses.length,
                itemBuilder: (context, index) {
                  final course = teacherCourses[index];
                  return CourseCard(
                    course: course,
                    onTap: () {
                      // Navigate to course details/management screen
                    },
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
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
              mainAxisAlignment: MainAxisAlignment.center,
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
                    size: 24,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
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
}
