import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:mentora/app_router.dart';
import 'package:mentora/core/constants/app_constants.dart';
import 'package:mentora/core/themes/app_theme.dart';
import 'package:mentora/core/widgets/app_button.dart';
import 'package:mentora/core/widgets/app_text_field.dart';
import 'package:mentora/core/widgets/loading_indicator.dart';
import 'package:mentora/di/injection.dart';
import 'package:mentora/presentation/student/bloc/student_dashboard_bloc.dart';
import 'package:mentora/presentation/student/bloc/student_dashboard_event.dart';
import 'package:mentora/presentation/student/bloc/student_dashboard_state.dart';

@RoutePage()
class PaymentScreen extends StatefulWidget {
  final int courseId;
  final double courseFee;

  const PaymentScreen({
    Key? key,
    @QueryParam('courseId') required this.courseId,
    @QueryParam('courseFee') required this.courseFee,
  }) : super(key: key);

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _expiryDateController = TextEditingController();
  final _cvvController = TextEditingController();
  final _nameOnCardController = TextEditingController();
  late StudentDashboardBloc _dashboardBloc;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _dashboardBloc = getIt<StudentDashboardBloc>();
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryDateController.dispose();
    _cvvController.dispose();
    _nameOnCardController.dispose();
    super.dispose();
  }

  void _processPayment() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      
      // In a real implementation, this would invoke the Stripe SDK
      // to create a payment intent and confirm the payment
      
      // For now, we're simulating a successful payment
      Future.delayed(const Duration(seconds: 2), () {
        // This would be returned from the Stripe payment intent creation
        const String paymentIntentId = 'pi_simulated_intent_123456';
        
        _dashboardBloc.add(EnrollInCourseEvent(
          courseId: widget.courseId,
          paymentIntentId: paymentIntentId,
        ));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _dashboardBloc,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Payment'),
        ),
        body: BlocConsumer<StudentDashboardBloc, StudentDashboardState>(
          listener: (context, state) {
            setState(() {
              _isLoading = state is StudentDashboardLoading;
            });
            
            if (state is EnrollmentSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppTheme.successColor,
                ),
              );
              
              // Navigate back to dashboard after successful enrollment
              context.router.navigate(const StudentDashboardRoute());
            } else if (state is StudentDashboardError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppTheme.errorColor,
                ),
              );
            }
          },
          builder: (context, state) {
            return LoadingOverlay(
              isLoading: _isLoading,
              loadingMessage: 'Processing payment...',
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Payment summary card
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Payment Summary',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Course Fee:'),
                                  Text(
                                    'PKR ${widget.courseFee.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              const Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Taxes:'),
                                  Text(
                                    'PKR 0.00',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(height: 24),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Total:',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'PKR ${widget.courseFee.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: AppTheme.primaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Payment method section
                      const Text(
                        'Payment Details',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Card number field
                      AppTextField(
                        label: 'Card Number',
                        hint: '1234 5678 9012 3456',
                        controller: _cardNumberController,
                        keyboardType: TextInputType.number,
                        prefixIcon: Icons.credit_card,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(16),
                          _CardNumberFormatter(),
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter card number';
                          }
                          if (value.replaceAll(' ', '').length < 16) {
                            return 'Please enter a valid card number';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Row for expiry date and CVV
                      Row(
                        children: [
                          // Expiry date field
                          Expanded(
                            child: AppTextField(
                              label: 'Expiry Date',
                              hint: 'MM/YY',
                              controller: _expiryDateController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(4),
                                _ExpiryDateFormatter(),
                              ],
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Required';
                                }
                                if (value.length < 5) {
                                  return 'Invalid date';
                                }
                                return null;
                              },
                            ),
                          ),
                          
                          const SizedBox(width: 16),
                          
                          // CVV field
                          Expanded(
                            child: AppTextField(
                              label: 'CVV',
                              hint: '123',
                              controller: _cvvController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(3),
                              ],
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Required';
                                }
                                if (value.length < 3) {
                                  return 'Invalid CVV';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Name on card field
                      AppTextField(
                        label: 'Name on Card',
                        hint: 'John Doe',
                        controller: _nameOnCardController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter name on card';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Pay button
                      AppButton(
                        text: 'Pay PKR ${widget.courseFee.toStringAsFixed(0)}',
                        onPressed: _processPayment,
                        isLoading: _isLoading,
                        isFullWidth: true,
                        size: AppButtonSize.large,
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Secure payment message
                      Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(
                              Icons.lock,
                              size: 16,
                              color: AppTheme.textSecondaryColor,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Secure payment powered by Stripe',
                              style: TextStyle(
                                color: AppTheme.textSecondaryColor,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// Custom formatters for credit card input
class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue;
    }
    
    final String text = newValue.text.replaceAll(' ', '');
    final StringBuffer buffer = StringBuffer();
    
    for (int i = 0; i < text.length; i++) {
      if (i > 0 && i % 4 == 0) {
        buffer.write(' ');
      }
      buffer.write(text[i]);
    }
    
    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}

class _ExpiryDateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue;
    }
    
    final String text = newValue.text.replaceAll('/', '');
    final StringBuffer buffer = StringBuffer();
    
    for (int i = 0; i < text.length; i++) {
      if (i == 2) {
        buffer.write('/');
      }
      buffer.write(text[i]);
    }
    
    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}
