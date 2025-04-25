import 'dart:async';
import 'package:flutter/material.dart';

void main() => runApp(SmartCookingTimerApp());

class SmartCookingTimerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Cooking Timer',
      theme: ThemeData(primarySwatch: Colors.orange),
      home: CookingTimerHome(),
    );
  }
}

class CookingTask {
  String label;
  int totalSeconds;
  int remainingSeconds;
  bool isRunning;
  Timer? timer;

  CookingTask({required this.label, required this.totalSeconds})
    : remainingSeconds = totalSeconds,
      isRunning = false;

  void start(VoidCallback onTick) {
    isRunning = true;
    timer = Timer.periodic(Duration(seconds: 1), (t) {
      if (remainingSeconds > 0) {
        remainingSeconds--;
        onTick();
      } else {
        stop();
      }
    });
  }

  void pause() {
    isRunning = false;
    timer?.cancel();
  }

  void reset() {
    pause();
    remainingSeconds = totalSeconds;
  }

  void stop() {
    isRunning = false;
    timer?.cancel();
    remainingSeconds = 0;
  }

  double get progress => 1 - (remainingSeconds / totalSeconds);
  String get timeString =>
      '${(remainingSeconds ~/ 60).toString().padLeft(2, '0')}:${(remainingSeconds % 60).toString().padLeft(2, '0')}';
}

class CookingTimerHome extends StatefulWidget {
  @override
  _CookingTimerHomeState createState() => _CookingTimerHomeState();
}

class _CookingTimerHomeState extends State<CookingTimerHome> {
  List<CookingTask> tasks = [];

  void _addTask(String label, int minutes) {
    setState(() {
      tasks.add(CookingTask(label: label, totalSeconds: minutes * 60));
    });
  }

  void _showAddTaskDialog() {
    final labelController = TextEditingController();
    final durationController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: Text('Add Cooking Task'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: labelController,
                  decoration: InputDecoration(labelText: 'Label'),
                ),
                TextField(
                  controller: durationController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Duration (mins)'),
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
                  if (labelController.text.isNotEmpty &&
                      int.tryParse(durationController.text) != null) {
                    _addTask(
                      labelController.text,
                      int.parse(durationController.text),
                    );
                  }
                  Navigator.of(ctx).pop();
                },
                child: Text('Add'),
              ),
            ],
          ),
    );
  }

  Widget _buildTaskCard(CookingTask task, int index) {
    return Card(
      margin: EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              task.label,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            LinearProgressIndicator(value: task.progress, minHeight: 10),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(task.timeString, style: TextStyle(fontSize: 16)),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        task.isRunning ? Icons.pause : Icons.play_arrow,
                      ),
                      onPressed: () {
                        setState(() {
                          if (task.isRunning) {
                            task.pause();
                          } else {
                            task.start(() => setState(() {}));
                          }
                        });
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.stop),
                      onPressed: () => setState(() => task.reset()),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    for (var task in tasks) {
      task.timer?.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Smart Cooking Timer')),
      body: ListView.builder(
        itemCount: tasks.length,
        itemBuilder: (ctx, i) => _buildTaskCard(tasks[i], i),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskDialog,
        child: Icon(Icons.add),
        tooltip: 'Add Cooking Task',
      ),
    );
  }
}
