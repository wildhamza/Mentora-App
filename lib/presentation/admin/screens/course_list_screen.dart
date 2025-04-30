import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/routes.dart';
import '../../../core/theme.dart';
import '../../../providers/course_provider.dart';
import '../../common/loading_widget.dart';
import '../../common/error_widget.dart';

class CourseListScreen extends StatefulWidget {
  const CourseListScreen({Key? key}) : super(key: key);

  @override
  State<CourseListScreen> createState() => _CourseListScreenState();
}

class _CourseListScreenState extends State<CourseListScreen> {
  late final CourseProvider _courseProvider;
  String _searchQuery = '';
  bool _showOnlyActive = false;

  @override
  void initState() {
    super.initState();
    _courseProvider = Provider.of<CourseProvider>(context, listen: false);
    _loadCourses();
  }

  Future<void> _loadCourses() async {
    await _courseProvider.fetchAllCourses();
  }

  List<dynamic> _getFilteredCourses() {
    final courses = _courseProvider.courses;

    return courses.where((course) {
      // Apply active filter if needed
      if (_showOnlyActive && !course.isEnrollmentOpen) {
        return false;
      }

      // Apply search query if present
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final title = course.title.toLowerCase();
        final description = course.description.toLowerCase();
        final instructorName = (course.instructorName ?? '').toLowerCase();

        return title.contains(query) ||
            description.contains(query) ||
            instructorName.contains(query);
      }

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Course Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).pushNamed(Routes.addEditCourse);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and filter bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search courses',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: FilterChip(
                        label: const Text('Active Courses Only'),
                        selected: _showOnlyActive,
                        onSelected: (selected) {
                          setState(() {
                            _showOnlyActive = selected;
                          });
                        },
                        backgroundColor: Colors.white,
                        selectedColor: AppColors.primary.withOpacity(0.1),
                        checkmarkColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(
                            color:
                                _showOnlyActive
                                    ? AppColors.primary
                                    : AppColors.textHint.withOpacity(0.5),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Course list
          Expanded(
            child: Consumer<CourseProvider>(
              builder: (context, courseProvider, child) {
                if (courseProvider.isLoading) {
                  return const LoadingWidget(message: 'Loading courses...');
                }

                if (courseProvider.error != null) {
                  return AppErrorWidget(
                    message: courseProvider.error!,
                    onRetry: _loadCourses,
                  );
                }

                final filteredCourses = _getFilteredCourses();

                if (filteredCourses.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.menu_book,
                          size: 64,
                          color: AppColors.textHint,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isNotEmpty || _showOnlyActive
                              ? 'No courses match your filters'
                              : 'No courses available',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(color: AppColors.textSecondary),
                          textAlign: TextAlign.center,
                        ),
                        if (_searchQuery.isNotEmpty || _showOnlyActive)
                          TextButton.icon(
                            onPressed: () {
                              setState(() {
                                _searchQuery = '';
                                _showOnlyActive = false;
                              });
                            },
                            icon: const Icon(Icons.filter_alt_off),
                            label: const Text('Clear Filters'),
                          ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: _loadCourses,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    itemCount: filteredCourses.length,
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) {
                      final course = filteredCourses[index];
                      return _buildCourseListItem(course);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed(Routes.addEditCourse);
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCourseListItem(course) {
    return Dismissible(
      key: Key('course-${course.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        color: AppColors.error,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('Delete Course'),
                content: Text(
                  'Are you sure you want to delete "${course.title}"?',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('Delete'),
                  ),
                ],
              ),
        );
      },
      onDismissed: (direction) async {
        final result = await _courseProvider.deleteCourse(course.id);
        if (!result) {
          // Show error if deletion failed
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  _courseProvider.error ?? 'Failed to delete course',
                ),
                backgroundColor: AppColors.error,
              ),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Course "${course.title}" deleted'),
                action: SnackBarAction(
                  label: 'Undo',
                  onPressed: () {
                    // Refresh to show all courses again
                    _loadCourses();
                  },
                ),
              ),
            );
          }
        }
      },
      child: Card(
        margin: EdgeInsets.zero,
        elevation: 0,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 4,
          ),
          leading: Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                course.title.substring(0, 1).toUpperCase(),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          title: Text(
            course.title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                course.hasInstructor
                    ? 'Instructor: ${course.instructorName}'
                    : 'No instructor assigned',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color:
                          course.isEnrollmentOpen
                              ? AppColors.success
                              : AppColors.textHint,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      course.isEnrollmentOpen ? 'Open' : 'Closed',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${course.enrolledCount}/${course.capacity} students',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.person_add, size: 20),
                onPressed: () {
                  Navigator.of(context).pushNamed(
                    Routes.assignInstructor,
                    arguments: {'courseId': course.id},
                  );
                },
                tooltip: 'Assign Instructor',
              ),
              IconButton(
                icon: const Icon(Icons.edit, size: 20),
                onPressed: () {
                  Navigator.of(context).pushNamed(
                    Routes.addEditCourse,
                    arguments: {'courseId': course.id},
                  );
                },
                tooltip: 'Edit Course',
              ),
            ],
          ),
          onTap: () {
            Navigator.of(context).pushNamed(
              Routes.addEditCourse,
              arguments: {'courseId': course.id},
            );
          },
        ),
      ),
    );
  }
}
