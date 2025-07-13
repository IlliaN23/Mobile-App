import 'package:file_picker/file_picker.dart'; // Импортируем file_picker
import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'settings_page.dart' as settingsPage; // Экран настроек с префиксом
import 'profile_page.dart' as profilePage; // Экран профиля с префиксом
import 'tasks_page.dart' as tasksPage; // Экран задач с префиксом
import 'work_page.dart' as workPage; // Экран работы с префиксом
import 'sign_in.dart' as signInPage; // Экран авторизации с префиксом

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

  runApp(MyApp(isLoggedIn: isLoggedIn));
}

Future<bool> _loadTheme() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool('isDarkTheme') ?? false;
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  const MyApp({required this.isLoggedIn, super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Productivity App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: isLoggedIn ? const MainPage() : const signInPage.SignInPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 1;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const tasksPage.TasksPage()));
        break;
      case 1:
        break; // Остаёмся на главной странице
      case 2:
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const profilePage.ProfilePage()));
        break;
      case 3:
        Navigator.push(
            context, MaterialPageRoute(builder: (_) => const ChatScreen()));
        break;
      case 4:
        _openProjectFolder();
        break;
    }
  }

  Future<void> _openProjectFolder() async {
    final result = await FilePicker.platform.getDirectoryPath();
    if (result != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProjectFolderScreen(path: result),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('Modern Builder')),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const settingsPage.SettingsPage()),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            _buildDashboardGrid(context),
            _buildBottomNavigation(context),
          ],
        ),
      ),
    );
  }
}

Widget _buildHeader(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hello, User',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Colors.black54,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
            ),
            Text(
              'Manage your time',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    fontSize: 18,
                  ),
            ),
          ],
        ),
        GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const profilePage.ProfilePage()),
          ),
          child: CircleAvatar(
            radius: 20,
            backgroundColor: Colors.blue.shade50,
            child:
                const Icon(Icons.person_outline, color: Colors.blue, size: 20),
          ),
        ),
      ],
    ),
  );
}

Widget _buildDashboardGrid(BuildContext context) {
  var _openProjectFolder;
  final List<DashboardItem> dashboardItems = [
    DashboardItem(
      title: 'To do list',
      subtitle: 'All the tasks in this project',
      icon: Icons.task,
      color: Colors.blue,
      value: 5,
      totalValue: 10,
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const tasksPage.TasksPage()),
      ),
    ),
    DashboardItem(
      title: 'Vacations',
      subtitle: 'Vacations C++ Developer',
      icon: Icons.work,
      color: Colors.green,
      value: 3,
      totalValue: 5,
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const workPage.WorkPage()),
      ),
    ),
    DashboardItem(
      title: 'Projects',
      subtitle: 'Last change',
      icon: Icons.folder,
      color: Colors.orange,
      value: 3,
      totalValue: 8,
      onTap: _openProjectFolder,
    ),
  ];

  return Expanded(
    child: GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 3 / 2,
      ),
      itemCount: dashboardItems.length,
      itemBuilder: (context, index) {
        final item = dashboardItems[index];
        return GestureDetector(
          onTap: item.onTap,
          child: GlassmorphicContainer(
            width: double.infinity,
            height: 120,
            borderRadius: 16,
            blur: 8,
            alignment: Alignment.bottomCenter,
            border: 1,
            linearGradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                item.color.withOpacity(0.1),
                item.color.withOpacity(0.05),
              ],
            ),
            borderGradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.5),
                Colors.white.withOpacity(0.2),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(item.icon, color: item.color, size: 24),
                      Text(
                        '${item.value}/${item.totalValue}',
                        style: TextStyle(
                          color: item.color,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.subtitle,
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ),
  );
}

Widget _buildBottomNavigation(BuildContext context) {
  return BottomNavigationBar(
    items: [
      BottomNavigationBarItem(
        icon: Icon(Icons.task, color: Colors.grey.shade600),
        label: 'Tasks',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.home, color: Colors.blue),
        label: 'General',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.person, color: Colors.grey.shade600),
        label: 'Profile',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.chat, color: Colors.grey.shade600),
        label: 'Messenger',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.folder, color: Colors.grey.shade600),
        label: 'Projects',
      ),
    ],
  );
}

// Экран папки проекта
class ProjectFolderScreen extends StatelessWidget {
  final String path;

  const ProjectFolderScreen({required this.path, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Project'),
      ),
      body: Center(
        child: Text('In this path: $path'),
      ),
    );
  }
}

class DashboardItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final int value;
  final int totalValue;
  final VoidCallback onTap;

  DashboardItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.value,
    required this.totalValue,
    required this.onTap,
  });
}

// Экран чата
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<Message> _messages = [];
  final TextEditingController _controller = TextEditingController();

  void _sendMessage() {
    if (_controller.text.isNotEmpty) {
      setState(() {
        _messages.add(
          Message(
            sender: 'User',
            content: _controller.text,
            timestamp: DateTime.now(),
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
                  subtitle: Text(message.content),
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

  Message({
    required this.sender,
    required this.content,
    required this.timestamp,
  });
}
