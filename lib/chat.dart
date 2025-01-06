import 'dart:math';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<Message> _messages = [];
  final TextEditingController _controller = TextEditingController();

  // Метод для случайного выбора файла
  String _getRandomFile() {
    final random = Random();
    // Список файлов
    final files = [
      'lib/assets/folder/sticker2.webp',
      'lib/assets/folder/sticker.webp',
    ];
    // Выбираем случайный файл из списка
    return files[random.nextInt(files.length)];
  }

  void _sendMessage() {
    if (_controller.text.isNotEmpty) {
      setState(() {
        // Добавляем новое текстовое сообщение
        _messages.add(
          Message(
            sender: 'User',
            content: _controller.text,
            timestamp: DateTime.now(),
            filePath: _getRandomFile(), // Отправляем случайный файл
          ),
        );
      });
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chat')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return ListTile(
                  title: Text(message.sender),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(message.content),
                      // Если есть файл, отображаем его
                      if (message.filePath != null)
                        Image.asset(
                          message.filePath!,
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                    ],
                  ),
                  trailing: Text(
                    '${message.timestamp.hour}:${message.timestamp.minute}',
                    style: const TextStyle(fontSize: 10),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration:
                        const InputDecoration(hintText: 'Type a message'),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class Message {
  final String sender;
  final String content;
  final DateTime timestamp;
  final String? filePath; // Добавляем путь к файлу

  Message({
    required this.sender,
    required this.content,
    required this.timestamp,
    this.filePath, // файл может быть пустым
  });
}
