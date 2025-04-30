import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/routes.dart';
import '../../../core/theme.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/course_provider.dart';
import '../../../providers/assignment_provider.dart';
import '../../common/loading_widget.dart';
import '../../common/error_widget.dart';
import 'package:intl/intl.dart';

class TeacherDashboard extends StatefulWidget {
  const TeacherDashboard({Key? key}) : super(key: key);

  @override
  State<TeacherDashboard> createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard> {
  late final CourseProvider _courseProvider;
  late final AssignmentProvider _assignmentProvider;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _courseProvider = Provider.of<CourseProvider>(context, listen: false);
    _assignmentProvider =
        Provider.of<AssignmentProvider>(context, listen: false);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    await _courseProvider.fetchAssignedCourses();

    if (_courseProvider.courses.isNotEmpty) {
      await _assignmentProvider
          .fetchCourseAssignments(_courseProvider.courses[0].id);
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _refreshData() async {
    await _loadData();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final courseProvider = Provider.of<CourseProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Teacher Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final success = await authProvider.logout();
              if (success && mounted) {
                Navigator.of(context).pushReplacementNamed(Routes.login);
              }
            },
          ),
        ],
      ),
      drawer: _buildDrawer(authProvider),
      body: _isLoading
          ? const LoadingWidget(message: 'Loading dashboard...')
          : RefreshIndicator(
              onRefresh: _refreshData,
              child: courseProvider.error != null
                  ? AppErrorWidget(
                      message: courseProvider.error!,
                      onRetry: _refreshData,
                    )
                  : SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Welcome card
                          _buildWelcomeCard(authProvider),

                          const SizedBox(height: 24),

                          // Stats overview
                          _buildStatsOverview(courseProvider),

                          const SizedBox(height: 24),

                          // Quick actions
                          _buildQuickActions(),

                          const SizedBox(height: 24),

                          // Upcoming activities
                          _buildUpcomingActivities(),

                          const SizedBox(height: 24),

                          // My courses
                          _buildMyCourses(courseProvider),
                        ],
                      ),
                    ),
            ),
    );
  }

  Widget _buildDrawer(AuthProvider authProvider) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: AppColors.primary,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: Colors.white,
                  child: Text(
                    authProvider.user?.name.substring(0, 1).toUpperCase() ??
                        'T',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  authProvider.user?.name ?? 'Teacher',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  authProvider.user?.email ?? '',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Dashboard'),
            selected: true,
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.book),
            title: const Text('My Courses'),
            onTap: () {
              Navigator.pop(context);
              // Navigate to courses listing
            },
          ),
          ListTile(
            leading: const Icon(Icons.assignment),
            title: const Text('Assignments'),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).pushNamed(Routes.assignmentManagement);
            },
          ),
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('Attendance'),
            onTap: () {
              Navigator.pop(context);
              if (_courseProvider.courses.isNotEmpty) {
                Navigator.of(context).pushNamed(
                  Routes.attendance,
                  arguments: {'courseId': _courseProvider.courses[0].id},
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('No courses assigned yet'),
                  ),
                );
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.video_call),
            title: const Text('Schedule Session'),
            onTap: () {
              Navigator.pop(context);
              if (_courseProvider.courses.isNotEmpty) {
                Navigator.of(context).pushNamed(
                  Routes.scheduleSession,
                  arguments: {'courseId': _courseProvider.courses[0].id},
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('No courses assigned yet'),
                  ),
                );
              }
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              // Navigate to settings
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () async {
              Navigator.pop(context);
              final success = await authProvider.logout();
              if (success && mounted) {
                Navigator.of(context).pushReplacementNamed(Routes.login);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard(AuthProvider authProvider) {
    final now = DateTime.now();
    String greeting;

    if (now.hour < 12) {
      greeting = 'Good Morning';
    } else if (now.hour < 17) {
      greeting = 'Good Afternoon';
    } else {
      greeting = 'Good Evening';
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greeting,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                        fontWeight: FontWeight.w500,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  authProvider.user?.name ?? 'Teacher',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                Text(
                  DateFormat('EEEE, MMM d, yyyy').format(DateTime.now()),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withOpacity(0.8),
                      ),
                ),
              ],
            ),
          ),
          CircleAvatar(
            radius: 36,
            backgroundColor: Colors.white,
            child: Text(
              authProvider.user?.name.substring(0, 1).toUpperCase() ?? 'T',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsOverview(CourseProvider courseProvider) {
    final assignedCourses = courseProvider.courses.length;
    final totalStudents = courseProvider.courses
        .fold<int>(0, (sum, course) => sum + course.enrolledCount);
    final pendingAssignments = _assignmentProvider.assignments
        .where((a) => a.isSubmitted && !a.isEvaluated)
        .length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Overview',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: 'Assigned Courses',
                value: assignedCourses.toString(),
                icon: Icons.menu_book,
                iconColor: AppColors.primary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                title: 'Total Students',
                value: totalStudents.toString(),
                icon: Icons.people,
                iconColor: AppColors.secondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: 'Pending Reviews',
                value: pendingAssignments.toString(),
                icon: Icons.assignment_late,
                iconColor: AppColors.warning,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                title: 'Upcoming Sessions',
                value: '2',
                icon: Icons.video_call,
                iconColor: AppColors.info,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
              Icon(
                icon,
                color: iconColor,
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.5,
          children: [
            _buildActionCard(
              title: 'Mark Attendance',
              icon: Icons.fact_check,
              color: AppColors.success,
              onTap: () {
                if (_courseProvider.courses.isNotEmpty) {
                  Navigator.of(context).pushNamed(
                    Routes.attendance,
                    arguments: {'courseId': _courseProvider.courses[0].id},
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('No courses assigned yet'),
                    ),
                  );
                }
              },
            ),
            _buildActionCard(
              title: 'Create Assignment',
              icon: Icons.assignment_add,
              color: AppColors.primary,
              onTap: () {
                Navigator.of(context).pushNamed(Routes.assignmentManagement);
              },
            ),
            _buildActionCard(
              title: 'Schedule Session',
              icon: Icons.video_call,
              color: AppColors.info,
              onTap: () {
                if (_courseProvider.courses.isNotEmpty) {
                  Navigator.of(context).pushNamed(
                    Routes.scheduleSession,
                    arguments: {'courseId': _courseProvider.courses[0].id},
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('No courses assigned yet'),
                    ),
                  );
                }
              },
            ),
            _buildActionCard(
              title: 'Review Submissions',
              icon: Icons.grading,
              color: AppColors.secondary,
              onTap: () {
                Navigator.of(context).pushNamed(Routes.assignmentManagement);
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
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
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingActivities() {
    // Mock data for upcoming activities
    final activities = [
      {
        'type': 'assignment',
        'title': 'Final Project Due',
        'course': 'Advanced Programming',
        'datetime': DateTime.now().add(const Duration(days: 2)),
      },
      {
        'type': 'session',
        'title': 'Live Lecture: Data Structures',
        'course': 'Computer Science 101',
        'datetime': DateTime.now().add(const Duration(days: 1, hours: 3)),
      },
      {
        'type': 'quiz',
        'title': 'Mid-term Quiz',
        'course': 'Mathematics',
        'datetime': DateTime.now().add(const Duration(hours: 5)),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Upcoming Activities',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            TextButton(
              onPressed: () {
                // Navigate to full calendar/schedule
              },
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (activities.isEmpty)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 32),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.textHint.withOpacity(0.5)),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.event_available,
                  size: 48,
                  color: AppColors.textHint,
                ),
                const SizedBox(height: 16),
                Text(
                  'No upcoming activities',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: activities.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final activity = activities[index];
              return _buildActivityCard(activity);
            },
          ),
      ],
    );
  }

  Widget _buildActivityCard(Map<String, dynamic> activity) {
    IconData getActivityIcon() {
      switch (activity['type']) {
        case 'assignment':
          return Icons.assignment;
        case 'session':
          return Icons.video_call;
        case 'quiz':
          return Icons.quiz;
        default:
          return Icons.event;
      }
    }

    Color getActivityColor() {
      switch (activity['type']) {
        case 'assignment':
          return AppColors.primary;
        case 'session':
          return AppColors.info;
        case 'quiz':
          return AppColors.warning;
        default:
          return AppColors.secondary;
      }
    }

    final now = DateTime.now();
    final activityDate = activity['datetime'] as DateTime;
    final difference = activityDate.difference(now);

    String getTimeText() {
      if (difference.inDays > 0) {
        return 'In ${difference.inDays} days';
      } else if (difference.inHours > 0) {
        return 'In ${difference.inHours} hours';
      } else {
        return 'In ${difference.inMinutes} minutes';
      }
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              color: getActivityColor().withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              getActivityIcon(),
              color: getActivityColor(),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity['title'],
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  activity['course'],
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: getActivityColor().withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              getTimeText(),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: getActivityColor(),
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMyCourses(CourseProvider courseProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'My Courses',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            TextButton(
              onPressed: () {
                // Navigate to full course list
              },
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (courseProvider.courses.isEmpty)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 32),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.textHint.withOpacity(0.5)),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.school,
                  size: 48,
                  color: AppColors.textHint,
                ),
                const SizedBox(height: 16),
                Text(
                  'No courses assigned yet',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
            ),
          )
        else
          SizedBox(
            height: 220,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: courseProvider.courses.length,
              itemBuilder: (context, index) {
                final course = courseProvider.courses[index];
                return _buildCourseCard(course);
              },
            ),
          ),
      ],
    );
  }

  Widget _buildCourseCard(course) {
    return Container(
      width: 300,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Course header/image
          Container(
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              image: course.thumbnail != null
                  ? DecorationImage(
                      image: NetworkImage(course.thumbnail!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: Center(
              child: course.thumbnail == null
                  ? Icon(
                      Icons.menu_book,
                      size: 48,
                      color: AppColors.primary.withOpacity(0.5),
                    )
                  : null,
            ),
          ),

          // Course details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  course.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.people,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${course.enrolledCount} students',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: course.isEnrollmentOpen
                            ? AppColors.success
                            : AppColors.textHint,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        course.isEnrollmentOpen ? 'Active' : 'Inactive',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.white,
                            ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
