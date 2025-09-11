import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'models/asana.dart';

class QuizStartScreen extends StatefulWidget {
  final List<Asana> asanas; // ✅ добавили поле

  const QuizStartScreen({super.key, required this.asanas}); // ✅ конструктор

  @override
  State<QuizStartScreen> createState() => _QuizStartScreenState();
}


class _QuizStartScreenState extends State<QuizStartScreen> {
  int totalQuestions = 5;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Выберите количество вопросов")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            DropdownButton<int>(
              value: totalQuestions,
              items: const [
                DropdownMenuItem(value: 5, child: Text("5")),
                DropdownMenuItem(value: 10, child: Text("10")),
                DropdownMenuItem(value: 20, child: Text("20")),
              ],
              onChanged: (val) {
                setState(() {
                  totalQuestions = val!;
                });
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final String response =
                    await rootBundle.loadString('assets/data/surya_namaskar.json');
                final List<dynamic> data = json.decode(response);
                final asanas = data.map((item) => Asana.fromJson(item)).toList();

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        QuizScreen(asanas: asanas, totalQuestions: totalQuestions),
                  ),
                );
              },
              child: const Text("Начать тест"),
            ),
          ],
        ),
      ),
    );
  }
}

class QuizScreen extends StatefulWidget {
  final List<Asana> asanas;
  final int totalQuestions;

  const QuizScreen({super.key, required this.asanas, required this.totalQuestions});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late List<Asana> quizAsanas;
  int currentIndex = 0;
  int score = 0;
  String? selectedAnswer;

  @override
  void initState() {
    super.initState();
    quizAsanas = List.of(widget.asanas)..shuffle();
    quizAsanas = quizAsanas.take(widget.totalQuestions).toList();
  }

  void checkAnswer(String answer) {
    setState(() {
      selectedAnswer = answer;
      if (answer == quizAsanas[currentIndex].nameSanskrit) {
        score++;
      }
    });

    // через 1 секунду переключаемся на следующий вопрос
    Future.delayed(const Duration(seconds: 1), () {
      if (currentIndex < widget.totalQuestions - 1) {
        setState(() {
          currentIndex++;
          selectedAnswer = null;
        });
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                QuizResultScreen(score: score, total: widget.totalQuestions),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final asana = quizAsanas[currentIndex];

// правильный ответ
final correctAnswer = asana.nameSanskrit.trim();

// собираем все уникальные варианты
final allOptions = widget.asanas
    .map((a) => a.nameSanskrit.trim())
    .toSet() // убираем дубли
    .toList();

// убираем правильный из "неправильных"
allOptions.remove(correctAnswer);

// выбираем 3 случайных неправильных
allOptions.shuffle(Random());
final wrongOptions = allOptions.take(3).toList();

// финальный список: правильный + неправильные
List<String> options = [correctAnswer, ...wrongOptions]..shuffle(Random());



    return Scaffold(
      appBar: AppBar(title: Text("Вопрос ${currentIndex + 1}/${widget.totalQuestions}")),
      body: Column(
        children: [
          Expanded(
            flex: 3, // картинка занимает 3/4
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Image.network(asana.imageUrl, fit: BoxFit.contain),
            ),
          ),
          Expanded(
            flex: 1, // кнопки занимают 1/4
            child: ListView(
              children: options.map((option) {
               Color? color;
final correctAnswer = asana.nameSanskrit.trim();
final chosen = option.trim();

if (selectedAnswer != null) {
  if (chosen == correctAnswer) {
    color = Colors.green;
  } else if (chosen == selectedAnswer!.trim()) {
    color = Colors.red;
  }
}
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color ?? Colors.white,
                      foregroundColor: Colors.black,
                      side: const BorderSide(color: Colors.black12),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    onPressed: selectedAnswer == null ? () => checkAnswer(option) : null,
                    child: Text(option, style: const TextStyle(fontSize: 16)),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class QuizResultScreen extends StatelessWidget {
  final int score;
  final int total;

  const QuizResultScreen({super.key, required this.score, required this.total});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Результат")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Вы набрали $score из $total",
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Завершить"),
            ),
          ],
        ),
      ),
    );
  }
}
