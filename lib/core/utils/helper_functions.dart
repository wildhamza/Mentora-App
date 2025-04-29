import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HelperFunctions {
  // Date formatting
  static String formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }
  
  static String formatDateTime(DateTime date) {
    return DateFormat('yyyy-MM-dd HH:mm').format(date);
  }
  
  static String formatTime(DateTime time) {
    return DateFormat('HH:mm').format(time);
  }
  
  static String formatDateForDisplay(DateTime date) {
    return DateFormat.yMMMMd().format(date);
  }
  
  static String formatTimeForDisplay(DateTime time) {
    return DateFormat.jm().format(time);
  }
  
  // Currency formatting
  static String formatCurrency(double amount) {
    return NumberFormat.currency(symbol: 'PKR ', decimalDigits: 0).format(amount);
  }
  
  // File size formatting
  static String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      double kb = bytes / 1024;
      return '${kb.toStringAsFixed(1)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      double mb = bytes / (1024 * 1024);
      return '${mb.toStringAsFixed(1)} MB';
    } else {
      double gb = bytes / (1024 * 1024 * 1024);
      return '${gb.toStringAsFixed(1)} GB';
    }
  }
  
  // Email validation
  static bool isValidEmail(String email) {
    final emailRegExp = RegExp(r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+');
    return emailRegExp.hasMatch(email);
  }
  
  // Password validation
  static bool isValidPassword(String password) {
    return password.length >= 6;
  }
  
  // Show snackbar
  static void showSnackBar(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }
  
  // Show loading dialog
  static void showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
  
  // File extension from path
  static String getFileExtension(String path) {
    return path.split('.').last.toLowerCase();
  }
  
  // Check if file is image
  static bool isImageFile(String path) {
    final extension = getFileExtension(path);
    return ['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(extension);
  }
  
  // Check if file is document
  static bool isDocumentFile(String path) {
    final extension = getFileExtension(path);
    return ['pdf', 'doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx', 'txt'].contains(extension);
  }
  
  // Get icon for file type
  static IconData getFileTypeIcon(String path) {
    final extension = getFileExtension(path);
    
    if (isImageFile(path)) {
      return Icons.image;
    } else if (['pdf'].contains(extension)) {
      return Icons.picture_as_pdf;
    } else if (['doc', 'docx', 'txt'].contains(extension)) {
      return Icons.description;
    } else if (['xls', 'xlsx'].contains(extension)) {
      return Icons.table_chart;
    } else if (['ppt', 'pptx'].contains(extension)) {
      return Icons.slideshow;
    } else if (['mp4', 'mov', 'avi'].contains(extension)) {
      return Icons.video_library;
    } else {
      return Icons.insert_drive_file;
    }
  }
  
  // Get abbreviated name (e.g., John Doe -> JD)
  static String getInitials(String fullName) {
    if (fullName.isEmpty) return '';
    
    List<String> nameParts = fullName.split(' ');
    if (nameParts.length > 1) {
      return '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase();
    } else {
      return nameParts[0][0].toUpperCase();
    }
  }
  
  // Format duration (e.g., 90 -> "1h 30m")
  static String formatDuration(int minutes) {
    int hours = minutes ~/ 60;
    int remainingMinutes = minutes % 60;
    
    if (hours > 0) {
      return '${hours}h ${remainingMinutes}m';
    } else {
      return '${remainingMinutes}m';
    }
  }
  
  // Get contrasting text color based on background color
  static Color getContrastingTextColor(Color backgroundColor) {
    return backgroundColor.computeLuminance() > 0.5 ? Colors.black : Colors.white;
  }
}
