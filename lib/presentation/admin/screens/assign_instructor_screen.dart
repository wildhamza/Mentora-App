import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mentora/core/themes/app_theme.dart';
import 'package:mentora/core/widgets/app_button.dart';
import 'package:mentora/core/widgets/app_text_field.dart';
import 'package:mentora/core/widgets/loading_indicator.dart';
import 'package:mentora/di/injection.dart';
import 'package:mentora/domain/entities/course.dart';
import 'package:mentora/presentation/admin/bloc/admin_dashboard_bloc.dart';
import 'package:mentora/presentation/admin/bloc/admin_dashboard_event.dart';
import 'package:mentora/presentation/admin/bloc/admin_dashboard_state.dart';
import 'package:mentora/presentation/common/widgets/error_widget.dart';

@RoutePage()
class AssignInstructorScreen extends StatefulWidget {
  final int? courseId;

  const AssignInstructorScreen({
    Key? key,
    @QueryParam('courseId') this.courseId,
  }) : super(key: key);

  @override
  _AssignInstructorScreenState createState() => _AssignInstructorScreenState();
}

class _AssignInstructorScreenState extends State<AssignInstructorScreen> {
  late AdminDashboardBloc _dashboardBloc;
  final TextEditingController _searchController = TextEditingController();
  
  bool _isLoading = false;
  bool _isSubmitting = false;
  Course? _selectedCourse;
  List<Course> _courses = [];
  int? _selectedInstructorId;
  
  // Mock teacher data for demonstration
  final List<Teacher> _teachers = [
    Teacher(id: 1, name: 'Dr. Ahmed Khan', email: 'ahmed.khan@example.com', expertise: 'Computer Science'),
    Teacher(id: 2, name: 'Prof. Fatima Ali', email: 'fatima.ali@example.com', expertise: 'Mathematics'),
    Teacher(id: 3, name: 'Dr. Muhammad Usman', email: 'muhammad.usman@example.com', expertise: 'Biology'),
    Teacher(id: 4, name: 'Ms. Ayesha Malik', email: 'ayesha.malik@example.com', expertise: 'English Literature'),
    Teacher(id: 5, name: 'Dr. Imran Hussain', email: 'imran.hussain@example.com', expertise: 'Physics'),
    Teacher(id: 6, name: 'Prof. Zainab Ahmed', email: 'zainab.ahmed@example.com', expertise: 'Psychology'),
  ];
  
  List<Teacher> _filteredTeachers = [];
  
  @override
  void initState() {
    super.initState();
    _dashboardBloc = getIt<AdminDashboardBloc>();
    _filteredTeachers = List.from(_teachers);
    
    if (widget.courseId != null) {
      _loadCourseDetails(widget.courseId!);
    } else {
      _loadCourses();
    }
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadCourseDetails(int courseId) {
    setState(() {
      _isLoading = true;
    });
    
    _dashboardBloc.add(LoadCourseDetailsEvent(courseId));
  }

  void _loadCourses() {
    setState(() {
      _isLoading = true;
    });
    
    _dashboardBloc.add(const LoadCoursesEvent());
  }
  
  void _searchTeachers(String query) {
    setState(() {
      if (query.isNotEmpty) {
        _filteredTeachers = _teachers.where((teacher) {
          return teacher.name.toLowerCase().contains(query.toLowerCase()) ||
              teacher.email.toLowerCase().contains(query.toLowerCase()) ||
              teacher.expertise.toLowerCase().contains(query.toLowerCase());
        }).toList();
      } else {
        _filteredTeachers = List.from(_teachers);
      }
    });
  }
  
  void _assignInstructor() {
    if (_selectedCourse == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a course'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }
    
    if (_selectedInstructorId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an instructor'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }
    
    setState(() {
      _isSubmitting = true;
    });
    
    _dashboardBloc.add(AssignInstructorEvent(
      courseId: _selectedCourse!.id,
      instructorId: _selectedInstructorId!,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _dashboardBloc,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Assign Instructor'),
          backgroundColor: AppTheme.adminColor,
        ),
        body: BlocConsumer<AdminDashboardBloc, AdminDashboardState>(
          listener: (context, state) {
            if (state is CourseDetailsLoaded) {
              setState(() {
                _selectedCourse = state.course;
                _isLoading = false;
                
                // If course already has an instructor, pre-select them
                if (_selectedCourse!.instructorId != null) {
                  _selectedInstructorId = _selectedCourse!.instructorId;
                }
              });
            } else if (state is CoursesLoaded) {
              setState(() {
                _courses = state.courses;
                if (_courses.isNotEmpty && _selectedCourse == null) {
                  _selectedCourse = _courses.first;
                }
                _isLoading = false;
              });
            } else if (state is InstructorAssigned) {
              setState(() {
                _isSubmitting = false;
              });
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppTheme.successColor,
                ),
              );
              
              // Navigate back after a short delay
              Future.delayed(const Duration(seconds: 2), () {
                context.router.pop();
              });
            } else if (state is AdminDashboardError) {
              setState(() {
                _isSubmitting = false;
                _isLoading = false;
              });
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppTheme.errorColor,
                ),
              );
            }
          },
          builder: (context, state) {
            if (_isLoading) {
              return const LoadingIndicator(
                message: 'Loading data...',
              );
            }
            
            return Column(
              children: [
                // Course selection section
                Card(
                  margin: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Course',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        widget.courseId != null
                            ? _buildSelectedCourseInfo()
                            : _buildCourseDropdown(),
                      ],
                    ),
                  ),
                ),
                
                // Teachers search and list
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: AppTextField(
                    label: 'Search Instructors',
                    hint: 'Search by name, email or expertise',
                    controller: _searchController,
                    prefixIcon: Icons.search,
                    onChanged: _searchTeachers,
                    suffixIcon: Icons.clear,
                    onSuffixIconPressed: () {
                      _searchController.clear();
                      _searchTeachers('');
                    },
                  ),
                ),
                
                const SizedBox(height: 16),
                
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Available Instructors',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                
                const SizedBox(height: 8),
                
                Expanded(
                  child: _filteredTeachers.isEmpty
                      ? const EmptyStateView(
                          title: 'No Instructors Found',
                          message: 'Try adjusting your search criteria.',
                          icon: Icons.person_search,
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _filteredTeachers.length,
                          itemBuilder: (context, index) {
                            final teacher = _filteredTeachers[index];
                            final isSelected = _selectedInstructorId == teacher.id;
                            
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: BorderSide(
                                  color: isSelected
                                      ? AppTheme.adminColor
                                      : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    _selectedInstructorId = teacher.id;
                                  });
                                },
                                borderRadius: BorderRadius.circular(8),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 24,
                                        backgroundColor: isSelected
                                            ? AppTheme.adminColor
                                            : Colors.grey[300],
                                        child: Icon(
                                          Icons.person,
                                          color: isSelected
                                              ? Colors.white
                                              : Colors.grey[700],
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              teacher.name,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              teacher.email,
                                              style: const TextStyle(
                                                color: AppTheme.textSecondaryColor,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Expertise: ${teacher.expertise}',
                                              style: const TextStyle(
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Radio<int>(
                                        value: teacher.id,
                                        groupValue: _selectedInstructorId,
                                        activeColor: AppTheme.adminColor,
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
                    isLoading: _isSubmitting,
                    isFullWidth: true,
                    size: AppButtonSize.large,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSelectedCourseInfo() {
    if (_selectedCourse == null) {
      return const Text('Loading course information...');
    }
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.adminColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.school,
              color: AppTheme.adminColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _selectedCourse!.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Current Instructor: ${_selectedCourse!.instructorName ?? 'None'}',
                  style: TextStyle(
                    fontSize: 14,
                    color: _selectedCourse!.instructorName != null 
                        ? AppTheme.successColor 
                        : AppTheme.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.dividerColor),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Course>(
          value: _selectedCourse,
          isExpanded: true,
          hint: const Text('Select a course'),
          items: _courses.map((Course course) {
            return DropdownMenuItem<Course>(
              value: course,
              child: Text(course.title),
            );
          }).toList(),
          onChanged: (Course? newValue) {
            if (newValue != null) {
              setState(() {
                _selectedCourse = newValue;
                // If course already has an instructor, pre-select them
                if (_selectedCourse!.instructorId != null) {
                  _selectedInstructorId = _selectedCourse!.instructorId;
                } else {
                  _selectedInstructorId = null;
                }
              });
            }
          },
        ),
      ),
    );
  }
}

class Teacher {
  final int id;
  final String name;
  final String email;
  final String expertise;

  Teacher({
    required this.id,
    required this.name,
    required this.email,
    required this.expertise,
  });
}
