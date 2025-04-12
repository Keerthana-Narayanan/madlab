// pubsec yaml file
// name: todo_app
// description: A simple to-do app using Provider and SharedPreferences.
// publish_to: 'none' 
// version: 1.0.0+1

// environment:
//   sdk: '>=2.17.0 <4.0.0'

// dependencies:
//   flutter:
//     sdk: flutter
//   provider: ^6.1.2
//   shared_preferences: ^2.2.2

// dev_dependencies:
//   flutter_test:
//     sdk: flutter

// flutter:
//   uses-material-design: true

//   # Optional: Add custom font if you want 'Poppins'
//   fonts:
//     - family: Poppins
//       fonts:
//         - asset: assets/fonts/Poppins-Regular.ttf
//         - asset: assets/fonts/Poppins-Bold.ttf
//           weight: 700

//   # Optional: Include assets folder if you use images or other resources
//   assets:
//     - assets/


import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

typedef TaskList = List<String>;

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TodoProvider()),
      ],
      child: const TodoApp(),
    ),
  );
}

class TodoApp extends StatelessWidget {
  const TodoApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'To-Do App',
      theme: ThemeData(
        fontFamily: 'Poppins',
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.transparent,
      ),
      home: const TodoHome(),
    );
  }
}

class TodoHome extends StatelessWidget {
  const TodoHome({Key? key}) : super(key: key);

  void showTaskDialog(BuildContext context, {String? task, int? index}) {
    final controller = TextEditingController(text: task);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text(index == null ? 'Add Task' : 'Edit Task',
            style: const TextStyle(fontWeight: FontWeight.bold)),
        content: TextField(controller: controller, decoration: const InputDecoration(border: OutlineInputBorder())),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              final todoProvider = Provider.of<TodoProvider>(context, listen: false);
              if (controller.text.isNotEmpty) {
                index == null ? todoProvider.addTask(controller.text) : todoProvider.editTask(index, controller.text);
              }
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('To-Do List')),
      body: Consumer<TodoProvider>(
        builder: (context, todoProvider, child) {
          return Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(colors: [Colors.blue, Colors.blueAccent], begin: Alignment.topLeft, end: Alignment.bottomRight),
                ),
              ),
              ListView.builder(
                padding: const EdgeInsets.all(10),
                itemCount: todoProvider.tasks.length,
                itemBuilder: (context, index) => Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    title: Text(todoProvider.tasks[index], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                    trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                      IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => showTaskDialog(context, task: todoProvider.tasks[index], index: index)),
                      IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => todoProvider.deleteTask(index)),
                    ]),
                  ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueAccent,
        onPressed: () => showTaskDialog(context),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class TodoProvider extends ChangeNotifier {
  TaskList _tasks = [];

  TaskList get tasks => _tasks;

  TodoProvider() {
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    _tasks = prefs.getStringList('tasks') ?? [];
    notifyListeners();
  }

  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('tasks', _tasks);
  }

  void addTask(String task) {
    _tasks.add(task);
    _saveTasks();
    notifyListeners();
  }

  void editTask(int index, String newTask) {
    _tasks[index] = newTask;
    _saveTasks();
    notifyListeners();
  }

  void deleteTask(int index) {
    _tasks.removeAt(index);
    _saveTasks();
    notifyListeners();
  }
}
