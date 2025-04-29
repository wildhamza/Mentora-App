import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:mentora/app_router.dart';
import 'package:mentora/core/constants/app_constants.dart';
import 'package:mentora/core/themes/app_theme.dart';
import 'package:mentora/core/widgets/loading_indicator.dart';
import 'package:mentora/data/models/assignment/assignment_model.dart';
import 'package:mentora/presentation/common/widgets/error_widget.dart';

@RoutePage()
class AssignmentsScreen extends StatefulWidget {
  const AssignmentsScreen({Key? key}) : super(key: key);

  @override
  _AssignmentsScreenState createState() => _AssignmentsScreenState();
}

class _AssignmentsScreenState extends State<AssignmentsScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  String? _errorMessage;
  
  List<AssignmentModel> _pendingAssignments = [];
  List<AssignmentModel> _submittedAssignments = [];
  List<AssignmentModel> _gradedAssignments = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadAssignments();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAssignments() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // This would be replaced with actual API calls
    try {
      await Future.delayed(const Duration(seconds: 1));

      // Mock data for UI demonstration
      setState(() {
        _pendingAssignments = [
          AssignmentModel(
            id: 1,
            courseId: 101,
            title: 'Introduction to Flutter',
            description: 'Create a simple Flutter app with 3 screens.',
            dueDate: DateTime.now().add(const Duration(days: 5)),
            maxMarks: 20,
            createdAt: DateTime.now().subtract(const Duration(days: 2)),
            updatedAt: DateTime.now().subtract(const Duration(days: 2)),
          ),
          AssignmentModel(
            id: 2,
            courseId: 102,
            title: 'State Management Research',
            description: 'Compare different state management solutions in Flutter.',
            dueDate: DateTime.now().add(const Duration(days: 7)),
            maxMarks: 15,
            createdAt: DateTime.now().subtract(const Duration(days: 1)),
            updatedAt: DateTime.now().subtract(const Duration(days: 1)),
          ),
        ];

        _submittedAssignments = [
          AssignmentModel(
            id: 3,
            courseId: 103,
            title: 'UI Design Principles',
            description: 'Create a mockup for an e-commerce app following Material Design guidelines.',
            dueDate: DateTime.now().subtract(const Duration(days: 1)),
            maxMarks: 25,
            createdAt: DateTime.now().subtract(const Duration(days: 10)),
            updatedAt: DateTime.now().subtract(const Duration(days: 5)),
          ),
        ];

        _gradedAssignments = [
          AssignmentModel(
            id: 4,
            courseId: 104,
            title: 'Flutter Animations',
            description: 'Implement various animations in a Flutter application.',
            dueDate: DateTime.now().subtract(const Duration(days: 8)),
            maxMarks: 30,
            createdAt: DateTime.now().subtract(const Duration(days: 15)),
            updatedAt: DateTime.now().subtract(const Duration(days: 7)),
          ),
        ];

        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load assignments: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Assignments'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.studentColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppTheme.studentColor,
          tabs: const [
            Tab(text: 'Pending'),
            Tab(text: 'Submitted'),
            Tab(text: 'Graded'),
          ],
        ),
      ),
      body: _isLoading
          ? const LoadingIndicator(message: 'Loading assignments...')
          : _errorMessage != null
              ? ErrorView(
                  message: _errorMessage!,
                  onRetry: _loadAssignments,
                )
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildAssignmentList(_pendingAssignments, AppConstants.assignmentStatusDue),
                    _buildAssignmentList(_submittedAssignments, AppConstants.assignmentStatusSubmitted),
                    _buildAssignmentList(_gradedAssignments, AppConstants.assignmentStatusGraded),
                  ],
                ),
    );
  }

  Widget _buildAssignmentList(List<AssignmentModel> assignments, String status) {
    if (assignments.isEmpty) {
      return EmptyStateView(
        title: 'No Assignments',
        message: status == AppConstants.assignmentStatusDue
            ? 'You don\'t have any pending assignments at the moment.'
            : status == AppConstants.assignmentStatusSubmitted
                ? 'You haven\'t submitted any assignments yet.'
                : 'You don\'t have any graded assignments yet.',
        icon: Icons.assignment,
      );
    }

    return RefreshIndicator(
      onRefresh: _loadAssignments,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: assignments.length,
        itemBuilder: (context, index) {
          final assignment = assignments[index];
          return _buildAssignmentCard(assignment, status);
        },
      ),
    );
  }

  Widget _buildAssignmentCard(AssignmentModel assignment, String status) {
    final Color statusColor;
    final IconData statusIcon;
    
    switch (status) {
      case AppConstants.assignmentStatusDue:
        statusColor = AppTheme.warningColor;
        statusIcon = Icons.timer;
        break;
      case AppConstants.assignmentStatusSubmitted:
        statusColor = AppTheme.primaryColor;
        statusIcon = Icons.check_circle;
        break;
      case AppConstants.assignmentStatusGraded:
        statusColor = AppTheme.successColor;
        statusIcon = Icons.grade;
        break;
      default:
        statusColor = AppTheme.textSecondaryColor;
        statusIcon = Icons.assignment;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          // Handle assignment tap, e.g., navigate to assignment details
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      statusIcon,
                      color: statusColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          assignment.title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _truncateText(assignment.description, 80),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildAssignmentInfoChip(
                    Icons.calendar_today,
                    'Due: ${_formatDate(assignment.dueDate)}',
                    AppTheme.primaryColor.withOpacity(0.1),
                  ),
                  _buildAssignmentInfoChip(
                    Icons.workspace_premium,
                    'Marks: ${assignment.maxMarks}',
                    AppTheme.successColor.withOpacity(0.1),
                  ),
                ],
              ),
              if (status == AppConstants.assignmentStatusDue) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          // Navigate to assignment submission screen
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.studentColor,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Submit Assignment'),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAssignmentInfoChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: AppTheme.textPrimaryColor,
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _truncateText(String text, int maxLength) {
    if (text.length <= maxLength) {
      return text;
    }
    return '${text.substring(0, maxLength)}...';
  }
}
