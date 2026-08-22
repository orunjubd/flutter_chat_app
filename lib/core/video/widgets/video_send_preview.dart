import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import 'package:chat_app/core/media/models/media_draft.dart';
import 'package:chat_app/core/video/providers/video_upload_progress_provider.dart';

class VideoSendPreview extends ConsumerStatefulWidget {
  const VideoSendPreview({
    super.key,
    required this.draft,
    required this.onSend,
    this.thumbnailFile,
    this.onCancel,
  });

  final MediaDraft draft;
  final Future<void> Function(MediaDraft draft) onSend;
  final File? thumbnailFile;
  final VoidCallback? onCancel;

  @override
  ConsumerState<VideoSendPreview> createState() => _VideoSendPreviewState();
}

class _VideoSendPreviewState extends ConsumerState<VideoSendPreview> {
  late final TextEditingController _captionController;

  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _captionController = TextEditingController(text: widget.draft.caption);
  }

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (_sending) return;

    setState(() {
      _sending = true;
    });

    final caption = _captionController.text.trim();
    final updatedDraft = widget.draft.copyWith(caption: caption);

    try {
      await widget.onSend(updatedDraft);

      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _sending = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to send video: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final uploadProgress = ref.watch(videoUploadProgressProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Send video'),
        leading: IconButton(
          onPressed: _sending
              ? null
              : () {
                  widget.onCancel?.call();
                  Navigator.of(context).pop();
                },
          icon: const Icon(Icons.close),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  _LocalVideoPreview(
                    videoFile: widget.draft.file,
                    thumbnailFile: widget.thumbnailFile,
                  ),

                  /// ===========================================================================
                  /// Video Upload Progress indicator
                  /// ============================================================================
                  if (uploadProgress.isUploading)
                    Positioned(
                      top: 20,
                      right: 20,
                      child: _VideoUploadProgressIndicator(
                        percentage: uploadProgress.percentage,
                      ),
                    ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _captionController,
                      enabled: !_sending,
                      maxLines: 4,
                      minLines: 1,
                      textInputAction: TextInputAction.newline,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Add a caption...',
                        hintStyle: const TextStyle(color: Colors.white60),
                        filled: true,
                        fillColor: Colors.white12,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _sending ? null : _send,
                    icon: _sending
                        ? const Icon(Icons.cloud_upload)
                        : const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VideoUploadProgressIndicator extends StatelessWidget {
  const _VideoUploadProgressIndicator({required this.percentage});

  final int percentage;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 110,
      height: 110,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.72),
        shape: BoxShape.circle,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 78,
            height: 78,
            child: CircularProgressIndicator(
              value: percentage / 100,
              strokeWidth: 5,
              color: Colors.red,
              backgroundColor: Colors.white24,
            ),
          ),

          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$percentage%',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'Uploading',
                style: TextStyle(color: Colors.white70, fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Local-file video preview, shown before upload. Displays the
/// generated local thumbnail immediately (cheap, instant) and only
/// initializes a real VideoPlayerController once tapped, to avoid
/// spinning up a decoder the user may never actually play.
class _LocalVideoPreview extends StatefulWidget {
  const _LocalVideoPreview({required this.videoFile, this.thumbnailFile});

  final File videoFile;
  final File? thumbnailFile;

  @override
  State<_LocalVideoPreview> createState() => _LocalVideoPreviewState();
}

class _LocalVideoPreviewState extends State<_LocalVideoPreview> {
  VideoPlayerController? _controller;
  bool _isPlaying = false;

  Future<void> _startPlayback() async {
    final controller = VideoPlayerController.file(widget.videoFile);
    _controller = controller;
    await controller.initialize();
    if (!mounted) {
      await controller.dispose();
      return;
    }
    await controller.play();
    setState(() => _isPlaying = true);
  }

  Future<void> _togglePlayback() async {
    final controller = _controller;
    if (controller == null) {
      await _startPlayback();
      return;
    }
    if (controller.value.isPlaying) {
      await controller.pause();
    } else {
      await controller.play();
    }
    if (!mounted) return;
    setState(() {});
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    final isReady = controller != null && controller.value.isInitialized;

    return GestureDetector(
      onTap: _togglePlayback,
      child: Center(
        child: isReady
            ? FittedBox(
                fit: BoxFit.contain,
                child: SizedBox(
                  width: controller.value.size.width,
                  height: controller.value.size.height,
                  child: VideoPlayer(controller),
                ),
              )
            : Stack(
                alignment: Alignment.center,
                children: [
                  if (widget.thumbnailFile != null)
                    Positioned.fill(
                      child: Image.file(
                        widget.thumbnailFile!,
                        fit: BoxFit.contain,
                      ),
                    ),
                  Icon(
                    _isPlaying ? Icons.pause_circle : Icons.play_circle,
                    color: Colors.white70,
                    size: 64,
                  ),
                ],
              ),
      ),
    );
  }
}
