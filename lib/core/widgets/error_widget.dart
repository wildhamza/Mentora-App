import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'custom_button.dart';

class AppErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final IconData? icon;

  const AppErrorWidget({
    Key? key,
    required this.message,
    this.onRetry,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon ?? Icons.error_outline,
              size: 64,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: AppTheme.spacingMedium),
            Text(
              message,
              style: TextStyle(
                fontSize: AppTheme.fontSizeMedium,
                color: theme.textTheme.bodyLarge?.color,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppTheme.spacingLarge),
              SecondaryButton(
                text: 'Retry',
                icon: Icons.refresh,
                onPressed: onRetry!,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class NetworkErrorWidget extends StatelessWidget {
  final VoidCallback onRetry;

  const NetworkErrorWidget({
    Key? key,
    required this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppErrorWidget(
      message: 'Network error. Please check your internet connection and try again.',
      icon: Icons.wifi_off,
      onRetry: onRetry,
    );
  }
}

class ServerErrorWidget extends StatelessWidget {
  final VoidCallback onRetry;

  const ServerErrorWidget({
    Key? key,
    required this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppErrorWidget(
      message: 'Server error. Please try again later.',
      icon: Icons.cloud_off,
      onRetry: onRetry,
    );
  }
}

class EmptyStateWidget extends StatelessWidget {
  final String message;
  final IconData icon;
  final VoidCallback? onAction;
  final String? actionLabel;

  const EmptyStateWidget({
    Key? key,
    required this.message,
    this.icon = Icons.inbox,
    this.onAction,
    this.actionLabel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 64,
              color: theme.dividerColor,
            ),
            const SizedBox(height: AppTheme.spacingMedium),
            Text(
              message,
              style: TextStyle(
                fontSize: AppTheme.fontSizeMedium,
                color: theme.textTheme.bodyLarge?.color,
              ),
              textAlign: TextAlign.center,
            ),
            if (onAction != null && actionLabel != null) ...[
              const SizedBox(height: AppTheme.spacingLarge),
              SecondaryButton(
                text: actionLabel!,
                onPressed: onAction!,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class NoCoursesWidget extends StatelessWidget {
  final VoidCallback? onBrowseCourses;

  const NoCoursesWidget({
    Key? key,
    this.onBrowseCourses,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      message: 'You are not enrolled in any courses yet.',
      icon: Icons.school,
      onAction: onBrowseCourses,
      actionLabel: 'Browse Courses',
    );
  }
}

class NoAssignmentsWidget extends StatelessWidget {
  const NoAssignmentsWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const EmptyStateWidget(
      message: 'No assignments available at the moment.',
      icon: Icons.assignment,
    );
  }
}

class NoQuizzesWidget extends StatelessWidget {
  const NoQuizzesWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const EmptyStateWidget(
      message: 'No quizzes available at the moment.',
      icon: Icons.quiz,
    );
  }
}

class NoMaterialsWidget extends StatelessWidget {
  const NoMaterialsWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const EmptyStateWidget(
      message: 'No learning materials available for this course.',
      icon: Icons.book,
    );
  }
}
