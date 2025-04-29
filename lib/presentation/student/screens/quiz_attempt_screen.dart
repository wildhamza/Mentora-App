import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:mentora/core/themes/app_theme.dart';
import 'package:mentora/core/widgets/app_button.dart';
import 'package:mentora/core/widgets/loading_indicator.dart';

@RoutePage()
class QuizAttemptScreen extends StatefulWidget {
  final int quizId;

  const QuizAttemptScreen({
    Key? key,
    @PathParam('id') required this.quizId,
  }) : super(key: key);

  @override
  _QuizAttemptScreenState createState() => _QuizAttemptScreenState();
}

class _QuizAttemptScreenState extends State<QuizAttemptScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  
  // Quiz data
  String _quizTitle = '';
  String _quizDescription = '';
  int _totalQuestions = 0;
  int _totalMarks = 0;
  int _timeLimit = 0; // in minutes
  
  // Quiz state
  int _currentQuestionIndex = 0;
  List<QuizQuestion> _questions = [];
  Map<int, int?> _selectedAnswers = {};
  Duration _remainingTime = Duration.zero;
  bool _isSubmitting = false;
  bool _quizCompleted = false;
  int? _score;

  late PageController _pageController;
  
  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _loadQuiz();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadQuiz() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      // Mock quiz data
      setState(() {
        _quizTitle = 'Flutter Fundamentals';
        _quizDescription = 'Test your knowledge of basic Flutter concepts and widgets.';
        _totalQuestions = 5;
        _totalMarks = 25;
        _timeLimit = 15; // 15 minutes
        _remainingTime = Duration(minutes: _timeLimit);
        
        _questions = [
          QuizQuestion(
            id: 1,
            text: 'What is Flutter?',
            options: [
              'A mobile operating system',
              'A UI toolkit for building multi-platform apps from a single codebase',
              'A programming language',
              'A database management system',
            ],
            correctOptionIndex: 1,
          ),
          QuizQuestion(
            id: 2,
            text: 'Which programming language is used for Flutter development?',
            options: [
              'Java',
              'Kotlin',
              'Swift',
              'Dart',
            ],
            correctOptionIndex: 3,
          ),
          QuizQuestion(
            id: 3,
            text: 'What is a Widget in Flutter?',
            options: [
              'A database object',
              'A UI component',
              'A design pattern',
              'A networking protocol',
            ],
            correctOptionIndex: 1,
          ),
          QuizQuestion(
            id: 4,
            text: 'Which of the following is a stateless widget?',
            options: [
              'Text',
              'TextField',
              'Checkbox',
              'StreamBuilder',
            ],
            correctOptionIndex: 0,
          ),
          QuizQuestion(
            id: 5,
            text: 'What is hot reload in Flutter?',
            options: [
              'Restarting the entire application',
              'Injecting updated code into the running Dart VM',
              'Changing the app theme dynamically',
              'Clearing the app cache',
            ],
            correctOptionIndex: 1,
          ),
        ];
        
        _isLoading = false;
        
        // Start timer
        _startTimer();
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load quiz: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  void _startTimer() {
    // In a real implementation, this would use a proper timer
    // For now, just simulate time passing
    Future.delayed(const Duration(minutes: 1), () {
      if (mounted && !_quizCompleted) {
        setState(() {
          _remainingTime = _remainingTime - const Duration(minutes: 1);
          
          if (_remainingTime.inSeconds <= 0) {
            _submitQuiz();
          } else {
            _startTimer();
          }
        });
      }
    });
  }

  void _selectAnswer(int questionId, int optionIndex) {
    setState(() {
      _selectedAnswers[questionId] = optionIndex;
    });
  }

  void _goToNextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
      _pageController.animateToPage(
        _currentQuestionIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _goToPreviousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() {
        _currentQuestionIndex--;
      });
      _pageController.animateToPage(
        _currentQuestionIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _submitQuiz() async {
    setState(() {
      _isSubmitting = true;
    });

    try {
      // Simulate API call to submit quiz answers
      await Future.delayed(const Duration(seconds: 2));
      
      // Calculate score
      int correctAnswers = 0;
      for (var question in _questions) {
        if (_selectedAnswers[question.id] == question.correctOptionIndex) {
          correctAnswers++;
        }
      }
      
      final score = (correctAnswers / _questions.length * _totalMarks).round();
      
      setState(() {
        _quizCompleted = true;
        _score = score;
        _isSubmitting = false;
      });
    } catch (e) {
      setState(() {
        _isSubmitting = false;
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit quiz: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_quizTitle.isEmpty ? 'Quiz' : _quizTitle),
        actions: [
          if (!_isLoading && !_quizCompleted)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _remainingTime.inMinutes < 5
                        ? AppTheme.errorColor.withOpacity(0.2)
                        : AppTheme.primaryColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.timer,
                        size: 16,
                        color: _remainingTime.inMinutes < 5
                            ? AppTheme.errorColor
                            : AppTheme.primaryColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${_remainingTime.inMinutes}:${(_remainingTime.inSeconds % 60).toString().padLeft(2, '0')}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _remainingTime.inMinutes < 5
                              ? AppTheme.errorColor
                              : AppTheme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const LoadingIndicator(message: 'Loading quiz...')
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Error',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadQuiz,
                          child: const Text('Try Again'),
                        ),
                      ],
                    ),
                  ),
                )
              : _quizCompleted
                  ? _buildQuizResults()
                  : _buildQuizContent(),
      bottomNavigationBar: !_isLoading && !_quizCompleted && _questions.isNotEmpty
          ? _buildBottomNavigation()
          : null,
    );
  }

  Widget _buildQuizContent() {
    return Column(
      children: [
        // Quiz info card
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _quizTitle,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _quizDescription,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildQuizInfoChip(
                        Icons.help_outline,
                        '$_totalQuestions Questions',
                        AppTheme.primaryColor.withOpacity(0.1),
                      ),
                      _buildQuizInfoChip(
                        Icons.workspace_premium,
                        '$_totalMarks Marks',
                        AppTheme.successColor.withOpacity(0.1),
                      ),
                      _buildQuizInfoChip(
                        Icons.timer,
                        '$_timeLimit Minutes',
                        AppTheme.warningColor.withOpacity(0.1),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        
        // Progress indicator
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: LinearProgressIndicator(
            value: (_currentQuestionIndex + 1) / _questions.length,
            backgroundColor: AppTheme.dividerColor,
            color: AppTheme.studentColor,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            'Question ${_currentQuestionIndex + 1} of $_totalQuestions',
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        
        // Questions
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            onPageChanged: (index) {
              setState(() {
                _currentQuestionIndex = index;
              });
            },
            itemCount: _questions.length,
            itemBuilder: (context, index) {
              final question = _questions[index];
              return _buildQuestionCard(question);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionCard(QuizQuestion question) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                question.text,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: question.options.length,
                  itemBuilder: (context, index) {
                    final isSelected = _selectedAnswers[question.id] == index;
                    return RadioListTile<int>(
                      title: Text(question.options[index]),
                      value: index,
                      groupValue: _selectedAnswers[question.id],
                      onChanged: (value) {
                        if (value != null) {
                          _selectAnswer(question.id, value);
                        }
                      },
                      activeColor: AppTheme.studentColor,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(
                          color: isSelected
                              ? AppTheme.studentColor
                              : AppTheme.dividerColor,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      tileColor:
                          isSelected ? AppTheme.studentColor.withOpacity(0.1) : null,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavigation() {
    final isLastQuestion = _currentQuestionIndex == _questions.length - 1;
    final isFirstQuestion = _currentQuestionIndex == 0;
    final currentQuestion = _questions[_currentQuestionIndex];
    final hasAnswered = _selectedAnswers.containsKey(currentQuestion.id);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (!isFirstQuestion)
            TextButton.icon(
              onPressed: _goToPreviousQuestion,
              icon: const Icon(Icons.arrow_back),
              label: const Text('Previous'),
            )
          else
            const SizedBox.shrink(),
          if (isLastQuestion)
            Expanded(
              child: AppButton(
                text: 'Submit Quiz',
                onPressed: _submitQuiz,
                type: AppButtonType.primary,
                isLoading: _isSubmitting,
              ),
            )
          else
            AppButton(
              text: 'Next Question',
              onPressed: hasAnswered ? _goToNextQuestion : null,
              type: AppButtonType.primary,
              icon: Icons.arrow_forward,
            ),
        ],
      ),
    );
  }

  Widget _buildQuizResults() {
    final percentScore = (_score! / _totalMarks * 100).round();
    final isPassing = percentScore >= 70;
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Results card
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isPassing
                          ? AppTheme.successColor.withOpacity(0.1)
                          : AppTheme.errorColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isPassing ? Icons.check_circle : Icons.error,
                      size: 64,
                      color: isPassing ? AppTheme.successColor : AppTheme.errorColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isPassing ? 'Congratulations!' : 'Quiz Completed',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isPassing ? AppTheme.successColor : AppTheme.errorColor,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isPassing
                        ? 'You passed the quiz!'
                        : 'You can try again to improve your score.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),
                  Text(
                    'Your Score',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$_score',
                        style: Theme.of(context).textTheme.displayLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isPassing
                                  ? AppTheme.successColor
                                  : AppTheme.errorColor,
                            ),
                      ),
                      Text(
                        '/$_totalMarks',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: AppTheme.textSecondaryColor,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$percentScore%',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: isPassing
                              ? AppTheme.successColor
                              : AppTheme.errorColor,
                        ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Action buttons
          Row(
            children: [
              Expanded(
                child: AppButton(
                  text: 'Review Answers',
                  onPressed: () {
                    // Navigate to review screen
                  },
                  type: AppButtonType.outline,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: AppButton(
                  text: 'Back to Course',
                  onPressed: () {
                    context.router.pop();
                  },
                  type: AppButtonType.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuizInfoChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: AppTheme.textPrimaryColor,
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class QuizQuestion {
  final int id;
  final String text;
  final List<String> options;
  final int correctOptionIndex;

  QuizQuestion({
    required this.id,
    required this.text,
    required this.options,
    required this.correctOptionIndex,
  });
}
