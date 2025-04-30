import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme.dart';
import '../../../data/models/file_attachment_model.dart';
import '../../../providers/assignment_provider.dart';
import '../../common/app_button.dart';
import '../../common/app_text_field.dart';

class AssignmentSubmissionScreen extends StatefulWidget {
  final String assignmentId;
  
  const AssignmentSubmissionScreen({
    Key? key,
    required this.assignmentId,
  }) : super(key: key);

  @override
  State<AssignmentSubmissionScreen> createState() => _AssignmentSubmissionScreenState();
}

class _AssignmentSubmissionScreenState extends State<AssignmentSubmissionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _answerController = TextEditingController();
  bool _isSubmitting = false;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Load assignment details
      Provider.of<AssignmentProvider>(context, listen: false).getAssignmentById(widget.assignmentId);
    });
  }
  
  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }
  
  Future<void> _submitAssignment() async {
    if (_formKey.currentState?.validate() != true) {
      return;
    }
    
    setState(() {
      _isSubmitting = true;
    });
    
    try {
      final assignmentProvider = Provider.of<AssignmentProvider>(context, listen: false);
      final success = await assignmentProvider.submitAssignmentAnswer(
        widget.assignmentId,
        _answerController.text,
      );
      
      if (!mounted) return;
      
      setState(() {
        _isSubmitting = false;
      });
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Assignment submitted successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
        
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(assignmentProvider.error ?? 'Failed to submit assignment'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isSubmitting = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final assignmentProvider = Provider.of<AssignmentProvider>(context);
    final assignment = assignmentProvider.currentAssignment;
    final isLoading = assignmentProvider.isLoading;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assignment Submission'),
      ),
      body: isLoading || assignment == null
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Assignment title
                      Text(
                        assignment.title ?? 'Assignment',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      
                      const SizedBox(height: 8),
                      
                      // Course name
                      Text(
                        'Course: ${assignment.courseName ?? 'N/A'}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Assignment details card
                      Card(
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
                                  _buildDetailItem(
                                    context,
                                    icon: Icons.calendar_today,
                                    label: 'Due Date',
                                    value: assignment.dueDateFormatted,
                                  ),
                                  _buildDetailItem(
                                    context,
                                    icon: Icons.grade,
                                    label: 'Points',
                                    value: assignment.totalPoints?.toString() ?? 'N/A',
                                  ),
                                  _buildDetailItem(
                                    context,
                                    icon: Icons.attach_file,
                                    label: 'Attachments',
                                    value: assignment.attachments?.length.toString() ?? '0',
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Assignment description
                      Text(
                        'Instructions',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      
                      const SizedBox(height: 8),
                      
                      Text(
                        assignment.description ?? 'No instructions provided.',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Attachment list if any
                      if (assignment.attachments != null && assignment.attachments!.isNotEmpty) ...[
                        Text(
                          'Attachments',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        
                        const SizedBox(height: 8),
                        
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: assignment.attachments!.length,
                          itemBuilder: (context, index) {
                            final attachmentUrl = assignment.attachments![index];
                            final attachment = FileAttachment.fromUrl(attachmentUrl);
                            return ListTile(
                              leading: const Icon(Icons.insert_drive_file),
                              title: Text(attachment.fileName ?? 'File ${index + 1}'),
                              subtitle: Text(attachment.fileSize ?? 'Unknown size'),
                              trailing: IconButton(
                                icon: const Icon(Icons.download),
                                onPressed: () {
                                  // Download attachment
                                },
                              ),
                            );
                          },
                        ),
                        
                        const SizedBox(height: 24),
                      ],
                      
                      // Submission area
                      Text(
                        'Your Answer',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      
                      const SizedBox(height: 16),
                      
                      AppTextField(
                        label: 'Your Answer',
                        hint: 'Write your answer here...',
                        controller: _answerController,
                        maxLines: 10,
                        textCapitalization: TextCapitalization.sentences,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please provide an answer';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // File upload button
                      OutlinedButton.icon(
                        onPressed: () {
                          // Upload file logic
                        },
                        icon: const Icon(Icons.attach_file),
                        label: const Text('Attach Files'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Submit button
                      AppButton(
                        text: 'Submit Assignment',
                        onPressed: _submitAssignment,
                        isLoading: _isSubmitting,
                        isFullWidth: true,
                      ),
                      
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
  
  Widget _buildDetailItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: AppColors.primary,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}