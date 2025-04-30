import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/constants.dart';
import '../../../core/theme.dart';
import '../../../providers/course_provider.dart';
import '../../common/app_button.dart';
import '../../common/app_text_field.dart';
import '../../common/loading_widget.dart';
import 'package:intl/intl.dart';

class AddEditCourseScreen extends StatefulWidget {
  final int? courseId;
  
  const AddEditCourseScreen({
    Key? key,
    this.courseId,
  }) : super(key: key);

  @override
  State<AddEditCourseScreen> createState() => _AddEditCourseScreenState();
}

class _AddEditCourseScreenState extends State<AddEditCourseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _feesController = TextEditingController();
  final _capacityController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isEnrollmentOpen = false;
  bool _isLoading = false;
  bool _isEditing = false;
  
  @override
  void initState() {
    super.initState();
    _isEditing = widget.courseId != null;
    
    if (_isEditing) {
      _loadCourseData();
    }
  }
  
  Future<void> _loadCourseData() async {
    setState(() {
      _isLoading = true;
    });
    
    final courseProvider = Provider.of<CourseProvider>(context, listen: false);
    await courseProvider.fetchCourseById(widget.courseId!);
    
    final course = courseProvider.selectedCourse;
    
    if (course != null) {
      _titleController.text = course.title;
      _descriptionController.text = course.description;
      _feesController.text = course.fees.toString();
      _capacityController.text = course.capacity.toString();
      _startDate = course.startDate;
      _endDate = course.endDate;
      _isEnrollmentOpen = course.isEnrollmentOpen;
    }
    
    setState(() {
      _isLoading = false;
    });
  }
  
  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _feesController.dispose();
    _capacityController.dispose();
    super.dispose();
  }
  
  Future<void> _saveCourse() async {
    if (_formKey.currentState?.validate() != true) {
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    final courseData = {
      'title': _titleController.text.trim(),
      'description': _descriptionController.text.trim(),
      'fees': double.parse(_feesController.text),
      'capacity': int.parse(_capacityController.text),
      'start_date': _startDate?.toIso8601String(),
      'end_date': _endDate?.toIso8601String(),
      'is_enrollment_open': _isEnrollmentOpen,
    };
    
    final courseProvider = Provider.of<CourseProvider>(context, listen: false);
    
    bool success;
    if (_isEditing) {
      success = await courseProvider.updateCourse(widget.courseId!, courseData);
    } else {
      success = await courseProvider.createCourse(courseData);
    }
    
    setState(() {
      _isLoading = false;
    });
    
    if (!mounted) return;
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditing ? 'Course updated successfully' : 'Course created successfully'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(courseProvider.error ?? 'Failed to save course. Please try again.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
  
  Future<void> _selectStartDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (picked != null && picked != _startDate) {
      setState(() {
        _startDate = picked;
        
        // If end date is before start date, update it
        if (_endDate != null && _endDate!.isBefore(_startDate!)) {
          _endDate = _startDate!.add(const Duration(days: 30));
        }
      });
    }
  }
  
  Future<void> _selectEndDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? (_startDate != null ? _startDate!.add(const Duration(days: 30)) : DateTime.now().add(const Duration(days: 30))),
      firstDate: _startDate ?? DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 730)),
    );
    
    if (picked != null && picked != _endDate) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Course' : 'Add Course'),
      ),
      body: _isLoading
          ? const LoadingWidget(message: 'Loading course data...')
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Course title
                    AppTextField(
                      label: 'Course Title',
                      hint: 'Enter course title',
                      controller: _titleController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return ErrorMessages.emptyFieldError;
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Course description
                    AppTextField(
                      label: 'Description',
                      hint: 'Enter course description',
                      controller: _descriptionController,
                      maxLines: 4,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return ErrorMessages.emptyFieldError;
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Course fees
                    AppTextField(
                      label: 'Fees (Rs.)',
                      hint: 'Enter course fees',
                      controller: _feesController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return ErrorMessages.emptyFieldError;
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Course capacity
                    AppTextField(
                      label: 'Capacity',
                      hint: 'Maximum number of students',
                      controller: _capacityController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return ErrorMessages.emptyFieldError;
                        }
                        
                        final capacity = int.tryParse(value);
                        if (capacity == null || capacity <= 0) {
                          return 'Capacity must be a positive number';
                        }
                        
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    Text(
                      'Enrollment Period',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    // Date selection
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: _selectStartDate,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
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
                                    _startDate != null
                                        ? DateFormat('MMM dd, yyyy').format(_startDate!)
                                        : 'Start Date',
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: _startDate != null ? AppColors.textPrimary : AppColors.textHint,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: InkWell(
                            onTap: _selectEndDate,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
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
                                    _endDate != null
                                        ? DateFormat('MMM dd, yyyy').format(_endDate!)
                                        : 'End Date',
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: _endDate != null ? AppColors.textPrimary : AppColors.textHint,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Enrollment open switch
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: AppColors.textHint),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Open Enrollment',
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Allow students to enroll in this course',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: _isEnrollmentOpen,
                            onChanged: (value) {
                              setState(() {
                                _isEnrollmentOpen = value;
                              });
                            },
                            activeColor: AppColors.primary,
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Submit button
                    AppButton(
                      text: _isEditing ? 'Update Course' : 'Create Course',
                      onPressed: _saveCourse,
                      isLoading: _isLoading,
                      isFullWidth: true,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
