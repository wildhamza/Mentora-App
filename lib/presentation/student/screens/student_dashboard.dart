import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants.dart';
import '../../../core/routes.dart';
import '../../../core/theme.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/course_provider.dart';
import '../../common/app_button.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({Key? key}) : super(key: key);

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Load enrolled courses
      Provider.of<CourseProvider>(context, listen: false).getEnrolledCourses();
    });
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome message
              Text(
                'Welcome, ${authProvider.user?.name ?? 'Student'}!',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              
              const SizedBox(height: 8),
              
              Text(
                'Here\'s your learning dashboard',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Quick access buttons
              Row(
                children: [
                  Expanded(
                    child: _buildQuickAccessCard(
                      context,
                      icon: Icons.menu_book,
                      title: 'Courses',
                      onTap: () {
                        Navigator.of(context).pushNamed(Routes.courseBrowse);
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildQuickAccessCard(
                      context,
                      icon: Icons.assignment,
                      title: 'Assignments',
                      onTap: () {
                        // Navigate to assignments
                      },
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Enrolled courses
              Text(
                'My Courses',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              
              const SizedBox(height: 16),
              
              // Course list
              Expanded(
                child: courseProvider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : courseProvider.enrolledCourses.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.school_outlined,
                                  size: 64,
                                  color: AppColors.textSecondary,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No courses enrolled yet',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                AppButton(
                                  text: 'Explore Courses',
                                  type: ButtonType.primary,
                                  onPressed: () {
                                    Navigator.of(context).pushNamed(Routes.courseBrowse);
                                  },
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: courseProvider.enrolledCourses.length,
                            itemBuilder: (context, index) {
                              final course = courseProvider.enrolledCourses[index];
                              return _buildCourseCard(context, course);
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAccessCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 32,
                color: AppColors.primary,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCourseCard(BuildContext context, dynamic course) {
    // This should use the actual Course model
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              course.title ?? 'Course Name',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              course.description ?? 'Course description goes here',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Progress indicator
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Progress:',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '40%',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: 0.4,
                        backgroundColor: AppColors.primaryLight.withOpacity(0.3),
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Continue button
                AppButton(
                  text: 'Continue',
                  type: ButtonType.primary,
                  onPressed: () {
                    // Navigate to course details
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}