import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme.dart';
import '../../../providers/course_provider.dart';
import '../../common/loading_widget.dart';
import '../../common/error_widget.dart';
import '../../common/app_button.dart';

class AssignInstructorScreen extends StatefulWidget {
  final int courseId;

  const AssignInstructorScreen({
    Key? key,
    required this.courseId,
  }) : super(key: key);

  @override
  State<AssignInstructorScreen> createState() => _AssignInstructorScreenState();
}

class _AssignInstructorScreenState extends State<AssignInstructorScreen> {
  late final CourseProvider _courseProvider;
  bool _isLoading = false;
  String? _searchQuery;
  int? _selectedInstructorId;

  // Mock data for instructors
  final List<Map<String, dynamic>> _instructors = [
    {'id': 1, 'name': 'Dr. Ahmed Khan', 'subject': 'Mathematics', 'courses': 2},
    {
      'id': 2,
      'name': 'Prof. Sara Ali',
      'subject': 'Computer Science',
      'courses': 1
    },
    {'id': 3, 'name': 'Dr. Hamza Malik', 'subject': 'Physics', 'courses': 3},
    {
      'id': 4,
      'name': 'Prof. Aisha Jabeen',
      'subject': 'English Literature',
      'courses': 0
    },
    {'id': 5, 'name': 'Dr. Farooq Ahmed', 'subject': 'Chemistry', 'courses': 1},
    {
      'id': 6,
      'name': 'Prof. Zainab Fatima',
      'subject': 'History',
      'courses': 2
    },
    {'id': 7, 'name': 'Dr. Umar Khalid', 'subject': 'Biology', 'courses': 1},
  ];

  @override
  void initState() {
    super.initState();
    _courseProvider = Provider.of<CourseProvider>(context, listen: false);
    _loadCourseData();
  }

  Future<void> _loadCourseData() async {
    setState(() {
      _isLoading = true;
    });

    await _courseProvider.fetchCourseById(widget.courseId);

    final course = _courseProvider.selectedCourse;
    if (course != null && course.instructorId != null) {
      setState(() {
        _selectedInstructorId = course.instructorId;
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  List<Map<String, dynamic>> _getFilteredInstructors() {
    if (_searchQuery == null || _searchQuery!.isEmpty) {
      return _instructors;
    }

    final query = _searchQuery!.toLowerCase();
    return _instructors.where((instructor) {
      final name = instructor['name'].toString().toLowerCase();
      final subject = instructor['subject'].toString().toLowerCase();
      return name.contains(query) || subject.contains(query);
    }).toList();
  }

  Future<void> _assignInstructor() async {
    if (_selectedInstructorId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an instructor to assign'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final success = await _courseProvider.assignInstructor(
      widget.courseId,
      _selectedInstructorId!,
    );

    setState(() {
      _isLoading = false;
    });

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Instructor assigned successfully'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_courseProvider.error ??
              'Failed to assign instructor. Please try again.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assign Instructor'),
      ),
      body: _isLoading
          ? const LoadingWidget(message: 'Loading data...')
          : _courseProvider.selectedCourse == null
              ? AppErrorWidget(
                  message: 'Could not load course data',
                  onRetry: _loadCourseData,
                )
              : Column(
                  children: [
                    // Course info card
                    Padding(
                      padding: const EdgeInsets.all(16),
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Course Information',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const Divider(),
                            const SizedBox(height: 8),
                            _buildCourseInfoRow(
                              label: 'Title',
                              value: _courseProvider.selectedCourse!.title,
                            ),
                            const SizedBox(height: 8),
                            _buildCourseInfoRow(
                              label: 'Current Instructor',
                              value: _courseProvider
                                      .selectedCourse!.instructorName ??
                                  'None',
                            ),
                            const SizedBox(height: 8),
                            _buildCourseInfoRow(
                              label: 'Students',
                              value:
                                  '${_courseProvider.selectedCourse!.enrolledCount}/${_courseProvider.selectedCourse!.capacity}',
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Search bar
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search instructors',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                        },
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Instructors list
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _getFilteredInstructors().length,
                        itemBuilder: (context, index) {
                          final instructor = _getFilteredInstructors()[index];
                          final isSelected =
                              _selectedInstructorId == instructor['id'];

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: isSelected
                                    ? AppColors.primary
                                    : Colors.transparent,
                                width: isSelected ? 2 : 0,
                              ),
                            ),
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  _selectedInstructorId = instructor['id'];
                                });
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 24,
                                      backgroundColor: isSelected
                                          ? AppColors.primary
                                          : AppColors.secondary
                                              .withOpacity(0.1),
                                      child: Text(
                                        instructor['name']
                                            .toString()
                                            .substring(0, 1),
                                        style: TextStyle(
                                          color: isSelected
                                              ? Colors.white
                                              : AppColors.secondary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            instructor['name'],
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w600,
                                                ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            instructor['subject'],
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.copyWith(
                                                  color:
                                                      AppColors.textSecondary,
                                                ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '${instructor['courses']} active courses',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(
                                                  color:
                                                      AppColors.textSecondary,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Radio<int>(
                                      value: instructor['id'],
                                      groupValue: _selectedInstructorId,
                                      activeColor: AppColors.primary,
                                      onChanged: (value) {
                                        setState(() {
                                          _selectedInstructorId = value;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    // Assign button
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: AppButton(
                        text: 'Assign Instructor',
                        onPressed: _assignInstructor,
                        isLoading: _isLoading,
                        isFullWidth: true,
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildCourseInfoRow({
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
