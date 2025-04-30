import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/constants.dart';
import '../../../core/theme.dart';
import '../../../data/models/attendance_model.dart';
import '../../../providers/attendance_provider.dart';
import '../../../providers/course_provider.dart';
import '../../common/loading_widget.dart';
import '../../common/error_widget.dart';
import '../../common/app_button.dart';

class AttendanceScreen extends StatefulWidget {
  final int courseId;

  const AttendanceScreen({
    Key? key,
    required this.courseId,
  }) : super(key: key);

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final AttendanceProvider _attendanceProvider;
  late final CourseProvider _courseProvider;
  bool _isLoading = false;
  DateTime _selectedDate = DateTime.now();
  
  // Mock students data for marking attendance
  final List<Map<String, dynamic>> _mockStudents = [
    {'id': 1, 'name': 'Ali Hassan', 'isPresent': true},
    {'id': 2, 'name': 'Fatima Khan', 'isPresent': true},
    {'id': 3, 'name': 'Muhammad Ahmed', 'isPresent': true},
    {'id': 4, 'name': 'Ayesha Malik', 'isPresent': true},
    {'id': 5, 'name': 'Usman Ali', 'isPresent': true},
    {'id': 6, 'name': 'Zainab Fatima', 'isPresent': true},
    {'id': 7, 'name': 'Omar Khalid', 'isPresent': true},
    {'id': 8, 'name': 'Hira Zafar', 'isPresent': true},
  ];

  List<Map<String, dynamic>> _studentsAttendance = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _attendanceProvider = Provider.of<AttendanceProvider>(context, listen: false);
    _courseProvider = Provider.of<CourseProvider>(context, listen: false);
    _studentsAttendance = List.from(_mockStudents);
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

    await _courseProvider.fetchCourseById(widget.courseId);
    await _attendanceProvider.fetchCourseAttendanceRecords(widget.courseId);
    await _attendanceProvider.fetchCourseAttendanceSummary(widget.courseId);

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _refreshData() async {
    await _attendanceProvider.fetchCourseAttendanceRecords(widget.courseId);
    await _attendanceProvider.fetchCourseAttendanceSummary(widget.courseId);
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _markAttendance() async {
    setState(() {
      _isLoading = true;
    });

    final attendance = _studentsAttendance.map((student) => {
      'student_id': student['id'],
      'student_name': student['name'],
      'is_present': student['isPresent'],
    }).toList();

    final success = await _attendanceProvider.markAttendance(
      widget.courseId,
      _selectedDate,
      attendance,
    );

    setState(() {
      _isLoading = false;
    });

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Attendance marked successfully'),
          backgroundColor: AppColors.success,
        ),
      );
      _refreshData();
      _tabController.animateTo(1); // Switch to history tab
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_attendanceProvider.error ?? 'Failed to mark attendance'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _toggleStudentAttendance(int index, bool value) {
    setState(() {
      _studentsAttendance[index]['isPresent'] = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Attendance - ${_courseProvider.selectedCourse?.title ?? "Course"}',
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Mark Attendance'),
            Tab(text: 'Attendance History'),
          ],
          indicatorColor: Colors.white,
          labelColor: Colors.white,
        ),
      ),
      body: _isLoading
          ? const LoadingWidget(message: 'Loading attendance data...')
          : TabBarView(
              controller: _tabController,
              children: [
                // Mark Attendance Tab
                _buildMarkAttendanceTab(),

                // Attendance History Tab
                _buildAttendanceHistoryTab(),
              ],
            ),
    );
  }

  Widget _buildMarkAttendanceTab() {
    return Column(
      children: [
        // Date selector
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: _selectDate,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.primary),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          DateFormat('MMMM dd, yyyy').format(_selectedDate),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Icon(Icons.calendar_today, color: AppColors.primary),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Present/absent count
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: _buildCountCard(
                  title: 'Present',
                  count: _studentsAttendance.where((s) => s['isPresent']).length,
                  total: _studentsAttendance.length,
                  color: AppColors.success,
                  icon: Icons.check_circle,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildCountCard(
                  title: 'Absent',
                  count: _studentsAttendance.where((s) => !s['isPresent']).length,
                  total: _studentsAttendance.length,
                  color: AppColors.error,
                  icon: Icons.cancel,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Students list
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Text(
                'Students',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Spacer(),
              Text(
                'Mark All:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(width: 8),
              // Mark all buttons would go here
            ],
          ),
        ),

        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _studentsAttendance.length,
            itemBuilder: (context, index) {
              final student = _studentsAttendance[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    child: Text(
                      student['name'].toString().substring(0, 1),
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(student['name']),
                  trailing: Switch(
                    value: student['isPresent'],
                    onChanged: (value) => _toggleStudentAttendance(index, value),
                    activeColor: AppColors.success,
                    inactiveTrackColor: AppColors.error.withOpacity(0.5),
                  ),
                ),
              );
            },
          ),
        ),

        // Submit button
        Padding(
          padding: const EdgeInsets.all(16),
          child: AppButton(
            text: 'Submit Attendance',
            onPressed: _markAttendance,
            isLoading: _isLoading,
            isFullWidth: true,
          ),
        ),
      ],
    );
  }

  Widget _buildAttendanceHistoryTab() {
    final attendanceProvider = Provider.of<AttendanceProvider>(context);

    if (attendanceProvider.isLoading) {
      return const LoadingWidget(message: 'Loading attendance records...');
    }

    if (attendanceProvider.error != null) {
      return AppErrorWidget(
        message: attendanceProvider.error!,
        onRetry: _refreshData,
      );
    }

    if (attendanceProvider.attendanceRecords.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.history,
              size: 64,
              color: AppColors.textHint,
            ),
            const SizedBox(height: 16),
            Text(
              'No attendance records found',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshData,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Overall attendance summary
          Card(
            margin: const EdgeInsets.only(bottom: 24),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Overall Attendance Summary',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  LinearProgressIndicator(
                    value: attendanceProvider.attendanceRecords.isEmpty
                        ? 0
                        : attendanceProvider.attendanceRecords.first.attendancePercentage / 100,
                    backgroundColor: Colors.grey[300],
                    color: AppColors.success,
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${attendanceProvider.attendanceRecords.isEmpty ? 0 : attendanceProvider.attendanceRecords.first.attendancePercentage.toStringAsFixed(1)}% Attendance',
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          color: AppColors.success,
                        ),
                      ),
                      Text(
                        '${attendanceProvider.attendanceRecords.length} Classes',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Student attendance summary
          if (attendanceProvider.attendanceSummary.isNotEmpty) ...[
            const Text(
              'Student Summary',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...attendanceProvider.attendanceSummary.map(
              (summary) => Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: AppColors.primary.withOpacity(0.1),
                        child: Text(
                          summary.studentName.substring(0, 1),
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              summary.studentName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            LinearProgressIndicator(
                              value: summary.attendancePercentage / 100,
                              backgroundColor: Colors.grey[300],
                              color: _getAttendanceColor(summary.attendancePercentage),
                              minHeight: 6,
                              borderRadius: BorderRadius.circular(3),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${summary.attendancePercentage.toStringAsFixed(1)}%',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: _getAttendanceColor(summary.attendancePercentage),
                                  ),
                                ),
                                Text(
                                  'Present: ${summary.presentCount}/${summary.totalClasses}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],

          const SizedBox(height: 24),

          // Daily attendance records
          const Text(
            'Daily Records',
            style: TextStyle(
              fontSize:.18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...attendanceProvider.attendanceRecords.map(
            (record) => Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ExpansionTile(
                title: Text(
                  DateFormat('MMMM dd, yyyy').format(record.date),
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: Text(
                  'Present: ${record.presentCount}/${record.students.length} (${record.attendancePercentage.toStringAsFixed(1)}%)',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                  ),
                ),
                trailing: Icon(
                  Icons.chevron_right,
                  color: AppColors.textSecondary,
                ),
                children: [
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: record.students.length,
                    itemBuilder: (context, index) {
                      final student = record.students[index];
                      return ListTile(
                        dense: true,
                        leading: Icon(
                          student.isPresent ? Icons.check_circle : Icons.cancel,
                          color: student.isPresent ? AppColors.success : AppColors.error,
                        ),
                        title: Text(student.studentName),
                        trailing: Text(
                          student.isPresent ? 'Present' : 'Absent',
                          style: TextStyle(
                            color: student.isPresent ? AppColors.success : AppColors.error,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCountCard({
    required String title,
    required int count,
    required int total,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '$count',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            'out of $total',
            style: TextStyle(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Color _getAttendanceColor(double percentage) {
    if (percentage >= 75) {
      return AppColors.success;
    } else if (percentage >= 60) {
      return AppColors.warning;
    } else {
      return AppColors.error;
    }
  }
}
