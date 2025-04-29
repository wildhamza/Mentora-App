import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:mentora/core/themes/app_theme.dart';
import 'package:mentora/core/widgets/app_button.dart';
import 'package:mentora/core/widgets/loading_indicator.dart';
import 'package:mentora/di/injection.dart';
import 'package:mentora/domain/entities/course.dart';
import 'package:mentora/presentation/common/widgets/error_widget.dart';
import 'package:mentora/presentation/teacher/bloc/teacher_dashboard_bloc.dart';
import 'package:mentora/presentation/teacher/bloc/teacher_dashboard_event.dart';
import 'package:mentora/presentation/teacher/bloc/teacher_dashboard_state.dart';

@RoutePage()
class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({Key? key}) : super(key: key);

  @override
  _AttendanceScreenState createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  late TeacherDashboardBloc _dashboardBloc;
  List<Course> _teacherCourses = [];
  Course? _selectedCourse;
  DateTime _selectedDate = DateTime.now();
  bool _isSubmitting = false;
  bool _isLoading = true;
  
  // Mock student data
  final List<Student> _students = [
    Student(id: 1, name: 'Ahmed Khan', email: 'ahmed.khan@example.com'),
    Student(id: 2, name: 'Sara Ahmed', email: 'sara.ahmed@example.com'),
    Student(id: 3, name: 'Imran Ali', email: 'imran.ali@example.com'),
    Student(id: 4, name: 'Fatima Zahra', email: 'fatima.zahra@example.com'),
    Student(id: 5, name: 'Usman Malik', email: 'usman.malik@example.com'),
    Student(id: 6, name: 'Ayesha Iqbal', email: 'ayesha.iqbal@example.com'),
  ];
  
  // Store attendance status for each student
  final Map<int, bool> _attendance = {};
  
  @override
  void initState() {
    super.initState();
    _dashboardBloc = getIt<TeacherDashboardBloc>();
    _dashboardBloc.add(LoadTeacherCoursesEvent());
    
    // Initialize all students as present by default
    for (var student in _students) {
      _attendance[student.id] = true;
    }
  }
  
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now(),
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
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }
  
  void _toggleAttendance(int studentId) {
    setState(() {
      _attendance[studentId] = !(_attendance[studentId] ?? false);
    });
  }
  
  void _markAllPresent() {
    setState(() {
      for (var student in _students) {
        _attendance[student.id] = true;
      }
    });
  }
  
  void _markAllAbsent() {
    setState(() {
      for (var student in _students) {
        _attendance[student.id] = false;
      }
    });
  }
  
  void _submitAttendance() {
    if (_selectedCourse == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a course'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }
    
    setState(() {
      _isSubmitting = true;
    });
    
    _dashboardBloc.add(MarkAttendanceEvent(
      courseId: _selectedCourse!.id,
      date: _selectedDate,
      studentAttendance: _attendance,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _dashboardBloc,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Mark Attendance'),
        ),
        body: BlocConsumer<TeacherDashboardBloc, TeacherDashboardState>(
          listener: (context, state) {
            if (state is TeacherCoursesLoaded) {
              setState(() {
                _teacherCourses = state.courses;
                if (_teacherCourses.isNotEmpty && _selectedCourse == null) {
                  _selectedCourse = _teacherCourses.first;
                }
                _isLoading = false;
              });
            } else if (state is AttendanceMarked) {
              setState(() {
                _isSubmitting = false;
              });
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppTheme.successColor,
                ),
              );
            } else if (state is TeacherDashboardError) {
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
                message: 'Loading courses...',
              );
            }
            
            if (_teacherCourses.isEmpty) {
              return const EmptyStateView(
                title: 'No Courses Available',
                message: 'You don\'t have any assigned courses to mark attendance for.',
                icon: Icons.school,
              );
            }
            
            return Column(
              children: [
                // Course and date selection card
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
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildCourseDropdown(),
                        
                        const SizedBox(height: 16),
                        
                        const Text(
                          'Date',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
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
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  DateFormat('EEEE, MMMM d, yyyy').format(_selectedDate),
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
                ),
                
                // Action buttons
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _markAllPresent,
                          icon: const Icon(Icons.check_circle),
                          label: const Text('All Present'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.successColor,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _markAllAbsent,
                          icon: const Icon(Icons.cancel),
                          label: const Text('All Absent'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.errorColor,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Student list
                Expanded(
                  child: _buildStudentList(),
                ),
                
                // Submit button
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: AppButton(
                    text: 'Submit Attendance',
                    onPressed: _submitAttendance,
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

  Widget _buildStudentList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _students.length,
      itemBuilder: (context, index) {
        final student = _students[index];
        final isPresent = _attendance[student.id] ?? true;
        
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: CircleAvatar(
              backgroundColor: isPresent ? AppTheme.successColor : AppTheme.errorColor,
              child: Icon(
                isPresent ? Icons.check : Icons.close,
                color: Colors.white,
              ),
            ),
            title: Text(
              student.name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(student.email),
            trailing: Switch(
              value: isPresent,
              activeColor: AppTheme.successColor,
              inactiveThumbColor: AppTheme.errorColor,
              onChanged: (value) {
                _toggleAttendance(student.id);
              },
            ),
            onTap: () {
              _toggleAttendance(student.id);
            },
          ),
        );
      },
    );
  }
}

class Student {
  final int id;
  final String name;
  final String email;

  Student({
    required this.id,
    required this.name,
    required this.email,
  });
}
