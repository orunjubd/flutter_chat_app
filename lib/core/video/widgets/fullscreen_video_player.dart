// core/video/widgets/fullscreen_video_player.dart
import 'package:flutter/material.dart';
import 'package:chat_app/features/chat/data/models/message.dart';
import 'package:chat_app/core/video/widgets/video_message_bubble_controller.dart';

class FullscreenVideoPlayer extends StatelessWidget {
  const FullscreenVideoPlayer({super.key, required this.message});

  final VideoMessage message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Video Player'),
        //elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(child: VideoMessageBubbleController(message: message)),
    );
  }
}
