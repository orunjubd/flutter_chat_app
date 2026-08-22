import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import 'package:chat_app/features/chat/data/models/message.dart';

class VideoMessageBubbleController extends StatefulWidget {
  const VideoMessageBubbleController({super.key, required this.message});

  final VideoMessage message;

  @override
  State<VideoMessageBubbleController> createState() =>
      _VideoMessageBubbleControllerState();
}

class _VideoMessageBubbleControllerState
    extends State<VideoMessageBubbleController> {
  VideoPlayerController? _controller;

  bool _isInitializing = true;
  bool _hasError = false;
  String? _errorMessage;

  bool _isMuted = false;
  bool _isCompleted = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  // ---------------------------------------------------------------------------
  // Initialization
  // ---------------------------------------------------------------------------

  Future<void> _initialize() async {
    final url = widget.message.videoUrl;

    if (url.isEmpty) {
      _setError('Video URL is missing.');
      return;
    }

    try {
      final controller = VideoPlayerController.networkUrl(Uri.parse(url));

      _controller = controller;

      await controller.initialize();

      if (!mounted) {
        await controller.dispose();
        return;
      }

      // Listen for position, buffering, completion, etc.
      controller.addListener(_handleControllerUpdate);

      setState(() {
        _isInitializing = false;
        _hasError = false;
        _errorMessage = null;
      });
    } catch (e, stackTrace) {
      debugPrint('❌ Video initialization failed: $e');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      setState(() {
        _isInitializing = false;
        _hasError = true;
        _errorMessage = e.toString();
      });
    }
  }

  // ---------------------------------------------------------------------------
  // Controller state listener
  // ---------------------------------------------------------------------------

  void _handleControllerUpdate() {
    final controller = _controller;

    if (controller == null || !mounted) {
      return;
    }

    final value = controller.value;

    final completed =
        value.isInitialized &&
        value.duration > Duration.zero &&
        value.position >= value.duration;

    if (completed != _isCompleted) {
      setState(() {
        _isCompleted = completed;
      });
      return;
    }

    // Rebuild UI for:
    // - position changes
    // - play/pause
    // - buffering
    // - volume changes
    // - completion
    setState(() {});
  }

  void _setError(String message) {
    debugPrint('❌ Video player error: $message');
    if (!mounted) return;
    setState(() {
      _isInitializing = false;
      _hasError = true;
      _errorMessage = message;
    });
  }

  // ---------------------------------------------------------------------------
  // Play / Pause
  // ---------------------------------------------------------------------------

  Future<void> _togglePlayback() async {
    final controller = _controller;

    if (controller == null || !controller.value.isInitialized) {
      return;
    }

    try {
      if (_isCompleted) {
        await controller.seekTo(Duration.zero);
        _isCompleted = false;
      }

      if (controller.value.isPlaying) {
        await controller.pause();
      } else {
        await controller.play();
      }

      if (!mounted) return;

      setState(() {});
    } catch (e, stackTrace) {
      debugPrint('❌ Video playback error: $e');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  // ---------------------------------------------------------------------------
  // Seek
  // ---------------------------------------------------------------------------

  Future<void> _seekTo(double value) async {
    final controller = _controller;

    if (controller == null || !controller.value.isInitialized) {
      return;
    }

    final duration = controller.value.duration;

    final position = Duration(
      milliseconds: (duration.inMilliseconds * value).round(),
    );

    try {
      await controller.seekTo(position);

      if (mounted) {
        setState(() {
          _isCompleted = false;
        });
      }
    } catch (e) {
      debugPrint('❌ Video seek failed: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // Mute / Unmute
  // ---------------------------------------------------------------------------

  Future<void> _toggleMute() async {
    final controller = _controller;

    if (controller == null || !controller.value.isInitialized) {
      return;
    }

    try {
      if (_isMuted) {
        await controller.setVolume(1.0);
      } else {
        await controller.setVolume(0.0);
      }

      if (!mounted) return;

      setState(() {
        _isMuted = !_isMuted;
      });
    } catch (e) {
      debugPrint('❌ Video mute/unmute failed: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // Retry
  // ---------------------------------------------------------------------------

  Future<void> _retry() async {
    final oldController = _controller;

    if (oldController != null) {
      oldController.removeListener(_handleControllerUpdate);
      await oldController.dispose();
    }

    _controller = null;

    if (!mounted) return;

    setState(() {
      _isInitializing = true;
      _hasError = false;
      _errorMessage = null;
      _isMuted = false;
      _isCompleted = false;
    });

    await _initialize();
  }

  // ---------------------------------------------------------------------------
  // Formatting
  // ---------------------------------------------------------------------------

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '$hours:'
          '${minutes.toString().padLeft(2, '0')}:'
          '${seconds.toString().padLeft(2, '0')}';
    }

    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  // ---------------------------------------------------------------------------
  // Dispose
  // ---------------------------------------------------------------------------

  @override
  void dispose() {
    debugPrint('🧹 Disposing video player controller.');
    final controller = _controller;

    if (controller != null) {
      controller.removeListener(_handleControllerUpdate);
      controller.dispose();
    }

    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    if (_isInitializing) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_hasError) {
      return _ErrorView(message: _errorMessage, onRetry: _retry);
    }

    final controller = _controller;

    if (controller == null || !controller.value.isInitialized) {
      return _ErrorView(
        message: 'Video player is not initialized.',
        onRetry: _retry,
      );
    }

    final value = controller.value;
    final duration = value.duration;
    final position = value.position > duration ? duration : value.position;

    final progress = duration.inMilliseconds > 0
        ? position.inMilliseconds / duration.inMilliseconds
        : 0.0;

    final videoSize = value.size;
    final hasValidSize = videoSize.width > 0 && videoSize.height > 0;

    return Column(
      // mainAxisSize.max (default) is required for Expanded to work below —
      // this relies on the ancestor (FullscreenVideoPlayer's Scaffold body)
      // giving this Column a bounded height, which it already does.
      mainAxisSize: MainAxisSize.min,
      children: [
        // ---------------------------------------------------------------
        // Video — takes whatever vertical space remains after the fixed
        // controls bar below it, and fits the video within that space on
        // BOTH axes (unlike AspectRatio, which only respects width).
        // ---------------------------------------------------------------
        Expanded(
          child: Center(
            child: FittedBox(
              fit: BoxFit.contain,
              child: SizedBox(
                width: hasValidSize ? videoSize.width : 16,
                height: hasValidSize ? videoSize.height : 9,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    VideoPlayer(controller),
                    if (value.isBuffering)
                      const CircularProgressIndicator(color: Colors.white),
                    _PlayPauseButton(
                      isPlaying: value.isPlaying,
                      isCompleted: _isCompleted,
                      onPressed: _togglePlayback,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // ---------------------------------------------------------------
        // Controls — fixed height, always fully visible regardless of
        // how much (or little) space the video above ends up using.
        // ---------------------------------------------------------------
        Container(
          color: Colors.black,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Column(
            children: [
              // Seek bar
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 3,
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 6,
                  ),
                ),
                child: Slider(
                  value: progress.clamp(0.0, 1.0),
                  min: 0.0,
                  max: 1.0,
                  onChanged: duration == Duration.zero ? null : _seekTo,
                ),
              ),

              Row(
                children: [
                  // Current position
                  Text(
                    _formatDuration(position),
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),

                  const Text(
                    ' / ',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),

                  // Duration
                  Text(
                    _formatDuration(duration),
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),

                  const Spacer(),

                  // Mute / unmute
                  IconButton(
                    tooltip: _isMuted ? 'Unmute' : 'Mute',
                    onPressed: _toggleMute,
                    icon: Icon(
                      _isMuted
                          ? Icons.volume_off_rounded
                          : Icons.volume_up_rounded,
                      color: Colors.white,
                    ),
                  ),

                  // Play / pause
                  IconButton(
                    tooltip: value.isPlaying ? 'Pause' : 'Play',
                    onPressed: _togglePlayback,
                    icon: Icon(
                      value.isPlaying
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// Play / Pause button
// ============================================================================

class _PlayPauseButton extends StatelessWidget {
  const _PlayPauseButton({
    required this.isPlaying,
    required this.isCompleted,
    required this.onPressed,
  });

  final bool isPlaying;
  final bool isCompleted;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black54,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Icon(
            isCompleted
                ? Icons.replay_rounded
                : isPlaying
                ? Icons.pause_rounded
                : Icons.play_arrow_rounded,
            color: Colors.white,
            size: 38,
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// Error view
// ============================================================================

class _ErrorView extends StatelessWidget {
  const _ErrorView({this.message, this.onRetry});

  final String? message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.white70, size: 40),
            const SizedBox(height: 8),
            const Text(
              'Unable to load video',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (message != null) ...[
              const SizedBox(height: 8),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white60, fontSize: 12),
              ),
            ],
            if (onRetry != null) ...[
              const SizedBox(height: 12),
              TextButton(onPressed: onRetry, child: const Text('Retry')),
            ],
          ],
        ),
      ),
    );
  }
}
