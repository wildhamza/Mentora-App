import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants.dart';
import '../../../core/theme.dart';
import '../../../providers/course_provider.dart';
import '../../common/app_button.dart';

class CourseBrowseScreen extends StatefulWidget {
  const CourseBrowseScreen({Key? key}) : super(key: key);

  @override
  State<CourseBrowseScreen> createState() => _CourseBrowseScreenState();
}

class _CourseBrowseScreenState extends State<CourseBrowseScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Load available courses
      Provider.of<CourseProvider>(context, listen: false).getAvailableCourses();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final courseProvider = Provider.of<CourseProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Browse Courses'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search bar
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search courses...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                            });
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
              
              const SizedBox(height: 24),
              
              // Filter chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip('All', true),
                    _buildFilterChip('Popular', false),
                    _buildFilterChip('New', false),
                    _buildFilterChip('Computer Science', false),
                    _buildFilterChip('Mathematics', false),
                    _buildFilterChip('English', false),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Available courses
              Text(
                'Available Courses',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              
              const SizedBox(height: 16),
              
              // Course list
              Expanded(
                child: courseProvider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : courseProvider.availableCourses.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.school_outlined,
                                  size: 64,
                                  color: AppColors.textSecondary,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No courses available at the moment',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: courseProvider.availableCourses.length,
                            itemBuilder: (context, index) {
                              final course = courseProvider.availableCourses[index];
                              // Filter by search query if needed
                              if (_searchQuery.isNotEmpty &&
                                  !(course.title?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false)) {
                                return const SizedBox.shrink();
                              }
                              return _buildCourseCard(context, course);
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (value) {
          // Apply filter logic
        },
        backgroundColor: Colors.white,
        selectedColor: AppColors.primaryLight,
        checkmarkColor: AppColors.primary,
      ),
    );
  }

  Widget _buildCourseCard(BuildContext context, dynamic course) {
    // This should use the actual Course model
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
            Text(
              course.title ?? 'Course Name',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              course.description ?? 'Course description goes here',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                // Course details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow(
                        context, 
                        icon: Icons.person,
                        text: 'Instructor: ${course.instructorName ?? 'TBD'}',
                      ),
                      const SizedBox(height: 4),
                      _buildDetailRow(
                        context, 
                        icon: Icons.calendar_today,
                        text: 'Duration: ${course.duration ?? '8 weeks'}',
                      ),
                      const SizedBox(height: 4),
                      _buildDetailRow(
                        context, 
                        icon: Icons.attach_money,
                        text: 'Fee: Rs. ${course.fee?.toString() ?? '5000'}',
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Enroll button
                AppButton(
                  text: 'Enroll Now',
                  type: ButtonType.primary,
                  onPressed: () {
                    // Navigate to payment screen
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context, {
    required IconData icon,
    required String text,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}