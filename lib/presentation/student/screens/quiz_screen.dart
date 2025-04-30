import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme.dart';
import '../../../providers/quiz_provider.dart';
import '../../common/app_button.dart';

class QuizScreen extends StatefulWidget {
  final String quizId;

  const QuizScreen({
    Key? key,
    required this.quizId,
  }) : super(key: key);

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentQuestionIndex = 0;
  Map<int, int> _selectedAnswers = {};
  bool _isSubmitting = false;
  bool _quizSubmitted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Load quiz details
      Provider.of<QuizProvider>(context, listen: false)
          .getQuizById(widget.quizId);
    });
  }

  Future<void> _submitQuiz() async {
    final quizProvider = Provider.of<QuizProvider>(context, listen: false);
    final quiz = quizProvider.currentQuiz;

    if (quiz == null || quiz.questions.isEmpty) {
      return;
    }

    // Check if all questions are answered
    if (_selectedAnswers.length < quiz.questions.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please answer all questions before submitting'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final answers = _selectedAnswers.map((questionIndex, answerIndex) {
        final questionId = quiz.questions[questionIndex].id;
        return MapEntry(questionId, answerIndex);
      });

      final success = await quizProvider.submitQuizWithAnswerMap(
        widget.quizId,
        answers,
      );

      if (!mounted) return;

      setState(() {
        _isSubmitting = false;
        _quizSubmitted = success;
      });

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Quiz submitted successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(quizProvider.error ?? 'Failed to submit quiz'),
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

  void _nextQuestion() {
    final quiz = Provider.of<QuizProvider>(context, listen: false).currentQuiz;
    if (quiz == null || quiz.questions.isEmpty) {
      return;
    }

    if (_currentQuestionIndex < quiz.questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
    }
  }

  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() {
        _currentQuestionIndex--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final quizProvider = Provider.of<QuizProvider>(context);
    final quiz = quizProvider.currentQuiz;
    final isLoading = quizProvider.isLoading;

    // If quiz is submitted, show results
    if (_quizSubmitted && quiz != null) {
      return _buildResultsScreen(context, quiz);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(quiz?.title ?? 'Quiz'),
        actions: [
          TextButton(
            onPressed: _submitQuiz,
            child: const Text(
              'Submit',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: isLoading || quiz == null
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Quiz progress
                    LinearProgressIndicator(
                      value: (quiz.questions.isNotEmpty)
                          ? (_currentQuestionIndex + 1) / quiz.questions.length
                          : 0,
                      backgroundColor: AppColors.primaryLight.withOpacity(0.3),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.primary),
                    ),

                    const SizedBox(height: 8),

                    // Question count
                    Text(
                      quiz.questions.isNotEmpty
                          ? 'Question ${_currentQuestionIndex + 1} of ${quiz.questions.length}'
                          : 'No questions available',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),

                    const SizedBox(height: 24),

                    // Question
                    if (quiz.questions.isNotEmpty &&
                        _currentQuestionIndex < quiz.questions.length)
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Question text
                              Text(
                                quiz.questions[_currentQuestionIndex].text,
                                style:
                                    Theme.of(context).textTheme.headlineSmall,
                              ),

                              const SizedBox(height: 24),

                              // Answer options
                              ...List.generate(
                                quiz.questions[_currentQuestionIndex].options
                                    .length,
                                (index) {
                                  final option = quiz
                                      .questions[_currentQuestionIndex]
                                      .options[index];
                                  return _buildAnswerOption(
                                    context,
                                    option: option,
                                    isSelected: _selectedAnswers[
                                            _currentQuestionIndex] ==
                                        index,
                                    onTap: () {
                                      setState(() {
                                        _selectedAnswers[
                                            _currentQuestionIndex] = index;
                                      });
                                    },
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      const Expanded(
                        child: Center(
                          child: Text('No questions available for this quiz'),
                        ),
                      ),

                    // Navigation buttons
                    if (quiz.questions.isNotEmpty)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (_currentQuestionIndex > 0)
                            AppButton(
                              text: 'Previous',
                              type: ButtonType.outline,
                              icon: Icons.arrow_back,
                              onPressed: _previousQuestion,
                            )
                          else
                            const SizedBox.shrink(),
                          if (_currentQuestionIndex < quiz.questions.length - 1)
                            AppButton(
                              text: 'Next',
                              type: ButtonType.primary,
                              icon: Icons.arrow_forward,
                              iconRight: true,
                              onPressed: _nextQuestion,
                            )
                          else
                            AppButton(
                              text: 'Submit Quiz',
                              type: ButtonType.primary,
                              isLoading: _isSubmitting,
                              onPressed: _submitQuiz,
                            ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildAnswerOption(
    BuildContext context, {
    required dynamic option,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.textHint,
              width: isSelected ? 2 : 1,
            ),
            color:
                isSelected ? AppColors.primary.withOpacity(0.1) : Colors.white,
          ),
          child: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? AppColors.primary : Colors.white,
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.textHint,
                  ),
                ),
                child: isSelected
                    ? const Icon(
                        Icons.check,
                        size: 16,
                        color: Colors.white,
                      )
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  option.text ?? 'Answer option',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultsScreen(BuildContext context, dynamic quiz) {
    final quizResult = Provider.of<QuizProvider>(context).quizResult;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Results'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(
                Icons.check_circle,
                size: 100,
                color: AppColors.success,
              ),

              const SizedBox(height: 24),

              Text(
                'Quiz Completed!',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              Text(
                'You have completed the ${quiz.title} quiz.',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 32),

              // Score
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Text(
                      'Your Score',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      quizResult != null
                          ? '${quizResult['score']}/${quizResult['total']}'
                          : 'Pending',
                      style:
                          Theme.of(context).textTheme.headlineLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      quizResult != null
                          ? 'Percentage: ${((quizResult['score'] / quizResult['total']) * 100).toStringAsFixed(1)}%'
                          : '',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Back to dashboard button
              AppButton(
                text: 'Back to Dashboard',
                type: ButtonType.primary,
                isFullWidth: true,
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
