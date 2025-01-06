import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'profile_edit_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late VideoPlayerController _videoController;
  VideoPlayerStatus _videoStatus = VideoPlayerStatus.loading;
  String _username = "Garbage Collector";
  Color _backgroundColor = Colors.blueAccent;

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer();
  }

  Future<void> _initializeVideoPlayer() async {
    try {
      _videoController = VideoPlayerController.asset(
        'lib/assets/folder/lol.mp4',
      );

      await _videoController.initialize();
      _videoController.setLooping(true);
      _videoController.setVolume(0.0);

      if (mounted) {
        setState(() {
          _videoStatus = VideoPlayerStatus.initialized;
        });
        _videoController.play();
      }
    } catch (e) {
      debugPrint('Video Initialization Error: $e');
      if (mounted) {
        setState(() {
          _videoStatus = VideoPlayerStatus.error;
        });
      }
    }
  }

  @override
  void dispose() {
    _videoController.dispose();
    super.dispose();
  }

  void _showEditProfileDialog() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ProfileEditPage(
          initialUsername: _username,
          initialBackgroundColor: _backgroundColor,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _username = result['username'];
        _backgroundColor = result['backgroundColor'];
      });
    }
  }

  void _showProfileMenu(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Profile Logo
                CircleAvatar(
                  radius: 50,
                  backgroundColor: _backgroundColor,
                  child: Text(
                    _username,
                    style: const TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 16),
                // Profile Greeting
                const Text(
                  "Вітаємо в профілі!",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                // Profile Edit Button
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _showEditProfileDialog();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 24),
                  ),
                  child: const Text(
                    "Редагувати профіль",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Video
          Positioned.fill(
            child: Container(
              color: Colors.black,
              child: _videoStatus == VideoPlayerStatus.initialized
                  ? VideoPlayer(_videoController)
                  : const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
            ),
          ),
          // Profile Menu in the Top-Right Corner
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: () => _showProfileMenu(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(12),
                  ),
                  child: const Icon(
                    Icons.person,
                    color: Colors.blueAccent,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Enum to track video player status
enum VideoPlayerStatus {
  loading,
  initialized,
  error,
}
