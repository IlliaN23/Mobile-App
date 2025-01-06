import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // Для работы с JSON

// Модель задачи
class Task {
  String text;
  DateTime date;

  Task(this.text, {required this.date});

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'date': date.toIso8601String(),
    };
  }

  static Task fromMap(Map<String, dynamic> map) {
    return Task(
      map['text'],
      date: DateTime.parse(map['date']),
    );
  }
}

// Менеджер задач
class TaskManager {
  List<Task> tasks = [];

  // Загрузка задач из SharedPreferences
  Future<void> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final String? tasksJson = prefs.getString('tasks');
    if (tasksJson != null) {
      final List<dynamic> taskList = json.decode(tasksJson);
      tasks = taskList.map((taskMap) => Task.fromMap(taskMap)).toList();
    }
  }

  // Сохранение задач в SharedPreferences
  Future<void> saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> taskList =
        tasks.map((task) => task.toMap()).toList();
    final String tasksJson = json.encode(taskList);
    prefs.setString('tasks', tasksJson);
  }

  // Добавление задачи
  void addTask(String text, DateTime date) {
    tasks.add(Task(text, date: date));
  }

  // Удаление задачи
  void removeTask(int index) {
    tasks.removeAt(index);
  }
}

class TasksPage extends StatefulWidget {
  const TasksPage({super.key});

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  final TaskManager taskManager = TaskManager();
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _loadTasks();
    _controller = VideoPlayerController.asset('lib/assets/folder/Tree.mp4')
      ..initialize().then((_) {
        setState(() {});
        _controller.setLooping(true);
        _controller.play();
      });
  }

  // Загрузка задач
  Future<void> _loadTasks() async {
    await taskManager.loadTasks();
    setState(() {});
  }

  // Добавление задачи
  void _addTask() async {
    final TextEditingController taskController = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Notice'),
        content: TextField(
          controller: taskController,
          decoration: const InputDecoration(hintText: 'Here your tasks'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final taskText = taskController.text.trim();
              if (taskText.isNotEmpty) {
                taskManager.addTask(taskText, DateTime.now());
                taskManager.saveTasks();
                setState(() {});
              }
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tasks"),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          _controller.value.isInitialized
              ? SizedBox.expand(
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: _controller.value.size.width,
                      height: _controller.value.size.height,
                      child: VideoPlayer(_controller),
                    ),
                  ),
                )
              : const Center(child: CircularProgressIndicator()),
          taskManager.tasks.isEmpty
              ? const Center(
                  child: Text(
                    "Add some Tasks!",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                )
              : ListView.builder(
                  itemCount: taskManager.tasks.length,
                  itemBuilder: (context, index) {
                    final task = taskManager.tasks[index];
                    return ListTile(
                      title: Text(
                        task.text,
                        style: const TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(
                        task.date.toLocal().toString(),
                        style: const TextStyle(color: Colors.white),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            taskManager.removeTask(index);
                            taskManager.saveTasks();
                          });
                        },
                      ),
                    );
                  },
                ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTask,
        child: const Icon(Icons.add),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose(); // Освобождение ресурсов видео
  }
}
