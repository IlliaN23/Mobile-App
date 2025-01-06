import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'user.task_page.dart'; // Импорт файла с моделью задачи и менеджером

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
    _controller = VideoPlayerController.asset('lib/assets/folder/medved.mp4')
      ..initialize().then((_) {
        setState(() {}); // Обновляем UI после инициализации видео
        _controller.setLooping(true); // Циклическое воспроизведение
        _controller.play(); // Запуск видео
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
          // Видеофон
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

          // Контент с задачами поверх видео
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
    _controller.dispose(); // Освобождаем ресурсы видео
  }
}
