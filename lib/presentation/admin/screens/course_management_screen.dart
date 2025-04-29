import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mentora/app_router.dart';
import 'package:mentora/core/constants/app_constants.dart';
import 'package:mentora/core/themes/app_theme.dart';
import 'package:mentora/core/widgets/app_text_field.dart';
import 'package:mentora/core/widgets/loading_indicator.dart';
import 'package:mentora/di/injection.dart';
import 'package:mentora/domain/entities/course.dart';
import 'package:mentora/presentation/admin/bloc/admin_dashboard_bloc.dart';
import 'package:mentora/presentation/admin/bloc/admin_dashboard_event.dart';
import 'package:mentora/presentation/admin/bloc/admin_dashboard_state.dart';
import 'package:mentora/presentation/common/widgets/error_widget.dart';

@RoutePage()
class CourseManagementScreen extends StatefulWidget {
  const CourseManagementScreen({Key? key}) : super(key: key);

  @override
  _CourseManagementScreenState createState() => _CourseManagementScreenState();
}

class _CourseManagementScreenState extends State<CourseManagementScreen> {
  late AdminDashboardBloc _dashboardBloc;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String? _selectedStatus;
  
  @override
  void initState() {
    super.initState();
    _dashboardBloc = getIt<AdminDashboardBloc>();
    _dashboardBloc.add(const LoadCoursesEvent());
    
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      final state = _dashboardBloc.state;
      if (state is CoursesLoaded && state.hasMorePages) {
        _dashboardBloc.add(LoadCoursesEvent(
          page: state.currentPage + 1,
          searchQuery: state.searchQuery,
          statusFilter: state.statusFilter,
        ));
      }
    }
  }

  void _search() {
    _dashboardBloc.add(LoadCoursesEvent(
      searchQuery: _searchController.text.isEmpty ? null : _searchController.text,
      statusFilter: _selectedStatus,
    ));
  }

  void _filterByStatus(String? status) {
    setState(() {
      _selectedStatus = status;
    });
    _dashboardBloc.add(LoadCoursesEvent(
      searchQuery: _searchController.text.isEmpty ? null : _searchController.text,
      statusFilter: status,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _dashboardBloc,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Course Management'),
          backgroundColor: AppTheme.adminColor,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: AppTextField(
                label: 'Search Courses',
                hint: 'Enter course name or keyword',
                controller: _searchController,
                prefixIcon: Icons.search,
                onSubmitted: (_) => _search(),
                suffixIcon: Icons.clear,
                onSuffixIconPressed: () {
                  _searchController.clear();
                  _search();
                },
              ),
            ),
          ),
        ),
        body: Column(
          children: [
            // Filter chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  FilterChip(
                    label: const Text('All'),
                    selected: _selectedStatus == null,
                    onSelected: (selected) {
                      if (selected) {
                        _filterByStatus(null);
                      }
                    },
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text('Active'),
                    selected: _selectedStatus == AppConstants.courseStatusActive,
                    onSelected: (selected) {
                      if (selected) {
                        _filterByStatus(AppConstants.courseStatusActive);
                      } else {
                        _filterByStatus(null);
                      }
                    },
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text('Upcoming'),
                    selected: _selectedStatus == AppConstants.courseStatusUpcoming,
                    onSelected: (selected) {
                      if (selected) {
                        _filterByStatus(AppConstants.courseStatusUpcoming);
                      } else {
                        _filterByStatus(null);
                      }
                    },
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text('Closed'),
                    selected: _selectedStatus == AppConstants.courseStatusClosed,
                    onSelected: (selected) {
                      if (selected) {
                        _filterByStatus(AppConstants.courseStatusClosed);
                      } else {
                        _filterByStatus(null);
                      }
                    },
                  ),
                ],
              ),
            ),
            
            // Course list
            Expanded(
              child: BlocConsumer<AdminDashboardBloc, AdminDashboardState>(
                listener: (context, state) {
                  if (state is CourseDeleted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: AppTheme.successColor,
                      ),
                    );
                    // Refresh the course list
                    _dashboardBloc.add(LoadCoursesEvent(
                      searchQuery: _searchController.text.isEmpty ? null : _searchController.text,
                      statusFilter: _selectedStatus,
                    ));
                  } else if (state is AdminDashboardError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: AppTheme.errorColor,
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  if (state is AdminDashboardLoading) {
                    return const LoadingIndicator(
                      message: 'Loading courses...',
                    );
                  } else if (state is CoursesLoaded) {
                    if (state.courses.isEmpty) {
                      return EmptyStateView(
                        title: 'No Courses Found',
                        message: 'Try adjusting your search or filters, or create a new course.',
                        icon: Icons.search_off,
                        actionText: 'Create Course',
                        onActionPressed: () {
                          context.router.push(const AddEditCourseRoute());
                        },
                      );
                    }
                    
                    return RefreshIndicator(
                      onRefresh: () async {
                        _dashboardBloc.add(LoadCoursesEvent(
                          searchQuery: _searchController.text.isEmpty ? null : _searchController.text,
                          statusFilter: _selectedStatus,
                        ));
                      },
                      child: ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: state.hasMorePages 
                            ? state.courses.length + 1 
                            : state.courses.length,
                        itemBuilder: (context, index) {
                          if (index >= state.courses.length) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }
                          
                          final course = state.courses[index];
                          return _buildCourseCard(context, course);
                        },
                      ),
                    );
                  } else if (state is AdminDashboardError) {
                    return ErrorView(
                      message: state.message,
                      onRetry: () {
                        _dashboardBloc.add(const LoadCoursesEvent());
                      },
                    );
                  }
                  
                  return const LoadingIndicator();
                },
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: AppTheme.adminColor,
          child: const Icon(Icons.add),
          onPressed: () {
            context.router.push(const AddEditCourseRoute());
          },
          tooltip: 'Create Course',
        ),
      ),
    );
  }

  Widget _buildCourseCard(BuildContext context, Course course) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    course.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(course.status).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    course.status.toUpperCase(),
                    style: TextStyle(
                      color: _getStatusColor(course.status),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            Text(
              course.description,
              style: const TextStyle(
                color: AppTheme.textSecondaryColor,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            
            const SizedBox(height: 16),
            
            // Course details
            Row(
              children: [
                _buildInfoBadge(
                  Icons.person,
                  course.instructorName ?? 'No instructor',
                  course.instructorName != null ? Colors.blue : AppTheme.errorColor,
                ),
                const SizedBox(width: 12),
                _buildInfoBadge(
                  Icons.people,
                  '${course.enrolledStudents}/${course.capacity}',
                  Colors.purple,
                ),
                const SizedBox(width: 12),
                _buildInfoBadge(
                  Icons.attach_money,
                  'PKR ${course.fee.toStringAsFixed(0)}',
                  Colors.green,
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit'),
                    onPressed: () {
                      context.router.push(AddEditCourseRoute(courseId: course.id));
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.adminColor,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.person_add),
                    label: const Text('Assign'),
                    onPressed: () {
                      context.router.push(AssignInstructorRoute(courseId: course.id));
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.blue,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.delete, color: AppTheme.errorColor),
                  onPressed: () {
                    _showDeleteConfirmation(context, course);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoBadge(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Course course) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Course'),
          content: Text('Are you sure you want to delete "${course.title}"? This action cannot be undone.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text(
                'Delete',
                style: TextStyle(color: AppTheme.errorColor),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                _dashboardBloc.add(DeleteCourseEvent(course.id));
              },
            ),
          ],
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case AppConstants.courseStatusActive:
        return AppTheme.successColor;
      case AppConstants.courseStatusClosed:
        return AppTheme.errorColor;
      case AppConstants.courseStatusUpcoming:
        return AppTheme.warningColor;
      default:
        return AppTheme.textSecondaryColor;
    }
  }
}
