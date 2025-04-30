import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/constants.dart';
import '../../../core/routes.dart';
import '../../../core/theme.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/course_provider.dart';
import '../../../providers/assignment_provider.dart';
import '../../../providers/quiz_provider.dart';
import '../../common/loading_widget.dart';
import '../../common/course_card.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({Key? key}) : super(key: key);

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  late final CourseProvider _courseProvider;
  late final AssignmentProvider _assignmentProvider;
  late final QuizProvider _quizProvider;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _courseProvider = Provider.of<CourseProvider>(context, listen: false);
    _assignmentProvider = Provider.of<AssignmentProvider>(
      context,
      listen: false,
    );
    _quizProvider = Provider.of<QuizProvider>(context, listen: false);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    await _courseProvider.fetchEnrolledCourses();
    await _assignmentProvider.fetchStudentAssignments();
    await _quizProvider.fetchStudentQuizzes();

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _refreshData() async {
    return _loadData();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final courseProvider = Provider.of<CourseProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // Navigate to notifications
            },
          ),
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
      body:
          _isLoading
              ? const LoadingWidget(message: 'Loading dashboard...')
              : RefreshIndicator(
                onRefresh: _refreshData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Welcome card
                      _buildWelcomeCard(authProvider),

                      const SizedBox(height: 24),

                      // Upcoming deadlines
                      _buildUpcomingDeadlines(),

                      const SizedBox(height: 24),

                      // My courses
                      _buildMyCourses(courseProvider),

                      const SizedBox(height: 24),

                      // Find new courses
                      _buildFindNewCourses(),
                    ],
                  ),
                ),
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed(Routes.courseBrowse);
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.search),
      ),
    );
  }

  Widget _buildDrawer(AuthProvider authProvider) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: AppColors.primary),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: Colors.white,
                  child: Text(
                    authProvider.user?.name.substring(0, 1).toUpperCase() ??
                        'S',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  authProvider.user?.name ?? 'Student',
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
            leading: const Icon(Icons.school),
            title: const Text('My Courses'),
            onTap: () {
              Navigator.pop(context);
              // Navigate to enrolled courses
            },
          ),
          ListTile(
            leading: const Icon(Icons.assignment),
            title: const Text('Assignments'),
            onTap: () {
              Navigator.pop(context);
              // Navigate to assignments
            },
          ),
          ListTile(
            leading: const Icon(Icons.quiz),
            title: const Text('Quizzes'),
            onTap: () {
              Navigator.pop(context);
              // Navigate to quizzes
            },
          ),
          ListTile(
            leading: const Icon(Icons.book),
            title: const Text('Materials'),
            onTap: () {
              Navigator.pop(context);
              if (_courseProvider.courses.isNotEmpty) {
                Navigator.of(context).pushNamed(
                  Routes.materials,
                  arguments: {'courseId': _courseProvider.courses[0].id},
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('You are not enrolled in any courses yet'),
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
                  authProvider.user?.name ?? 'Student',
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
              authProvider.user?.name.substring(0, 1).toUpperCase() ?? 'S',
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

  Widget _buildUpcomingDeadlines() {
    final assignmentProvider = Provider.of<AssignmentProvider>(context);
    final quizProvider = Provider.of<QuizProvider>(context);

    List<dynamic> deadlines = [];

    // Add assignments
    deadlines.addAll(
      assignmentProvider.assignments
          .where((a) => !a.isSubmitted && !a.isOverdue)
          .map(
            (a) => {
              'type': 'assignment',
              'title': a.title,
              'courseName': 'Course',
              'id': a.id,
              'deadline': a.dueDate,
            },
          ),
    );

    // Add quizzes
    deadlines.addAll(
      quizProvider.quizzes
          .where((q) => !q.isAttempted && q.isUpcoming)
          .map(
            (q) => {
              'type': 'quiz',
              'title': q.title,
              'courseName': 'Course',
              'id': q.id,
              'deadline': q.endTime,
            },
          ),
    );

    // Sort by deadline
    deadlines.sort((a, b) => a['deadline'].compareTo(b['deadline']));

    // Take only the nearest 3 deadlines
    final upcomingDeadlines = deadlines.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Upcoming Deadlines',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () {
                // Navigate to see all deadlines
              },
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (upcomingDeadlines.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            width: double.infinity,
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
              children: [
                Icon(
                  Icons.event_available,
                  size: 48,
                  color: AppColors.textHint,
                ),
                const SizedBox(height: 16),
                Text(
                  'No upcoming deadlines',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'You\'re all caught up!',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: upcomingDeadlines.length,
            itemBuilder: (context, index) {
              final deadline = upcomingDeadlines[index];
              return _buildDeadlineCard(deadline);
            },
          ),
      ],
    );
  }

  Widget _buildDeadlineCard(Map<String, dynamic> deadline) {
    final now = DateTime.now();
    final deadlineDate = deadline['deadline'] as DateTime;
    final daysLeft = deadlineDate.difference(now).inDays;
    final hoursLeft = deadlineDate.difference(now).inHours;

    String timeLeftText;
    Color timeLeftColor;

    if (daysLeft > 0) {
      timeLeftText = '$daysLeft days left';
      timeLeftColor = daysLeft > 3 ? AppColors.success : AppColors.warning;
    } else if (hoursLeft > 0) {
      timeLeftText = '$hoursLeft hours left';
      timeLeftColor = AppColors.error;
    } else {
      timeLeftText = 'Due soon';
      timeLeftColor = AppColors.error;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          // Navigate to the deadline item
          if (deadline['type'] == 'assignment') {
            Navigator.of(context).pushNamed(
              Routes.assignmentSubmission,
              arguments: {'assignmentId': deadline['id']},
            );
          } else if (deadline['type'] == 'quiz') {
            Navigator.of(
              context,
            ).pushNamed(Routes.quiz, arguments: {'quizId': deadline['id']});
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                  color: _getDeadlineColor(deadline['type']).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getDeadlineIcon(deadline['type']),
                  color: _getDeadlineColor(deadline['type']),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      deadline['title'],
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${deadline['courseName']} • ${_getDeadlineTypeText(deadline['type'])}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat(
                            'MMM d, h:mm a',
                          ).format(deadline['deadline']),
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: timeLeftColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: timeLeftColor),
                          ),
                          child: Text(
                            timeLeftText,
                            style: Theme.of(
                              context,
                            ).textTheme.bodySmall?.copyWith(
                              color: timeLeftColor,
                              fontWeight: FontWeight.w500,
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
        ),
      ),
    );
  }

  IconData _getDeadlineIcon(String type) {
    switch (type) {
      case 'assignment':
        return Icons.assignment;
      case 'quiz':
        return Icons.quiz;
      default:
        return Icons.event;
    }
  }

  Color _getDeadlineColor(String type) {
    switch (type) {
      case 'assignment':
        return AppColors.primary;
      case 'quiz':
        return AppColors.warning;
      default:
        return AppColors.secondary;
    }
  }

  String _getDeadlineTypeText(String type) {
    switch (type) {
      case 'assignment':
        return 'Assignment';
      case 'quiz':
        return 'Quiz';
      default:
        return 'Deadline';
    }
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
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () {
                // Navigate to all enrolled courses
              },
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (courseProvider.courses.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            width: double.infinity,
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
              children: [
                Icon(Icons.school, size: 48, color: AppColors.textHint),
                const SizedBox(height: 16),
                Text(
                  'You are not enrolled in any courses yet',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Browse available courses and enroll now',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pushNamed(Routes.courseBrowse);
                  },
                  icon: const Icon(Icons.search),
                  label: const Text('Find Courses'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
          )
        else
          SizedBox(
            height: 280,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: courseProvider.courses.length,
              itemBuilder: (context, index) {
                final course = courseProvider.courses[index];
                return Container(
                  width: 280,
                  margin: const EdgeInsets.only(right: 16),
                  child: CourseCard(
                    course: course,
                    onTap: () {
                      // View course details
                    },
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildFindNewCourses() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Find New Courses',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Container(
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            image: const DecorationImage(
              image: NetworkImage(AssetConstants.classroomImage1),
              fit: BoxFit.cover,
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
              ),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Discover New Subjects',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Browse through our catalog of courses',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed(Routes.courseBrowse);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                  child: const Text('Browse Now'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
