import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'models/asana.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  List<Asana> _allAsanas = [];
  List<Asana> _questions = [];
  List<String> _options = [];
  int _currentIndex = 0;
  int _score = 0;
  int _totalQuestions = 5;
  bool _answered = false;
  String? _selectedAnswer;

  @override
  void initState() {
    super.initState();
    _loadAsanas();
  }

  /// Загружаем JSON с асанами
  Future<void> _loadAsanas() async {
    final String response =
        await rootBundle.loadString('assets/data/surya_namaskar.json');
    final List<dynamic> data = json.decode(response);
    setState(() {
      _allAsanas = data.map((item) => Asana.fromJson(item)).toList();
    });
  }

  /// Запуск теста
  void _startQuiz() {
    if (_allAsanas.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Асаны ещё загружаются, попробуйте позже")),
      );
      return;
    }

    _allAsanas.shuffle();
    _questions = _allAsanas.take(_totalQuestions).toList();
    _currentIndex = 0;
    _score = 0;
    _answered = false;
    _selectedAnswer = null;
    _options = _generateOptions(_questions[_currentIndex]);

    setState(() {});
  }

  /// Генерация вариантов ответа
  List<String> _generateOptions(Asana correct) {
    final options = <String>[correct.nameSanskrit];
    final random = Random();

    while (options.length < 4) {
      final candidate = _allAsanas[random.nextInt(_allAsanas.length)].nameSanskrit;
      if (!options.contains(candidate)) {
        options.add(candidate);
      }
    }

    options.shuffle();
    return options;
  }

  /// Обработка выбора ответа
  void _selectAnswer(String answer) {
    setState(() {
      _answered = true;
      _selectedAnswer = answer;
      if (answer == _questions[_currentIndex].nameSanskrit) {
        _score++;
      }
    });

    Future.delayed(const Duration(seconds: 1), () {
      if (_currentIndex < _questions.length - 1) {
        setState(() {
          _currentIndex++;
          _answered = false;
          _selectedAnswer = null;
          _options = _generateOptions(_questions[_currentIndex]);
        });
      } else {
        _showResult();
      }
    });
  }

  /// Показ результата
  void _showResult() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Результат"),
        content: Text("Вы ответили правильно на $_score из $_totalQuestions"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _questions.clear();
              });
            },
            child: const Text("Ок"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 1. Пока асаны не загружены
    if (_allAsanas.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // 2. Пока тест не запущен
    if (_questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text("Тест")),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Выберите количество вопросов:"),
              const SizedBox(height: 20),
              DropdownButton<int>(
                value: _totalQuestions,
                items: const [
                  DropdownMenuItem(value: 5, child: Text("5")),
                  DropdownMenuItem(value: 10, child: Text("10")),
                  DropdownMenuItem(value: 20, child: Text("20")),
                ],
                onChanged: (val) => setState(() => _totalQuestions = val!),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _startQuiz,
                child: const Text("Начать тест"),
              ),
            ],
          ),
        ),
      );
    }

    // 3. Экран с вопросом
    final asana = _questions[_currentIndex];

    return Scaffold(
      appBar: AppBar(title: Text("Вопрос ${_currentIndex + 1}/$_totalQuestions")),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Image.network(asana.imageUrl, fit: BoxFit.contain),
            ),
          ),
          Column(
            children: _options.map((option) {
              final isCorrect = option == asana.nameSanskrit;
              final isSelected = option == _selectedAnswer;

              Color? color;
              if (_answered && isSelected) {
                color = isCorrect ? Colors.green : Colors.red;
              } else if (_answered && isCorrect) {
                color = Colors.green;
              }

              return GestureDetector(
                onTap: !_answered ? () => _selectAnswer(option) : null,
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.black54),
                    color: color ?? Colors.white,
                  ),
                  child: Center(
                    child: Text(option, style: const TextStyle(fontSize: 18)),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
