import 'package:flutter/material.dart';
import 'models/asana.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:math';

void main() {
  runApp(const YogaApp());
}

class YogaApp extends StatelessWidget {
  const YogaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Yoga App',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const LandingPage(),
    );
  }
}

/// ЛЕНДИНГ
class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          // Фоновая картинка
          Positioned.fill(
            child: Image.asset(
              'assets/images/landing.png',
              fit: BoxFit.contain, // картинка целиком, по бокам белые поля
              alignment: Alignment.center,
            ),
          ),
          // Меню поверх картинки
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 100), // отступ сверху
              _buildMenuItem(context, "Обучение", const AsanaCardsScreen()),
              const SizedBox(height: 30),
              _buildMenuItem(context, "Тест",
                  const PlaceholderScreen(title: "Тест")),
              const SizedBox(height: 30),
              _buildMenuItem(context, "Конструктор практики",
                  const PlaceholderScreen(title: "Конструктор практики")),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, String text, Widget screen) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => screen));
      },
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

/// СТРАНИЦА С КАРТОЧКАМИ АСАН
class AsanaCardsScreen extends StatefulWidget {
  const AsanaCardsScreen({super.key});

  @override
  State<AsanaCardsScreen> createState() => _AsanaCardsScreenState();
}

class _AsanaCardsScreenState extends State<AsanaCardsScreen> {
  late Future<List<Asana>> asanas;

  @override
  void initState() {
    super.initState();
    asanas = loadAsanas();
  }

  Future<List<Asana>> loadAsanas() async {
    final String response =
        await rootBundle.loadString('assets/data/surya_namaskar.json');
    final List<dynamic> data = json.decode(response);
    return data.map((item) => Asana.fromJson(item)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Сурья Намаскар')),
      body: FutureBuilder<List<Asana>>(
        future: asanas,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Ошибка: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Нет данных'));
          } else {
            final items = snapshot.data!;
            return PageView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final asana = items[index];
                return Center(
                  child: FlipCard(asana: asana),
                );
              },
            );
          }
        },
      ),
    );
  }
}

/// Виджет флип-карточки
class FlipCard extends StatefulWidget {
  final Asana asana;
  const FlipCard({super.key, required this.asana});

  @override
  State<FlipCard> createState() => _FlipCardState();
}

class _FlipCardState extends State<FlipCard> {
  bool _showBack = false;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: () => setState(() => _showBack = !_showBack),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        transitionBuilder: (child, animation) {
          final rotate = Tween(begin: pi, end: 0.0).animate(animation);
          return AnimatedBuilder(
            animation: rotate,
            builder: (context, child) {
              final angle = _showBack ? rotate.value : -rotate.value;
              return Transform(
                transform: Matrix4.rotationY(angle),
                alignment: Alignment.center,
                child: child,
              );
            },
            child: child,
          );
        },
        child: _showBack ? _buildBack(size) : _buildFront(size),
      ),
    );
  }

  /// Передняя сторона карточки
  Widget _buildFront(Size size) {
    return Card(
      elevation: 6,
      margin: const EdgeInsets.all(16),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: size.height * 0.75,
          maxWidth: 350,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Image.network(
                widget.asana.imageUrl,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 12),

            // Названия и подсказка
            Column(
              children: [
                Text(
                  widget.asana.nameSanskrit,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  widget.asana.nameRussian,
                  style: const TextStyle(
                    fontSize: 18,
                    fontStyle: FontStyle.italic,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                const Text(
                  '(нажми, чтобы перевернуть)',
                  style: TextStyle(
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    color: Colors.black54,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  /// Задняя сторона карточки
  Widget _buildBack(Size size) {
    return Card(
      elevation: 6,
      margin: const EdgeInsets.all(16),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: size.height * 0.75,
          maxWidth: 350,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.asana.fact.isNotEmpty) ...[
                  Text("Факт: ${widget.asana.fact}",
                      style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 8),
                ],
                if (widget.asana.technique.isNotEmpty) ...[
                  Text("Техника: ${widget.asana.technique}",
                      style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 8),
                ],
                if (widget.asana.limitations != null &&
                    widget.asana.limitations!.isNotEmpty)
                  Text("Ограничения: ${widget.asana.limitations}",
                      style: const TextStyle(fontSize: 16)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


/// ЗАГЛУШКИ ДЛЯ ТЕСТА И КОНСТРУКТОРА
class PlaceholderScreen extends StatelessWidget {
  final String title;
  const PlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: const Center(
        child: Text(
          'Stay tuned!',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
