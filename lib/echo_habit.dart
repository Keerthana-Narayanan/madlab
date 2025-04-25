import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';

void main() => runApp(EcoHabitTrackerApp());

class EcoHabitTrackerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EcoHabit Tracker',
      theme: ThemeData(primarySwatch: Colors.green),
      home: HabitHomePage(),
    );
  }
}

class HabitHomePage extends StatefulWidget {
  @override
  _HabitHomePageState createState() => _HabitHomePageState();
}

class _HabitHomePageState extends State<HabitHomePage> {
  List<Habit> habits = [];
  final quoteList = [
    "Small acts, when multiplied by millions of people, can transform the world.",
    "Be the change you wish to see in the world.",
    "Going green starts with a single step.",
  ];

  void _addHabit(String title, String frequency) {
    setState(() {
      habits.add(Habit(title: title, frequency: frequency));
    });
  }

  void _markComplete(int index) {
    setState(() {
      habits[index].completionCount++;
      habits[index].lastCompleted = DateTime.now();
    });
  }

  void _showAddHabitDialog() {
    final titleController = TextEditingController();
    String selectedFrequency = 'Daily';

    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: Text('Add New Habit'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(labelText: 'Habit'),
                ),
                DropdownButton<String>(
                  value: selectedFrequency,
                  onChanged:
                      (newValue) =>
                          setState(() => selectedFrequency = newValue!),
                  items:
                      ['Daily', 'Weekly']
                          .map(
                            (freq) => DropdownMenuItem(
                              value: freq,
                              child: Text(freq),
                            ),
                          )
                          .toList(),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  _addHabit(titleController.text, selectedFrequency);
                  Navigator.of(ctx).pop();
                },
                child: Text('Add'),
              ),
            ],
          ),
    );
  }

  String getMotivationalQuote() {
    if (habits.isEmpty) return "Start a green habit today!";
    return quoteList[Random().nextInt(quoteList.length)];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('EcoHabit Tracker')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              getMotivationalQuote(),
              style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: habits.length,
              itemBuilder: (ctx, index) {
                final habit = habits[index];
                return ListTile(
                  title: Text(habit.title),
                  subtitle: Text(
                    '${habit.frequency} | Completed: ${habit.completionCount}',
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.check_circle, color: Colors.green),
                    onPressed: () => _markComplete(index),
                  ),
                );
              },
            ),
          ),
          Container(
            height: 200,
            padding: EdgeInsets.all(16),
            child: BarChart(
              BarChartData(
                barGroups:
                    habits
                        .asMap()
                        .entries
                        .map(
                          (e) => BarChartGroupData(
                            x: e.key,
                            barRods: [
                              BarChartRodData(
                                toY: e.value.completionCount.toDouble(),
                                color: Colors.green,
                              ),
                            ],
                            showingTooltipIndicators: [0],
                          ),
                        )
                        .toList(),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddHabitDialog,
        child: Icon(Icons.add),
        tooltip: 'Add Habit',
      ),
    );
  }
}

class Habit {
  String title;
  String frequency;
  int completionCount;
  DateTime? lastCompleted;

  Habit({
    required this.title,
    required this.frequency,
    this.completionCount = 0,
    this.lastCompleted,
  });
}
