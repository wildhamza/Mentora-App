import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mentora/app_router.dart';
import 'package:mentora/core/constants/app_constants.dart';
import 'package:mentora/core/themes/app_theme.dart';
import 'package:mentora/core/widgets/app_button.dart';
import 'package:mentora/core/widgets/loading_indicator.dart';
import 'package:mentora/di/injection.dart';
import 'package:mentora/domain/entities/course.dart';
import 'package:mentora/presentation/common/widgets/error_widget.dart';
import 'package:mentora/presentation/student/bloc/student_dashboard_bloc.dart';
import 'package:mentora/presentation/student/bloc/student_dashboard_event.dart';
import 'package:mentora/presentation/student/bloc/student_dashboard_state.dart';

@RoutePage()
class CourseDetailScreen extends StatefulWidget {
  final int courseId;

  const CourseDetailScreen({
    Key? key,
    @PathParam('id') required this.courseId,
  }) : super(key: key);

  @override
  _CourseDetailScreenState createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  late StudentDashboardBloc _dashboardBloc;
  
  @override
  void initState() {
    super.initState();
    _dashboardBloc = getIt<StudentDashboardBloc>();
    _dashboardBloc.add(LoadCourseDetailsEvent(widget.courseId));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _dashboardBloc,
      child: Scaffold(
        body: BlocConsumer<StudentDashboardBloc, StudentDashboardState>(
          listener: (context, state) {
            if (state is EnrollmentSuccess || state is WaitlistSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    state is EnrollmentSuccess
                        ? state.message
                        : (state as WaitlistSuccess).message,
                  ),
                  backgroundColor: AppTheme.successColor,
                ),
              );
              
              // Refresh course details to show updated enrollment status
              _dashboardBloc.add(LoadCourseDetailsEvent(widget.courseId));
            } else if (state is StudentDashboardError) {
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
                message: 'Loading course details...',
              );
            } else if (state is CourseDetailsLoaded) {
              return _buildCourseDetails(context, state.course);
            } else if (state is StudentDashboardError) {
              return ErrorView(
                message: state.message,
                onRetry: () {
                  _dashboardBloc.add(LoadCourseDetailsEvent(widget.courseId));
                },
              );
            }
            
            return const LoadingIndicator();
          },
        ),
      ),
    );
  }

  Widget _buildCourseDetails(BuildContext context, Course course) {
    return CustomScrollView(
      slivers: [
        // App bar with course image/banner
        SliverAppBar(
          expandedHeight: 200,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            title: Text(
              course.title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    color: Colors.black54,
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
            background: Container(
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                image: course.thumbnailUrl != null
                    ? DecorationImage(
                        image: NetworkImage(course.thumbnailUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.7),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        
        // Course details
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status chip
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(course.status).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    course.status.toUpperCase(),
                    style: TextStyle(
                      color: _getStatusColor(course.status),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Course info section
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _buildInfoItem(
                                Icons.person,
                                'Instructor',
                                course.instructorName ?? 'TBA',
                              ),
                            ),
                            Expanded(
                              child: _buildInfoItem(
                                Icons.timer,
                                'Duration',
                                '${course.duration} Days',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildInfoItem(
                                Icons.attach_money,
                                'Fee',
                                'PKR ${course.fee.toStringAsFixed(0)}',
                              ),
                            ),
                            Expanded(
                              child: _buildInfoItem(
                                Icons.people,
                                'Enrollment',
                                '${course.enrolledStudents}/${course.capacity}',
                              ),
                            ),
                          ],
                        ),
                        if (course.enrollmentStartDate != null) ...[
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _buildInfoItem(
                                  Icons.calendar_today,
                                  'Enrollment Start',
                                  _formatDate(course.enrollmentStartDate!),
                                ),
                              ),
                              Expanded(
                                child: _buildInfoItem(
                                  Icons.event_busy,
                                  'Enrollment End',
                                  course.enrollmentEndDate != null
                                      ? _formatDate(course.enrollmentEndDate!)
                                      : 'Open',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Description section
                Text(
                  'About This Course',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  course.description,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                
                const SizedBox(height: 32),
                
                // Enrollment status and action button
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Enrollment Status',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        course.enrollmentStatusText,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 16),
                      if (course.isEnrollmentOpen) ...[
                        AppButton(
                          text: 'Enroll Now - PKR ${course.fee.toStringAsFixed(0)}',
                          onPressed: () {
                            context.router.push(
                              PaymentRoute(courseId: course.id, courseFee: course.fee),
                            );
                          },
                          type: AppButtonType.primary,
                          isFullWidth: true,
                        ),
                      ] else if (course.isFull) ...[
                        AppButton(
                          text: 'Join Waitlist',
                          onPressed: () {
                            _dashboardBloc.add(JoinWaitlistEvent(course.id));
                          },
                          type: AppButtonType.outline,
                          isFullWidth: true,
                        ),
                      ] else ...[
                        AppButton(
                          text: 'Check Back Later',
                          onPressed: null,
                          type: AppButtonType.outline,
                          isFullWidth: true,
                        ),
                      ],
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: AppTheme.primaryColor,
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondaryColor,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case AppConstants.courseStatusActive:
        return AppTheme.successColor;
      case AppConstants.courseStatusClosed:
        return AppTheme.errorColor;
      case AppConstants.courseStatusUpcoming:
        return AppTheme.warningColor;
      default:
        return AppTheme.textSecondaryColor;
    }
  }
}
