import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../services/api_service.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  String? _quizContent;
  bool _isLoading = false;
  int _score = 0;
  int _totalQuestions = 0;
  bool _quizCompleted = false;
  List<Map<String, dynamic>> _questions = [];
  Map<int, String> _selectedAnswers = {};

  @override
  void initState() {
    super.initState();
    _generateQuiz();
  }

  Future<void> _generateQuiz() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final appProvider = Provider.of<AppProvider>(context, listen: false);
      final apiService = ApiService();
      final response = await apiService.generateQuiz(appProvider.userId);

      if (mounted) {
        setState(() {
          _quizContent = response.quiz;
          _quizCompleted = false;
          _score = 0;
          _totalQuestions = _countQuestions(response.quiz);
          _questions = _parseQuiz(response.quiz);
          _selectedAnswers = {};
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to generate quiz: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  int _countQuestions(String quizText) {
    // Simple count of "Question" occurrences
    return "Question".allMatches(quizText).length;
  }

  List<Map<String, dynamic>> _parseQuiz(String quizText) {
    // Simple parsing - in a real app, you'd use a more robust parser
    // This assumes the quiz format is consistent
    List<Map<String, dynamic>> questions = [];
    List<String> lines = quizText.split('\n');

    Map<String, dynamic>? currentQuestion;
    List<String> currentOptions = [];

    for (String line in lines) {
      line = line.trim();
      if (line.startsWith('Question')) {
        if (currentQuestion != null) {
          currentQuestion['options'] = currentOptions;
          questions.add(currentQuestion);
        }
        currentQuestion = {
          'question': line,
          'options': [],
        };
        currentOptions = [];
      } else if (line.startsWith('A)') || line.startsWith('B)') || line.startsWith('C)') || line.startsWith('D)')) {
        currentOptions.add(line);
      } else if (line.startsWith('Correct:')) {
        if (currentQuestion != null) {
          currentQuestion['correctAnswer'] = line.split(':')[1].trim();
        }
      }
    }

    if (currentQuestion != null) {
      currentQuestion['options'] = currentOptions;
      questions.add(currentQuestion);
    }

    return questions;
  }

  void _completeQuiz() {
    int score = 0;
    for (int i = 0; i < _questions.length; i++) {
      String? selectedAnswer = _selectedAnswers[i];
      String? correctAnswer = _questions[i]['correctAnswer'];
      if (selectedAnswer == correctAnswer) {
        score++;
      }
    }

    setState(() {
      _score = score;
      _quizCompleted = true;
    });

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Quiz Completed!'),
        content: Text('Your score: $_score / $_totalQuestions'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _generateQuiz();
            },
            child: const Text('Take Another Quiz'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(); // Go back to home
            },
            child: const Text('Back to Home'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('StudyBuddy Quiz'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _generateQuiz,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _quizContent == null
              ? const Center(child: Text('No quiz available. Upload notes first.'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Answer the following questions based on your notes:',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 20),
                      if (_questions.isNotEmpty) ...[
                        ..._questions.map((question) => Card(
                          margin: const EdgeInsets.only(bottom: 16.0),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  question['question'],
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                ...(question['options'] as List<String>).map((option) => RadioListTile<String>(
                                  title: Text(option),
                                  value: option[0], // A, B, C, D
                                  groupValue: _selectedAnswers[_questions.indexOf(question)],
                                  onChanged: (String? value) {
                                    if (value != null) {
                                      setState(() {
                                        _selectedAnswers[_questions.indexOf(question)] = value;
                                      });
                                    }
                                  },
                                )),
                              ],
                            ),
                          ),
                        )),
                        const SizedBox(height: 20),
                        if (!_quizCompleted) ...[
                          Center(
                            child: ElevatedButton(
                              onPressed: _selectedAnswers.length == _questions.length ? _completeQuiz : null,
                              child: const Text('Submit Quiz'),
                            ),
                          ),
                        ],
                      ] else ...[
                        Text(
                          _quizContent!,
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 20),
                        if (!_quizCompleted) ...[
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  decoration: const InputDecoration(
                                    hintText: 'Enter your answers (e.g., A, B, C, D)',
                                    border: OutlineInputBorder(),
                                  ),
                                  onSubmitted: (value) {
                                    // For simplicity, we'll just mark as completed
                                    // In a real app, you'd parse answers and calculate score
                                    _completeQuiz();
                                  },
                                ),
                              ),
                              const SizedBox(width: 10),
                              ElevatedButton(
                                onPressed: _completeQuiz,
                                child: const Text('Submit Answers'),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ],
                  ),
                ),
    );
  }
}
