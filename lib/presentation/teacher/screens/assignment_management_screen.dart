import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme.dart';
import '../../../data/models/assignment_model.dart';
import '../../../providers/assignment_provider.dart';
import '../../../providers/course_provider.dart';
import '../../common/loading_widget.dart';
import '../../common/error_widget.dart';
import '../../common/app_button.dart';
import '../../common/app_text_field.dart';
import 'package:intl/intl.dart';

class AssignmentManagementScreen extends StatefulWidget {
  const AssignmentManagementScreen({Key? key}) : super(key: key);

  @override
  State<AssignmentManagementScreen> createState() =>
      _AssignmentManagementScreenState();
}

class _AssignmentManagementScreenState extends State<AssignmentManagementScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final CourseProvider _courseProvider;
  late final AssignmentProvider _assignmentProvider;
  bool _isLoading = false;
  int _selectedCourseId = -1;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _courseProvider = Provider.of<CourseProvider>(context, listen: false);
    _assignmentProvider = Provider.of<AssignmentProvider>(
      context,
      listen: false,
    );
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    // Load assigned courses first
    await _courseProvider.fetchAssignedCourses();

    // If there are courses, load assignments for the first course
    if (_courseProvider.courses.isNotEmpty) {
      _selectedCourseId = _courseProvider.courses[0].id;
      await _assignmentProvider.fetchCourseAssignments(_selectedCourseId);
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _onCourseChanged(int? courseId) {
    if (courseId != null && courseId != _selectedCourseId) {
      setState(() {
        _selectedCourseId = courseId;
      });
      _assignmentProvider.fetchCourseAssignments(_selectedCourseId);
    }
  }

  Future<void> _refreshData() async {
    if (_selectedCourseId != -1) {
      await _assignmentProvider.fetchCourseAssignments(_selectedCourseId);
    }
  }

  void _showCreateAssignmentDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CreateAssignmentDialog(courseId: _selectedCourseId);
      },
    ).then((_) => _refreshData());
  }

  void _showGradeSubmissionDialog(AssignmentModel assignment) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return GradeSubmissionDialog(assignment: assignment);
      },
    ).then((_) => _refreshData());
  }

  void _showDeleteConfirmation(AssignmentModel assignment) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Assignment'),
          content: Text(
            'Are you sure you want to delete "${assignment.title}"?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                final success = await _assignmentProvider.deleteAssignment(
                  assignment.id,
                );
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Assignment deleted successfully'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                  _refreshData();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        _assignmentProvider.error ??
                            'Failed to delete assignment',
                      ),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: AppColors.error),
              ),
            ),
          ],
        );
      },
    );
  }

  List<AssignmentModel> _getPendingAssignments() {
    return _assignmentProvider.assignments
        .where((a) => a.isSubmitted && !a.isEvaluated)
        .toList();
  }

  List<AssignmentModel> _getActiveAssignments() {
    return _assignmentProvider.assignments
        .where((a) => !a.isSubmitted && !a.isOverdue)
        .toList();
  }

  List<AssignmentModel> _getPastAssignments() {
    return _assignmentProvider.assignments
        .where((a) => a.isSubmitted && a.isEvaluated || a.isOverdue)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final courseProvider = Provider.of<CourseProvider>(context);
    final assignmentProvider = Provider.of<AssignmentProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Assignment Management'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Pending'),
            Tab(text: 'Active'),
            Tab(text: 'Past'),
          ],
          indicatorColor: Colors.white,
          labelColor: Colors.white,
        ),
      ),
      body:
          _isLoading
              ? const LoadingWidget(message: 'Loading assignments...')
              : Column(
                children: [
                  // Course selector
                  if (courseProvider.courses.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.textHint),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            isExpanded: true,
                            value: _selectedCourseId,
                            hint: const Text('Select Course'),
                            items:
                                courseProvider.courses.map((course) {
                                  return DropdownMenuItem<int>(
                                    value: course.id,
                                    child: Text(course.title),
                                  );
                                }).toList(),
                            onChanged: _onCourseChanged,
                          ),
                        ),
                      ),
                    ),

                  // Assignment lists
                  Expanded(
                    child:
                        courseProvider.courses.isEmpty
                            ? Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.school,
                                    size: 64,
                                    color: AppColors.textHint,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No courses assigned yet',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleMedium?.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            )
                            : assignmentProvider.isLoading
                            ? const LoadingWidget()
                            : assignmentProvider.error != null
                            ? AppErrorWidget(
                              message: assignmentProvider.error!,
                              onRetry: _refreshData,
                            )
                            : TabBarView(
                              controller: _tabController,
                              children: [
                                // Pending tab
                                _buildAssignmentList(
                                  _getPendingAssignments(),
                                  'No pending assignments to review',
                                  showGradeButton: true,
                                ),

                                // Active tab
                                _buildAssignmentList(
                                  _getActiveAssignments(),
                                  'No active assignments',
                                  showDeleteButton: true,
                                ),

                                // Past tab
                                _buildAssignmentList(
                                  _getPastAssignments(),
                                  'No past assignments',
                                ),
                              ],
                            ),
                  ),
                ],
              ),
      floatingActionButton:
          courseProvider.courses.isNotEmpty
              ? FloatingActionButton(
                onPressed: _showCreateAssignmentDialog,
                backgroundColor: AppColors.primary,
                child: const Icon(Icons.add),
              )
              : null,
    );
  }

  Widget _buildAssignmentList(
    List<AssignmentModel> assignments,
    String emptyMessage, {
    bool showGradeButton = false,
    bool showDeleteButton = false,
  }) {
    if (assignments.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.assignment, size: 64, color: AppColors.textHint),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshData,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: assignments.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final assignment = assignments[index];
          return _buildAssignmentCard(
            assignment,
            showGradeButton: showGradeButton,
            showDeleteButton: showDeleteButton,
          );
        },
      ),
    );
  }

  Widget _buildAssignmentCard(
    AssignmentModel assignment, {
    bool showGradeButton = false,
    bool showDeleteButton = false,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    assignment.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (showDeleteButton)
                  IconButton(
                    icon: const Icon(Icons.delete, color: AppColors.error),
                    onPressed: () => _showDeleteConfirmation(assignment),
                    tooltip: 'Delete Assignment',
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              assignment.description,
              style: Theme.of(context).textTheme.bodyMedium,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  'Due: ${DateFormat('MMM dd, yyyy').format(assignment.dueDate)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 16),
                Icon(Icons.score, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text(
                  'Marks: ${assignment.totalMarks}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildStatusChip(assignment),
                const Spacer(),
                if (showGradeButton &&
                    assignment.isSubmitted &&
                    !assignment.isEvaluated)
                  ElevatedButton.icon(
                    onPressed: () => _showGradeSubmissionDialog(assignment),
                    icon: const Icon(Icons.grading, size: 16),
                    label: const Text('Grade'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                  ),
              ],
            ),
            if (assignment.isEvaluated) ...[
              const Divider(height: 24),
              Row(
                children: [
                  Text(
                    'Grade: ${assignment.obtainedMarks} / ${assignment.totalMarks}',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Feedback:',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              if (assignment.feedback != null &&
                  assignment.feedback!.isNotEmpty)
                Text(
                  assignment.feedback!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: AppColors.textSecondary,
                  ),
                )
              else
                Text(
                  'No feedback provided',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: AppColors.textHint,
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(AssignmentModel assignment) {
    IconData iconData;
    String label;
    Color color;

    if (assignment.isEvaluated) {
      iconData = Icons.check_circle;
      label = 'Graded';
      color = AppColors.success;
    } else if (assignment.isSubmitted) {
      iconData = Icons.pending;
      label = 'Submitted';
      color = AppColors.info;
    } else if (assignment.isOverdue) {
      iconData = Icons.error;
      label = 'Overdue';
      color = AppColors.error;
    } else {
      iconData = Icons.timer;
      label = 'Active';
      color = AppColors.warning;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(iconData, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class CreateAssignmentDialog extends StatefulWidget {
  final int courseId;

  const CreateAssignmentDialog({Key? key, required this.courseId})
    : super(key: key);

  @override
  State<CreateAssignmentDialog> createState() => _CreateAssignmentDialogState();
}

class _CreateAssignmentDialogState extends State<CreateAssignmentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _marksController = TextEditingController();
  DateTime _dueDate = DateTime.now().add(const Duration(days: 7));
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _marksController.dispose();
    super.dispose();
  }

  Future<void> _selectDueDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (pickedDate != null && pickedDate != _dueDate) {
      setState(() {
        _dueDate = pickedDate;
      });
    }
  }

  Future<void> _createAssignment() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final assignmentData = {
      'course_id': widget.courseId,
      'title': _titleController.text.trim(),
      'description': _descriptionController.text.trim(),
      'total_marks': double.parse(_marksController.text),
      'due_date': _dueDate.toIso8601String(),
      'attachment_urls': <String>[],
    };

    final assignmentProvider = Provider.of<AssignmentProvider>(
      context,
      listen: false,
    );
    final success = await assignmentProvider.createAssignment(assignmentData);

    setState(() {
      _isLoading = false;
    });

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Assignment created successfully'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            assignmentProvider.error ?? 'Failed to create assignment',
          ),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Create New Assignment',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                AppTextField(
                  label: 'Title',
                  hint: 'Enter assignment title',
                  controller: _titleController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Description',
                  hint: 'Enter assignment description',
                  controller: _descriptionController,
                  maxLines: 4,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Total Marks',
                  hint: 'Enter total marks',
                  controller: _marksController,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter total marks';
                    }
                    if (double.tryParse(value) == null ||
                        double.parse(value) <= 0) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Due Date',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: _selectDueDate,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: AppColors.textHint),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.calendar_today,
                              size: 20,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              DateFormat('MMM dd, yyyy').format(_dueDate),
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 12),
                    AppButton(
                      text: 'Create',
                      onPressed: _createAssignment,
                      isLoading: _isLoading,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class GradeSubmissionDialog extends StatefulWidget {
  final AssignmentModel assignment;

  const GradeSubmissionDialog({Key? key, required this.assignment})
    : super(key: key);

  @override
  State<GradeSubmissionDialog> createState() => _GradeSubmissionDialogState();
}

class _GradeSubmissionDialogState extends State<GradeSubmissionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _marksController = TextEditingController();
  final _feedbackController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _marksController.dispose();
    _feedbackController.dispose();
    super.dispose();
  }

  Future<void> _submitGrade() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final marks = double.parse(_marksController.text);
    final feedback = _feedbackController.text.trim();

    final assignmentProvider = Provider.of<AssignmentProvider>(
      context,
      listen: false,
    );

    // This is a mock implementation since we don't have the actual studentId
    // In a real app, we would get the student ID from the submission
    final studentId = 1; // Mock student ID

    final success = await assignmentProvider.gradeAssignment(
      widget.assignment.id,
      studentId,
      marks,
      feedback,
    );

    setState(() {
      _isLoading = false;
    });

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Assignment graded successfully'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            assignmentProvider.error ?? 'Failed to grade assignment',
          ),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Grade Submission',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.assignment.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const Divider(height: 24),
                if (widget.assignment.submissionContent != null) ...[
                  Text(
                    'Submission:',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      widget.assignment.submissionContent!,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                if (widget.assignment.submissionAttachments != null &&
                    widget.assignment.submissionAttachments!.isNotEmpty) ...[
                  Text(
                    'Attachments:',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children:
                        widget.assignment.submissionAttachments!
                            .map(
                              (url) => Chip(
                                avatar: const Icon(Icons.attachment, size: 16),
                                label: Text(url.split('/').last),
                              ),
                            )
                            .toList(),
                  ),
                  const SizedBox(height: 16),
                ],
                AppTextField(
                  label: 'Marks',
                  hint: 'Enter marks (out of ${widget.assignment.totalMarks})',
                  controller: _marksController,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter marks';
                    }
                    final marks = double.tryParse(value);
                    if (marks == null) {
                      return 'Please enter a valid number';
                    }
                    if (marks < 0 || marks > widget.assignment.totalMarks) {
                      return 'Marks must be between 0 and ${widget.assignment.totalMarks}';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Feedback',
                  hint: 'Enter feedback for the student',
                  controller: _feedbackController,
                  maxLines: 4,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 12),
                    AppButton(
                      text: 'Submit Grade',
                      onPressed: _submitGrade,
                      isLoading: _isLoading,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
