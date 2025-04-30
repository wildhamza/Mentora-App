import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../data/models/course_model.dart';
import 'package:intl/intl.dart';

class CourseCard extends StatelessWidget {
  final CourseModel course;
  final VoidCallback? onTap;
  final bool showEnrollButton;
  final VoidCallback? onEnrollTap;
  final bool showInstructorName;
  
  const CourseCard({
    Key? key,
    required this.course,
    this.onTap,
    this.showEnrollButton = false,
    this.onEnrollTap,
    this.showInstructorName = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Course thumbnail or placeholder
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              child: course.thumbnail != null
                  ? Image.network(
                      course.thumbnail!,
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildPlaceholder();
                      },
                    )
                  : _buildPlaceholder(),
            ),
            
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    course.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 4),
                  
                  // Description
                  Text(
                    course.description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Fees
                  Text(
                    'Rs. ${course.fees.toStringAsFixed(0)}',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Instructor (if available and should be shown)
                  if (showInstructorName && course.instructorName != null)
                    Row(
                      children: [
                        const Icon(
                          Icons.person,
                          size: 16,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          course.instructorName!,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  
                  // Dates (if available)
                  if (course.startDate != null && course.endDate != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            size: 16,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${DateFormat('MMM d').format(course.startDate!)} - ${DateFormat('MMM d, y').format(course.endDate!)}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  
                  // Capacity and enrollment
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.group,
                          size: 16,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${course.enrolledCount}/${course.capacity} students',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        
                        const Spacer(),
                        
                        // Enrollment status badge
                        _buildStatusBadge(context),
                      ],
                    ),
                  ),
                  
                  // Enroll button (if enabled)
                  if (showEnrollButton && course.isEnrollmentOpen)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: course.isFull ? null : onEnrollTap,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: AppColors.textHint,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                          child: Text(course.isFull ? 'Join Waitlist' : 'Enroll Now'),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPlaceholder() {
    return Container(
      height: 120,
      width: double.infinity,
      color: AppColors.primaryLight.withOpacity(0.2),
      child: Center(
        child: Icon(
          Icons.school,
          size: 48,
          color: AppColors.primary.withOpacity(0.5),
        ),
      ),
    );
  }
  
  Widget _buildStatusBadge(BuildContext context) {
    if (!course.isEnrollmentOpen) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.textHint,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          'Closed',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.white,
          ),
        ),
      );
    }
    
    if (course.isFull) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.warning,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          'Full',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.white,
          ),
        ),
      );
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.success,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        'Open',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Colors.white,
        ),
      ),
    );
  }
}
