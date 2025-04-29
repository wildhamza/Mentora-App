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
import 'package:mentora/presentation/student/bloc/student_dashboard_bloc.dart';
import 'package:mentora/presentation/student/bloc/student_dashboard_event.dart';
import 'package:mentora/presentation/student/bloc/student_dashboard_state.dart';

@RoutePage()
class StudentDashboardScreen extends StatefulWidget {
  const StudentDashboardScreen({Key? key}) : super(key: key);

  @override
  _StudentDashboardScreenState createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen> {
  late StudentDashboardBloc _dashboardBloc;
  
  @override
  void initState() {
    super.initState();
    _dashboardBloc = getIt<StudentDashboardBloc>();
    _dashboardBloc.add(LoadEnrolledCoursesEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _dashboardBloc,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Student Dashboard'),
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                context.router.push(const CourseBrowseRoute());
              },
            ),
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
              return BlocConsumer<StudentDashboardBloc, StudentDashboardState>(
                listener: (context, state) {
                  if (state is StudentDashboardError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: AppTheme.errorColor,
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  if (state is StudentDashboardLoading) {
                    return const LoadingIndicator(
                      message: 'Loading your dashboard...',
                    );
                  } else if (state is EnrolledCoursesLoaded) {
                    return _buildDashboardContent(context, authState.user.name, state.courses);
                  } else if (state is StudentDashboardError) {
                    return ErrorView(
                      message: state.message,
                      onRetry: () {
                        _dashboardBloc.add(LoadEnrolledCoursesEvent());
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
          selectedItemColor: AppTheme.studentColor,
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
              icon: Icon(Icons.event),
              label: 'Sessions',
            ),
          ],
          onTap: (index) {
            switch (index) {
              case 0:
                // Already on dashboard
                break;
              case 1:
                context.router.push(const AssignmentsRoute());
                break;
              case 2:
                // Navigate to sessions screen
                break;
            }
          },
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: AppTheme.studentColor,
          child: const Icon(Icons.search),
          onPressed: () {
            context.router.push(const CourseBrowseRoute());
          },
        ),
      ),
    );
  }

  Widget _buildDashboardContent(
      BuildContext context, String userName, List<Course> enrolledCourses) {
    return RefreshIndicator(
      onRefresh: () async {
        _dashboardBloc.add(LoadEnrolledCoursesEvent());
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
                      backgroundColor: AppTheme.studentColor,
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
            
            // Quick stats
            Row(
              children: [
                _buildStatCard(
                  context,
                  Icons.book,
                  enrolledCourses.length.toString(),
                  'Enrolled Courses',
                  AppTheme.primaryColor,
                ),
                const SizedBox(width: 16),
                _buildStatCard(
                  context,
                  Icons.assignment,
                  '5', // This would come from a proper assignment count
                  'Pending Assignments',
                  AppTheme.warningColor,
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // My courses section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'My Courses',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                TextButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Browse More'),
                  onPressed: () {
                    context.router.push(const CourseBrowseRoute());
                  },
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            if (enrolledCourses.isEmpty)
              EmptyStateView(
                title: 'No Courses Yet',
                message: 'You haven\'t enrolled in any courses yet. Browse available courses to get started!',
                icon: Icons.school,
                actionText: 'Browse Courses',
                onActionPressed: () {
                  context.router.push(const CourseBrowseRoute());
                },
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: enrolledCourses.length,
                itemBuilder: (context, index) {
                  final course = enrolledCourses[index];
                  return CourseCard(
                    course: course,
                    onTap: () {
                      context.router.push(CourseDetailRoute(courseId: course.id));
                    },
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    IconData icon,
    String value,
    String label,
    Color color,
  ) {
    return Expanded(
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(
                icon,
                color: color,
                size: 32,
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
