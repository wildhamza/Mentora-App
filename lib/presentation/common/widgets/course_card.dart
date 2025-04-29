import 'package:flutter/material.dart';
import 'package:mentora/core/constants/app_constants.dart';
import 'package:mentora/core/themes/app_theme.dart';
import 'package:mentora/domain/entities/course.dart';

class CourseCard extends StatelessWidget {
  final Course course;
  final VoidCallback onTap;
  final bool showDetails;
  final bool showEnrollButton;
  final VoidCallback? onEnrollTap;

  const CourseCard({
    Key? key,
    required this.course,
    required this.onTap,
    this.showDetails = true,
    this.showEnrollButton = false,
    this.onEnrollTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Course image/banner
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              child: Container(
                height: 140,
                width: double.infinity,
                color: AppTheme.primaryColor.withOpacity(0.8),
                child: course.thumbnailUrl != null && course.thumbnailUrl!.isNotEmpty
                    ? Image.network(
                        course.thumbnailUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildPlaceholderImage();
                        },
                      )
                    : _buildPlaceholderImage(),
              ),
            ),
            
            // Course content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    course.title,
                    style: Theme.of(context).textTheme.titleLarge,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Status indicator
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor().withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      course.status.toUpperCase(),
                      style: TextStyle(
                        color: _getStatusColor(),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  
                  if (showDetails) ...[
                    const SizedBox(height: 12),
                    
                    // Instructor
                    if (course.instructorName != null && course.instructorName!.isNotEmpty)
                      _buildInfoRow(
                        Icons.person,
                        'Instructor: ${course.instructorName}',
                      ),
                    
                    const SizedBox(height: 8),
                    
                    // Duration
                    _buildInfoRow(
                      Icons.calendar_today,
                      'Duration: ${course.duration} days',
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Fee
                    _buildInfoRow(
                      Icons.attach_money,
                      'Fee: PKR ${course.fee.toStringAsFixed(0)}',
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Enrollment
                    _buildInfoRow(
                      Icons.people,
                      'Enrolled: ${course.enrolledStudents}/${course.capacity}',
                    ),
                  ],
                  
                  if (showEnrollButton && course.isEnrollmentOpen) ...[
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: onEnrollTap,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Enroll Now'),
                      ),
                    ),
                  ] else if (showEnrollButton && course.isFull) ...[
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: onEnrollTap,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Join Waitlist'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.school,
            size: 48,
            color: Colors.white.withOpacity(0.8),
          ),
          const SizedBox(height: 8),
          Text(
            course.title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: AppTheme.textSecondaryColor,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: AppTheme.textSecondaryColor,
              fontSize: 14,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor() {
    switch (course.status) {
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
