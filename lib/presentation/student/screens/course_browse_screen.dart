import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/routes.dart';
import '../../../core/theme.dart';
import '../../../providers/course_provider.dart';
import '../../common/loading_widget.dart';
import '../../common/error_widget.dart';
import '../../common/course_card.dart';

class CourseBrowseScreen extends StatefulWidget {
  const CourseBrowseScreen({Key? key}) : super(key: key);

  @override
  State<CourseBrowseScreen> createState() => _CourseBrowseScreenState();
}

class _CourseBrowseScreenState extends State<CourseBrowseScreen> {
  late final CourseProvider _courseProvider;
  bool _isLoading = false;
  String _searchQuery = '';
  final List<String> _selectedCategories = [];
  RangeValues _priceRange = const RangeValues(0, 10000);

  @override
  void initState() {
    super.initState();
    _courseProvider = Provider.of<CourseProvider>(context, listen: false);
    _loadCourses();
  }

  Future<void> _loadCourses() async {
    setState(() {
      _isLoading = true;
    });

    // Fetch all available courses (that have enrollment open)
    await _courseProvider.fetchAllCourses(filters: {'enrollment_open': true});

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _refreshCourses() async {
    return _loadCourses();
  }

  List<dynamic> _getFilteredCourses() {
    return _courseProvider.courses.where((course) {
      // Apply search filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final title = course.title.toLowerCase();
        final description = course.description.toLowerCase();
        final instructorName = (course.instructorName ?? '').toLowerCase();

        if (!title.contains(query) &&
            !description.contains(query) &&
            !instructorName.contains(query)) {
          return false;
        }
      }

      // Apply price filter
      if (course.fees < _priceRange.start || course.fees > _priceRange.end) {
        return false;
      }

      // Apply category filter (mock categories for demonstration)
      if (_selectedCategories.isNotEmpty) {
        // In a real app, courses would have categories
        // Here we're just filtering based on an imaginary category assignment
        final mockCategories = [
          'Programming',
          'Mathematics',
          'Science',
          'Language',
          'Arts',
        ];

        final courseIndex = course.id % mockCategories.length;
        final courseCategory = mockCategories[courseIndex];

        if (!_selectedCategories.contains(courseCategory)) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  void _showFilterDialog() {
    // Mock categories for demonstration
    final categories = [
      'Programming',
      'Mathematics',
      'Science',
      'Language',
      'Arts',
    ];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Filter Courses'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Price Range',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    RangeSlider(
                      values: _priceRange,
                      min: 0,
                      max: 10000,
                      divisions: 20,
                      labels: RangeLabels(
                        'Rs. ${_priceRange.start.round()}',
                        'Rs. ${_priceRange.end.round()}',
                      ),
                      onChanged: (RangeValues values) {
                        setState(() {
                          _priceRange = values;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Categories',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children:
                          categories.map((category) {
                            final isSelected = _selectedCategories.contains(
                              category,
                            );
                            return FilterChip(
                              label: Text(category),
                              selected: isSelected,
                              onSelected: (selected) {
                                setState(() {
                                  if (selected) {
                                    _selectedCategories.add(category);
                                  } else {
                                    _selectedCategories.remove(category);
                                  }
                                });
                              },
                              backgroundColor: Colors.white,
                              selectedColor: AppColors.primary.withOpacity(0.1),
                              checkmarkColor: AppColors.primary,
                            );
                          }).toList(),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    // Reset filters
                    this.setState(() {
                      _selectedCategories.clear();
                      _priceRange = const RangeValues(0, 10000);
                    });
                    Navigator.of(context).pop();
                  },
                  child: const Text('Reset'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    this.setState(() {});
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Apply'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Browse Courses'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
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
          ),

          // Filter chips
          if (_selectedCategories.isNotEmpty ||
              _priceRange != const RangeValues(0, 10000))
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Text(
                    'Active Filters:',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(width: 8),
                  if (_priceRange != const RangeValues(0, 10000))
                    Chip(
                      label: Text(
                        'Rs. ${_priceRange.start.round()} - ${_priceRange.end.round()}',
                      ),
                      onDeleted: () {
                        setState(() {
                          _priceRange = const RangeValues(0, 10000);
                        });
                      },
                    ),
                  const SizedBox(width: 4),
                  if (_selectedCategories.isNotEmpty)
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children:
                              _selectedCategories.map((category) {
                                return Padding(
                                  padding: const EdgeInsets.only(right: 4),
                                  child: Chip(
                                    label: Text(category),
                                    onDeleted: () {
                                      setState(() {
                                        _selectedCategories.remove(category);
                                      });
                                    },
                                  ),
                                );
                              }).toList(),
                        ),
                      ),
                    ),
                ],
              ),
            ),

          // Course list
          Expanded(
            child:
                _isLoading
                    ? const LoadingWidget(message: 'Loading courses...')
                    : Consumer<CourseProvider>(
                      builder: (context, courseProvider, child) {
                        if (courseProvider.error != null) {
                          return AppErrorWidget(
                            message: courseProvider.error!,
                            onRetry: _refreshCourses,
                          );
                        }

                        final filteredCourses = _getFilteredCourses();

                        if (filteredCourses.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.search_off,
                                  size: 64,
                                  color: AppColors.textHint,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No courses match your filters',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextButton.icon(
                                  onPressed: () {
                                    setState(() {
                                      _searchQuery = '';
                                      _selectedCategories.clear();
                                      _priceRange = const RangeValues(0, 10000);
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
                          onRefresh: _refreshCourses,
                          child: GridView.builder(
                            padding: const EdgeInsets.all(16),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 1,
                                  childAspectRatio: 1.3,
                                  mainAxisSpacing: 16,
                                ),
                            itemCount: filteredCourses.length,
                            itemBuilder: (context, index) {
                              final course = filteredCourses[index];
                              return CourseCard(
                                course: course,
                                showEnrollButton: true,
                                onTap: () {
                                  // View course details
                                },
                                onEnrollTap: () {
                                  Navigator.of(context).pushNamed(
                                    Routes.payment,
                                    arguments: {'courseId': course.id},
                                  );
                                },
                              );
                            },
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}
