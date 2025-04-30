import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme.dart';
import '../../../providers/course_provider.dart';
import '../../common/app_button.dart';
import '../../common/app_text_field.dart';

class PaymentScreen extends StatefulWidget {
  final String courseId;

  const PaymentScreen({
    Key? key,
    required this.courseId,
  }) : super(key: key);

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _expiryDateController = TextEditingController();
  final _cvvController = TextEditingController();
  final _nameOnCardController = TextEditingController();
  bool _saveCard = false;
  bool _isProcessing = false;
  bool _joinWaitlist = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Load course details
      Provider.of<CourseProvider>(context, listen: false)
          .getCourseById(widget.courseId);
    });
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryDateController.dispose();
    _cvvController.dispose();
    _nameOnCardController.dispose();
    super.dispose();
  }

  Future<void> _processPayment() async {
    if (_formKey.currentState?.validate() != true) {
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      final courseProvider =
          Provider.of<CourseProvider>(context, listen: false);

      // Check if joining waitlist instead of paying
      if (_joinWaitlist) {
        final success =
            await courseProvider.joinCourseWaitlist(widget.courseId);

        if (!mounted) return;

        setState(() {
          _isProcessing = false;
        });

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('You have been added to the waitlist!'),
              backgroundColor: AppColors.success,
            ),
          );

          Navigator.of(context).pop();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(courseProvider.error ?? 'Failed to join waitlist'),
              backgroundColor: AppColors.error,
            ),
          );
        }

        return;
      }

      // Process payment and enroll in course
      final paymentData = {
        'card_number': _cardNumberController.text.replaceAll(' ', ''),
        'expiry_date': _expiryDateController.text,
        'cvv': _cvvController.text,
        'name': _nameOnCardController.text,
        'save_card': _saveCard,
      };

      final success = await courseProvider.enrollCourseWithPayment(
          widget.courseId, paymentData);

      if (!mounted) return;

      setState(() {
        _isProcessing = false;
      });

      if (success) {
        // Show success dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => _buildSuccessDialog(context),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                courseProvider.error ?? 'Payment failed. Please try again.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
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
    final courseProvider = Provider.of<CourseProvider>(context);
    final course = courseProvider.currentCourse;
    final isLoading = courseProvider.isLoading;

    // Check if course is full
    final bool isFull = course?.currentEnrollment != null &&
        course?.maxCapacity != null &&
        course!.currentEnrollment! >= course.maxCapacity!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
      ),
      body: isLoading || course == null
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Course summary card
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Enrollment Summary',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 16),
                            _buildSummaryRow(
                              context,
                              label: 'Course',
                              value: course.title,
                            ),
                            const Divider(),
                            _buildSummaryRow(
                              context,
                              label: 'Instructor',
                              value: course.instructorName ?? 'TBD',
                            ),
                            const Divider(),
                            _buildSummaryRow(
                              context,
                              label: 'Duration',
                              value: course.duration ?? 'Unknown',
                            ),
                            const Divider(),
                            _buildSummaryRow(
                              context,
                              label: 'Starts On',
                              value: course.startDate != null
                                  ? '${course.startDate!.day}/${course.startDate!.month}/${course.startDate!.year}'
                                  : 'TBD',
                            ),
                            const Divider(),
                            _buildSummaryRow(
                              context,
                              label: 'Fee',
                              value: 'Rs. ${course.fee?.toString() ?? '0'}',
                              valueStyle: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                            ),
                            if (isFull) ...[
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.warning.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: AppColors.warning),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.warning_amber_rounded,
                                      color: AppColors.warning,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'This course is full. You can join the waitlist and we\'ll notify you when a spot becomes available.',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              color: AppColors.textPrimary,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              SwitchListTile(
                                title: const Text('Join Waitlist Instead'),
                                value: _joinWaitlist,
                                onChanged: (value) {
                                  setState(() {
                                    _joinWaitlist = value;
                                  });
                                },
                                activeColor: AppColors.primary,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Payment form
                    if (!_joinWaitlist) ...[
                      Text(
                        'Payment Details',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            AppTextField(
                              label: 'Card Number',
                              hint: '1234 5678 9012 3456',
                              controller: _cardNumberController,
                              keyboardType: TextInputType.number,
                              prefixIcon: const Icon(Icons.credit_card),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter card number';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: AppTextField(
                                    label: 'Expiry Date',
                                    hint: 'MM/YY',
                                    controller: _expiryDateController,
                                    keyboardType: TextInputType.datetime,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Required';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: AppTextField(
                                    label: 'CVV',
                                    hint: '123',
                                    controller: _cvvController,
                                    keyboardType: TextInputType.number,
                                    maxLength: 3,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Required';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            AppTextField(
                              label: 'Name on Card',
                              hint: 'John Doe',
                              controller: _nameOnCardController,
                              textCapitalization: TextCapitalization.words,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter name on card';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 8),
                            CheckboxListTile(
                              title:
                                  const Text('Save card for future payments'),
                              value: _saveCard,
                              onChanged: (value) {
                                setState(() {
                                  _saveCard = value ?? false;
                                });
                              },
                              controlAffinity: ListTileControlAffinity.leading,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 32),

                    // Payment button
                    AppButton(
                      text: _joinWaitlist
                          ? 'Join Waitlist'
                          : 'Pay Rs. ${course.fee?.toString() ?? '0'}',
                      type: ButtonType.primary,
                      isLoading: _isProcessing,
                      isFullWidth: true,
                      onPressed: _processPayment,
                    ),

                    const SizedBox(height: 24),

                    if (!_joinWaitlist) ...[
                      Center(
                        child: Column(
                          children: [
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.lock,
                                  size: 16,
                                  color: AppColors.textSecondary,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'Secure Payment',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Your payment information is secure. We use industry-standard encryption to protect your data.',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSummaryRow(
    BuildContext context, {
    required String label,
    required String value,
    TextStyle? valueStyle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          Text(
            value,
            style: valueStyle ??
                Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessDialog(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle,
              color: AppColors.success,
              size: 64,
            ),
            const SizedBox(height: 24),
            Text(
              'Payment Successful!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'You have successfully enrolled in the course. You can now access all course materials.',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            AppButton(
              text: 'Start Learning',
              type: ButtonType.primary,
              isFullWidth: true,
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop(); // Go back to previous screen
              },
            ),
          ],
        ),
      ),
    );
  }
}
