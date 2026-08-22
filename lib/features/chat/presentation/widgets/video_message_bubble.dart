import 'package:flutter/material.dart';

import 'package:chat_app/core/extensions/theme_extensions.dart';
import 'package:chat_app/features/chat/data/models/message.dart';
//import 'package:chat_app/core/video/widgets/video_message_bubble_controller.dart'; // i add this

class VideoMessageBubble extends StatelessWidget {
  const VideoMessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    this.onTap,
  });

  final VideoMessage message;
  final bool isMe;

  /// Reserved for the future fullscreen video player.
  ///
  /// 4.6.10 only displays the video thumbnail.
  /// Actual playback will be connected later.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final aspectRatio = _aspectRatio;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(minWidth: 220, maxWidth: 300),
        decoration: BoxDecoration(
          color: isMe
              ? context.primaryColor.withValues(alpha: 0.12)
              : (context.isDarkMode
                    ? Colors.white.withValues(alpha: 0.06)
                    : Colors.black.withValues(alpha: 0.04)),
          borderRadius: BorderRadius.circular(16),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _VideoPreview(
              message: message,
              aspectRatio: aspectRatio,
              onTap: onTap,
            ),

            if (message.caption != null && message.caption!.trim().isNotEmpty)
              _VideoCaption(caption: message.caption!, isMe: isMe),
          ],
        ),
      ),
    );
  }

  double get _aspectRatio {
    final width = message.videoWidth;
    final height = message.videoHeight;

    if (width == null || height == null || height <= 0) {
      return 16 / 9;
    }

    final ratio = width / height;

    // Prevent extremely unusual metadata from producing
    // an unusable layout.
    if (ratio < 0.5 || ratio > 2.5) {
      return 16 / 9;
    }

    return ratio;
  }
}

class _VideoPreview extends StatelessWidget {
  const _VideoPreview({
    required this.message,
    required this.aspectRatio,
    required this.onTap,
  });

  final VideoMessage message;
  final double aspectRatio;
  final VoidCallback? onTap;

  @override
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // =======================================================================
        // 🎞️ ELEMENT 1: ACTIVE INSTANCE VIDEO PREVIEW CANVAS FRAME
        // =======================================================================
        GestureDetector(
          onTap: onTap,
          child: AspectRatio(
            aspectRatio: aspectRatio,
            child: Stack(
              fit: StackFit.expand,
              alignment: Alignment.center,
              children: [
                _Thumbnail(thumbnailUrl: message.thumbnailUrl),

                // Dark overlay improves play-button visibility.
                Positioned.fill(
                  child: ColoredBox(
                    color: Colors.black.withValues(alpha: 0.12),
                  ),
                ),

                const _PlayButton(),

                if (message.videoDurationMs != null)
                  Positioned(
                    right: 8,
                    bottom: 8,
                    child: _DurationBadge(durationMs: message.videoDurationMs!),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({required this.thumbnailUrl});

  final String? thumbnailUrl;

  @override
  Widget build(BuildContext context) {
    final url = thumbnailUrl;

    if (url == null || url.isEmpty) {
      return const _ThumbnailPlaceholder();
    }

    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        debugPrint('❌ Video thumbnail failed to load: $error');

        return const _ThumbnailPlaceholder();
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) {
          return child;
        }

        return const _ThumbnailPlaceholder(showProgress: true);
      },
    );
  }
}

class _ThumbnailPlaceholder extends StatelessWidget {
  const _ThumbnailPlaceholder({this.showProgress = false});

  final bool showProgress;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black26,
      alignment: Alignment.center,
      child: showProgress
          ? const CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            )
          : const Icon(
              Icons.video_library_outlined,
              color: Colors.white70,
              size: 42,
            ),
    );
  }
}

class _PlayButton extends StatelessWidget {
  const _PlayButton();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.55),
        shape: BoxShape.circle,
      ),
      child: const Padding(
        padding: EdgeInsets.all(8),
        child: Icon(Icons.play_arrow_rounded, color: Colors.white, size: 40),
      ),
    );
  }
}

class _DurationBadge extends StatelessWidget {
  const _DurationBadge({required this.durationMs});

  final int durationMs;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        child: Text(
          _formatDuration(durationMs),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  String _formatDuration(int milliseconds) {
    final totalSeconds = (milliseconds / 1000).round();

    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;

    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}

class _VideoCaption extends StatelessWidget {
  const _VideoCaption({required this.caption, required this.isMe});

  final String caption;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          caption,
          style: TextStyle(
            color: context.isDarkMode ? Colors.white : Colors.black87,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
