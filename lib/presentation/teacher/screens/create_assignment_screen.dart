import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:mentora/core/themes/app_theme.dart';
import 'package:mentora/core/widgets/app_button.dart';
import 'package:mentora/core/widgets/app_text_field.dart';
import 'package:mentora/core/widgets/loading_indicator.dart';
import 'package:mentora/di/injection.dart';
import 'package:mentora/domain/entities/course.dart';
import 'package:mentora/presentation/teacher/bloc/teacher_dashboard_bloc.dart';
import 'package:mentora/presentation/teacher/bloc/teacher_dashboard_event.dart';
import 'package:mentora/presentation/teacher/bloc/teacher_dashboard_state.dart';

@RoutePage()
class CreateAssignmentScreen extends StatefulWidget {
  const CreateAssignmentScreen({Key? key}) : super(key: key);

  @override
  _CreateAssignmentScreenState createState() => _CreateAssignmentScreenState();
}

class _CreateAssignmentScreenState extends State<CreateAssignmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _maxMarksController = TextEditingController();
  
  late TeacherDashboardBloc _dashboardBloc;
  List<Course> _teacherCourses = [];
  Course? _selectedCourse;
  DateTime _dueDate = DateTime.now().add(const Duration(days: 7));
  bool _isFileAttached = false;
  bool _isSubmitting = false;
  
  @override
  void initState() {
    super.initState();
    _dashboardBloc = getIt<TeacherDashboardBloc>();
    _dashboardBloc.add(LoadTeacherCoursesEvent());
  }
  
  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _maxMarksController.dispose();
    super.dispose();
  }

  Future<void> _selectDueDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppTheme.teacherColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppTheme.textPrimaryColor,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != _dueDate) {
      setState(() {
        _dueDate = picked;
      });
    }
  }
  
  void _attachFile() {
    // This would actually open a file picker
    setState(() {
      _isFileAttached = true;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('File attached successfully'),
        backgroundColor: AppTheme.successColor,
      ),
    );
  }
  
  void _createAssignment() {
    if (_formKey.currentState!.validate() && _selectedCourse != null) {
      setState(() {
        _isSubmitting = true;
      });
      
      _dashboardBloc.add(CreateAssignmentEvent(
        courseId: _selectedCourse!.id,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        dueDate: _dueDate,
        maxMarks: int.parse(_maxMarksController.text.trim()),
        fileUrl: _isFileAttached ? 'https://example.com/assignment_file.pdf' : null,
      ));
    } else if (_selectedCourse == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a course'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _dashboardBloc,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Create Assignment'),
        ),
        body: BlocConsumer<TeacherDashboardBloc, TeacherDashboardState>(
          listener: (context, state) {
            if (state is TeacherCoursesLoaded) {
              setState(() {
                _teacherCourses = state.courses;
                if (_teacherCourses.isNotEmpty && _selectedCourse == null) {
                  _selectedCourse = _teacherCourses.first;
                }
              });
            } else if (state is AssignmentCreated) {
              setState(() {
                _isSubmitting = false;
              });
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppTheme.successColor,
                ),
              );
              
              // Reset form after successful creation
              _titleController.clear();
              _descriptionController.clear();
              _maxMarksController.clear();
              setState(() {
                _dueDate = DateTime.now().add(const Duration(days: 7));
                _isFileAttached = false;
              });
            } else if (state is TeacherDashboardError) {
              setState(() {
                _isSubmitting = false;
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
            if (state is TeacherDashboardLoading && _teacherCourses.isEmpty) {
              return const LoadingIndicator(
                message: 'Loading courses...',
              );
            }
            
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Course selection
                    const Text(
                      'Select Course',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildCourseDropdown(),
                    
                    const SizedBox(height: 24),
                    
                    // Assignment details
                    const Text(
                      'Assignment Details',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Title field
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
                    
                    // Description field
                    AppTextField(
                      label: 'Description',
                      hint: 'Enter assignment description',
                      controller: _descriptionController,
                      maxLines: 5,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a description';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Due date field
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Due Date',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: () => _selectDueDate(context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppTheme.dividerColor),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.calendar_today,
                                  color: AppTheme.teacherColor,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  DateFormat('EEEE, MMMM d, yyyy').format(_dueDate),
                                  style: const TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Max marks field
                    AppTextField(
                      label: 'Maximum Marks',
                      hint: 'Enter maximum marks',
                      controller: _maxMarksController,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter maximum marks';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Attachment section
                    const Text(
                      'Attachment',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // File attachment area
                            _isFileAttached
                                ? _buildAttachedFilePreview()
                                : _buildAttachmentDropArea(),
                            
                            const SizedBox(height: 16),
                            
                            // Attach file button
                            if (!_isFileAttached)
                              AppButton(
                                text: 'Attach File',
                                icon: Icons.attach_file,
                                onPressed: _attachFile,
                                type: AppButtonType.outline,
                              ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Create assignment button
                    AppButton(
                      text: 'Create Assignment',
                      onPressed: _createAssignment,
                      isLoading: _isSubmitting,
                      isFullWidth: true,
                      size: AppButtonSize.large,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
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
          items: _teacherCourses.map((Course course) {
            return DropdownMenuItem<Course>(
              value: course,
              child: Text(course.title),
            );
          }).toList(),
          onChanged: (Course? newValue) {
            if (newValue != null) {
              setState(() {
                _selectedCourse = newValue;
              });
            }
          },
        ),
      ),
    );
  }

  Widget _buildAttachmentDropArea() {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppTheme.dividerColor,
          style: BorderStyle.dashed,
        ),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_upload,
              size: 48,
              color: AppTheme.teacherColor,
            ),
            SizedBox(height: 8),
            Text(
              'Drag & drop files here or click to browse',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachedFilePreview() {
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
              color: AppTheme.teacherColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.description,
              color: AppTheme.teacherColor,
              size: 32,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'assignment_instructions.pdf',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '2.4 MB',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              setState(() {
                _isFileAttached = false;
              });
            },
          ),
        ],
      ),
    );
  }
}
