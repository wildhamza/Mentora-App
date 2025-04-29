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
class ScheduleSessionScreen extends StatefulWidget {
  const ScheduleSessionScreen({Key? key}) : super(key: key);

  @override
  _ScheduleSessionScreenState createState() => _ScheduleSessionScreenState();
}

class _ScheduleSessionScreenState extends State<ScheduleSessionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _meetingLinkController = TextEditingController();
  
  late TeacherDashboardBloc _dashboardBloc;
  List<Course> _teacherCourses = [];
  Course? _selectedCourse;
  DateTime _sessionDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _sessionTime = TimeOfDay.now();
  int _durationMinutes = 60;
  bool _isSubmitting = false;
  
  List<int> _durationOptions = [30, 45, 60, 90, 120, 180];
  
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
    _meetingLinkController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _sessionDate,
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
    
    if (picked != null && picked != _sessionDate) {
      setState(() {
        _sessionDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _sessionTime,
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
    
    if (picked != null && picked != _sessionTime) {
      setState(() {
        _sessionTime = picked;
      });
    }
  }
  
  void _scheduleSession() {
    if (_formKey.currentState!.validate() && _selectedCourse != null) {
      setState(() {
        _isSubmitting = true;
      });
      
      // Combine date and time into a single DateTime
      final startTime = DateTime(
        _sessionDate.year,
        _sessionDate.month,
        _sessionDate.day,
        _sessionTime.hour,
        _sessionTime.minute,
      );
      
      _dashboardBloc.add(ScheduleSessionEvent(
        courseId: _selectedCourse!.id,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        startTime: startTime,
        durationMinutes: _durationMinutes,
        meetingLink: _meetingLinkController.text.trim(),
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
          title: const Text('Schedule Live Session'),
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
            } else if (state is SessionScheduled) {
              setState(() {
                _isSubmitting = false;
              });
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppTheme.successColor,
                ),
              );
              
              // Reset form after successful scheduling
              _titleController.clear();
              _descriptionController.clear();
              _meetingLinkController.clear();
              
              // Navigate back after a short delay
              Future.delayed(const Duration(seconds: 2), () {
                context.router.pop();
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
                    
                    // Session details
                    const Text(
                      'Session Details',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Title field
                    AppTextField(
                      label: 'Session Title',
                      hint: 'Enter session title',
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
                      hint: 'Enter session description',
                      controller: _descriptionController,
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a description';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Session date and time
                    const Text(
                      'Session Schedule',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Date selection
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Date',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              InkWell(
                                onTap: () => _selectDate(context),
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
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        DateFormat('MMM d, yyyy').format(_sessionDate),
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
                        ),
                        const SizedBox(width: 16),
                        // Time selection
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Time',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              InkWell(
                                onTap: () => _selectTime(context),
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
                                        Icons.access_time,
                                        color: AppTheme.teacherColor,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        _sessionTime.format(context),
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
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Duration selection
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Duration',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppTheme.dividerColor),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<int>(
                              value: _durationMinutes,
                              isExpanded: true,
                              items: _durationOptions.map((int duration) {
                                return DropdownMenuItem<int>(
                                  value: duration,
                                  child: Text('$duration minutes'),
                                );
                              }).toList(),
                              onChanged: (int? newValue) {
                                if (newValue != null) {
                                  setState(() {
                                    _durationMinutes = newValue;
                                  });
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Meeting link
                    const Text(
                      'Meeting Information',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    AppTextField(
                      label: 'Meeting Link',
                      hint: 'Enter Zoom, Google Meet, or Dyte link',
                      controller: _meetingLinkController,
                      prefixIcon: Icons.link,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a meeting link';
                        }
                        if (!value.startsWith('http')) {
                          return 'Please enter a valid URL';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info,
                            color: AppTheme.primaryColor,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Students will receive a notification when you schedule this session.',
                              style: TextStyle(
                                color: AppTheme.primaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Schedule button
                    AppButton(
                      text: 'Schedule Session',
                      onPressed: _scheduleSession,
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
}
