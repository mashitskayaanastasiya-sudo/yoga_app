import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'models/asana.dart';

class PracticeConstructorScreen extends StatefulWidget {
  const PracticeConstructorScreen({super.key});

  @override
  State<PracticeConstructorScreen> createState() =>
      _PracticeConstructorScreenState();
}

class _PracticeConstructorScreenState extends State<PracticeConstructorScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Future<List<Asana>> asanasFuture;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    asanasFuture = loadAsanas();
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
      appBar: AppBar(
        title: const Text("Конструктор практики"),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "Сохранённые практики"),
            Tab(text: "Создать практику"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          const Center(child: Text("Здесь будут сохранённые практики")),
          FutureBuilder<List<Asana>>(
            future: asanasFuture,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              return CreatePracticeTab(asanas: snapshot.data!);
            },
          ),
        ],
      ),
    );
  }
}

class CreatePracticeTab extends StatefulWidget {
  final List<Asana> asanas;
  const CreatePracticeTab({super.key, required this.asanas});

  @override
  State<CreatePracticeTab> createState() => _CreatePracticeTabState();
}

class _CreatePracticeTabState extends State<CreatePracticeTab> {
  late List<Asana> sequence;

  @override
  void initState() {
    super.initState();
    sequence = [
      widget.asanas.firstWhere((a) => a.nameSanskrit == "Тадасана",
          orElse: () => widget.asanas.first),
      widget.asanas.firstWhere((a) => a.nameSanskrit == "Шавасана",
          orElse: () => widget.asanas.last),
    ];
  }

  void addAsana(Asana asana) {
    setState(() {
      sequence.insert(sequence.length - 1, asana);
    });
  }

  void removeAsana(int index) {
    setState(() {
      if (index != 0 && index != sequence.length - 1) {
        sequence.removeAt(index);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, List<Asana>> grouped = {};
    for (var asana in widget.asanas) {
      grouped.putIfAbsent(asana.skill, () => []).add(asana);
    }

    return Row(
      children: [
        Expanded(
          flex: 1,
          child: ListView.builder(
            itemCount: sequence.length,
            itemBuilder: (context, index) {
              final asana = sequence[index];
              return Card(
                margin: const EdgeInsets.all(8),
                child: Column(
                  children: [
                    Image.network(asana.imageUrl,
                        height: 80, fit: BoxFit.contain),
                    Text(asana.nameSanskrit,
                        style: const TextStyle(fontSize: 12)),
                    if (index != 0 && index != sequence.length - 1)
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => removeAsana(index),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
        Expanded(
          flex: 2,
          child: ListView(
            children: grouped.entries.map((entry) {
              return ExpansionTile(
                title: Text(entry.key,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                children: entry.value.map((asana) {
                  return ListTile(
                    leading: Image.network(asana.imageUrl,
                        height: 50, fit: BoxFit.contain),
                    title: Text(asana.nameSanskrit),
                    subtitle: Text(asana.nameRussian),
                    onTap: () => addAsana(asana),
                  );
                }).toList(),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
