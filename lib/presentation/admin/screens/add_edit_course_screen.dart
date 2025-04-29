import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:mentora/core/constants/app_constants.dart';
import 'package:mentora/core/themes/app_theme.dart';
import 'package:mentora/core/widgets/app_button.dart';
import 'package:mentora/core/widgets/app_text_field.dart';
import 'package:mentora/core/widgets/loading_indicator.dart';
import 'package:mentora/di/injection.dart';
import 'package:mentora/domain/entities/course.dart';
import 'package:mentora/presentation/admin/bloc/admin_dashboard_bloc.dart';
import 'package:mentora/presentation/admin/bloc/admin_dashboard_event.dart';
import 'package:mentora/presentation/admin/bloc/admin_dashboard_state.dart';

@RoutePage()
class AddEditCourseScreen extends StatefulWidget {
  final int? courseId;

  const AddEditCourseScreen({
    Key? key,
    @PathParam('id') this.courseId,
  }) : super(key: key);

  @override
  _AddEditCourseScreenState createState() => _AddEditCourseScreenState();
}

class _AddEditCourseScreenState extends State<AddEditCourseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _durationController = TextEditingController();
  final _feeController = TextEditingController();
  final _capacityController = TextEditingController();
  
  late AdminDashboardBloc _dashboardBloc;
  bool _isEditing = false;
  bool _isLoading = false;
  bool _isSubmitting = false;
  Course? _existingCourse;
  
  String _selectedStatus = AppConstants.courseStatusUpcoming;
  
  DateTime? _enrollmentStartDate;
  DateTime? _enrollmentEndDate;
  
  @override
  void initState() {
    super.initState();
    _dashboardBloc = getIt<AdminDashboardBloc>();
    _isEditing = widget.courseId != null;
    
    if (_isEditing) {
      _loadCourseDetails();
    }
  }
  
  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _durationController.dispose();
    _feeController.dispose();
    _capacityController.dispose();
    super.dispose();
  }

  void _loadCourseDetails() {
    setState(() {
      _isLoading = true;
    });
    
    _dashboardBloc.add(LoadCourseDetailsEvent(widget.courseId!));
  }
  
  void _populateFormFields(Course course) {
    _titleController.text = course.title;
    _descriptionController.text = course.description;
    _durationController.text = course.duration.toString();
    _feeController.text = course.fee.toString();
    _capacityController.text = course.capacity.toString();
    
    setState(() {
      _selectedStatus = course.status;
      _enrollmentStartDate = course.enrollmentStartDate;
      _enrollmentEndDate = course.enrollmentEndDate;
      _existingCourse = course;
      _isLoading = false;
    });
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final initialDate = isStartDate 
        ? _enrollmentStartDate ?? DateTime.now() 
        : _enrollmentEndDate ?? (_enrollmentStartDate?.add(const Duration(days: 7)) ?? DateTime.now().add(const Duration(days: 7)));
    
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: isStartDate ? DateTime.now() : (_enrollmentStartDate ?? DateTime.now()),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppTheme.adminColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppTheme.textPrimaryColor,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _enrollmentStartDate = picked;
          // If end date is before start date, adjust it
          if (_enrollmentEndDate != null && _enrollmentEndDate!.isBefore(_enrollmentStartDate!)) {
            _enrollmentEndDate = _enrollmentStartDate!.add(const Duration(days: 7));
          }
        } else {
          _enrollmentEndDate = picked;
        }
      });
    }
  }
  
  void _saveCourse() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });
      
      final courseData = Course(
        id: _isEditing ? _existingCourse!.id : 0,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        status: _selectedStatus,
        duration: int.parse(_durationController.text.trim()),
        fee: double.parse(_feeController.text.trim()),
        capacity: int.parse(_capacityController.text.trim()),
        enrollmentStartDate: _enrollmentStartDate,
        enrollmentEndDate: _enrollmentEndDate,
        enrolledStudents: _isEditing ? _existingCourse!.enrolledStudents : 0,
        thumbnailUrl: _isEditing ? _existingCourse!.thumbnailUrl : null,
        instructorId: _isEditing ? _existingCourse!.instructorId : null,
        instructorName: _isEditing ? _existingCourse!.instructorName : null,
        createdAt: _isEditing ? _existingCourse!.createdAt : DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      if (_isEditing) {
        _dashboardBloc.add(UpdateCourseEvent(courseData));
      } else {
        _dashboardBloc.add(CreateCourseEvent(courseData));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenTitle = _isEditing ? 'Edit Course' : 'Create Course';
    
    return BlocProvider.value(
      value: _dashboardBloc,
      child: Scaffold(
        appBar: AppBar(
          title: Text(screenTitle),
          backgroundColor: AppTheme.adminColor,
        ),
        body: BlocConsumer<AdminDashboardBloc, AdminDashboardState>(
          listener: (context, state) {
            if (state is CourseDetailsLoaded) {
              _populateFormFields(state.course);
            } else if (state is CourseCreated || state is CourseUpdated) {
              setState(() {
                _isSubmitting = false;
              });
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    _isEditing
                        ? AppConstants.successCourseUpdated
                        : AppConstants.successCourseCreated,
                  ),
                  backgroundColor: AppTheme.successColor,
                ),
              );
              
              // Navigate back after a short delay
              Future.delayed(const Duration(seconds: a2), () {
                context.router.pop();
              });
            } else if (state is AdminDashboardError) {
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
            if (_isLoading) {
              return const LoadingIndicator(
                message: 'Loading course details...',
              );
            }
            
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Basic information section
                    const Text(
                      'Basic Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Title field
                    AppTextField(
                      label: 'Course Title',
                      hint: 'Enter course title',
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
                      hint: 'Enter course description',
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
                    
                    // Status field
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Status',
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
                            child: DropdownButton<String>(
                              value: _selectedStatus,
                              isExpanded: true,
                              items: [
                                AppConstants.courseStatusUpcoming,
                                AppConstants.courseStatusActive,
                                AppConstants.courseStatusClosed,
                              ].map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value.toUpperCase()),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                if (newValue != null) {
                                  setState(() {
                                    _selectedStatus = newValue;
                                  });
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Course parameters section
                    const Text(
                      'Course Parameters',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Duration field
                    AppTextField(
                      label: 'Duration (days)',
                      hint: 'Enter course duration in days',
                      controller: _durationController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter duration';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Fee field
                    AppTextField(
                      label: 'Fee (PKR)',
                      hint: 'Enter course fee',
                      controller: _feeController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter fee';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Capacity field
                    AppTextField(
                      label: 'Capacity',
                      hint: 'Enter maximum number of students',
                      controller: _capacityController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter capacity';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Enrollment period section
                    const Text(
                      'Enrollment Period',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Start date field
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Enrollment Start Date',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: () => _selectDate(context, true),
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
                                  color: AppTheme.adminColor,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _enrollmentStartDate == null
                                      ? 'Select date'
                                      : DateFormat('EEEE, MMMM d, yyyy').format(_enrollmentStartDate!),
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: _enrollmentStartDate == null
                                        ? AppTheme.textSecondaryColor
                                        : AppTheme.textPrimaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // End date field
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Enrollment End Date',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: () => _selectDate(context, false),
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
                                  color: AppTheme.adminColor,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _enrollmentEndDate == null
                                      ? 'Select date'
                                      : DateFormat('EEEE, MMMM d, yyyy').format(_enrollmentEndDate!),
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: _enrollmentEndDate == null
                                        ? AppTheme.textSecondaryColor
                                        : AppTheme.textPrimaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Save button
                    AppButton(
                      text: _isEditing ? 'Update Course' : 'Create Course',
                      onPressed: _saveCourse,
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
}
