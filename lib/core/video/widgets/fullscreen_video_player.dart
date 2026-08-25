import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:share_plus/share_plus.dart';

import 'package:chat_app/features/chat/data/models/message.dart';
import 'package:chat_app/core/video/widgets/video_message_bubble_controller.dart';
import 'package:chat_app/core/media/services/media_share_service.dart';
import 'package:chat_app/core/media/widgets/share_choice_sheet.dart';

class FullscreenVideoPlayer extends StatefulWidget {
  const FullscreenVideoPlayer({super.key, required this.message});

  final VideoMessage message;

  @override
  State<FullscreenVideoPlayer> createState() => _FullscreenVideoPlayerState();
}

class _FullscreenVideoPlayerState extends State<FullscreenVideoPlayer> {
  final _shareService = const MediaShareService();
  double? _progress; // null = idle

  Future<void> _handleShare() async {
    final choice = await showShareChoiceSheet(context);
    if (choice == null) return;

    if (choice == ShareChoice.link) {
      await SharePlus.instance.share(
        ShareParams(text: widget.message.videoUrl),
      );
      return;
    }

    await _download((file) async {
      await SharePlus.instance.share(
        ShareParams(files: [XFile(file.path)], text: 'Video'),
      );
    });
  }

  Future<void> _handleSave() async {
    final hasAccess = await Gal.hasAccess() || await Gal.requestAccess();
    if (!hasAccess) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Gallery access denied.')));
      return;
    }

    await _download((file) async {
      await Gal.putVideo(file.path);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Saved to gallery.')));
    });
  }

  Future<void> _download(Future<void> Function(File file) onDone) async {
    setState(() => _progress = 0);
    try {
      final fileName = _shareService.fileNameFromUrl(
        widget.message.videoUrl,
        fallback: 'video.mp4',
      );
      final file = await _shareService.downloadToTempFile(
        widget.message.videoUrl,
        fileName: fileName,
        onProgress: (received, total) {
          if (total != null && total > 0 && mounted) {
            setState(() => _progress = received / total);
          }
        },
      );
      if (!mounted) return;
      await onDone(file);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed: $e')));
    } finally {
      if (mounted) setState(() => _progress = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isBusy = _progress != null;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (isBusy)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: Text(
                  '${((_progress ?? 0) * 100).round()}%',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            )
          else ...[
            IconButton(
              icon: const Icon(Icons.download_outlined, color: Colors.white),
              onPressed: _handleSave,
            ),
            IconButton(
              icon: const Icon(Icons.share_outlined, color: Colors.white),
              onPressed: _handleShare,
            ),
          ],
        ],
      ),
      body: Center(
        child: VideoMessageBubbleController(message: widget.message),
      ),
    );
  }
}
