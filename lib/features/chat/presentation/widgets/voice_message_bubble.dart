import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:chat_app/core/extensions/theme_extensions.dart';
import 'package:chat_app/features/chat/data/models/message.dart';
import 'package:chat_app/core/media/providers/voice_player_provider.dart';
import 'package:chat_app/core/media/services/voice_player_service.dart';

class VoiceMessageBubble extends ConsumerWidget {
  const VoiceMessageBubble({
    super.key,
    required this.message,
    required this.isMe,
  });

  final LegacyMessage message;
  final bool isMe;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final voiceUrl = message.voiceUrl;

    if (voiceUrl == null || voiceUrl.isEmpty) {
      return _UnavailableVoiceBubble(context: context, isMe: isMe);
    }

    // Services are read, not watched.
    final player = ref.read(voicePlayerServiceProvider);

    return StreamBuilder<String?>(
      stream: player.currentUrlStream,
      initialData: player.currentUrl,
      builder: (context, urlSnapshot) {
        final activeUrl = urlSnapshot.data;
        final isCurrentVoice = activeUrl == voiceUrl;

        return StreamBuilder<bool>(
          stream: player.playingStream,
          initialData: player.isPlaying,
          builder: (context, playingSnapshot) {
            final isPlaying = isCurrentVoice && playingSnapshot.data == true;

            return _VoiceBubbleContainer(
              context: context,
              isMe: isMe,
              child: Row(
                children: [
                  _PlayPauseButton(
                    isPlaying: isPlaying,
                    isMe: isMe,
                    onPressed: () => _togglePlayback(context, ref, voiceUrl),
                  ),
                  const SizedBox(width: 4),

                  Expanded(
                    child: isCurrentVoice
                        ? _ActiveVoiceProgress(
                            context: context,
                            ref: ref,
                            player: player,
                            voiceUrl: voiceUrl,
                            message: message,
                            isPlaying: isPlaying,
                            isMe: isMe,
                          )
                        : _StaticVoiceProgress(
                            context: context,
                            message: message,
                            isMe: isMe,
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _togglePlayback(
    BuildContext context,
    WidgetRef ref,
    String url,
  ) async {
    try {
      final player = ref.read(voicePlayerServiceProvider);

      if (player.currentUrl == url && player.isPlaying) {
        await player.pause();
      } else {
        await player.play(url);
      }
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to play voice message: $e')),
      );
    }
  }
}

/// Active voice only.
///
/// IMPORTANT:
/// This is the only widget that subscribes to positionStream.
/// Inactive voice bubbles never create this widget.
class _ActiveVoiceProgress extends StatefulWidget {
  const _ActiveVoiceProgress({
    required this.context,
    required this.ref,
    required this.player,
    required this.voiceUrl,
    required this.message,
    required this.isPlaying,
    required this.isMe,
  });

  final BuildContext context;
  final WidgetRef ref;
  final VoicePlayerService player;
  final String voiceUrl;
  final LegacyMessage message;
  final bool isPlaying;
  final bool isMe;

  @override
  State<_ActiveVoiceProgress> createState() => _ActiveVoiceProgressState();
}

class _ActiveVoiceProgressState extends State<_ActiveVoiceProgress> {
  bool _isSeeking = false;
  double? _dragPosition;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Duration?>(
      stream: widget.player.durationStream,
      initialData: widget.player.duration,
      builder: (context, durationSnapshot) {
        final playerDuration = durationSnapshot.data;

        final metadataDurationMs = widget.message.voiceDurationMs ?? 0;

        final metadataDuration = metadataDurationMs > 0
            ? Duration(milliseconds: metadataDurationMs)
            : Duration.zero;

        // Prefer actual player duration when available.
        final resolvedDuration =
            playerDuration != null && playerDuration.inMilliseconds > 0
            ? playerDuration
            : metadataDuration;

        final totalMilliseconds = resolvedDuration.inMilliseconds;

        return StreamBuilder<Duration>(
          stream: widget.player.positionStream,
          initialData: widget.player.position,
          builder: (context, positionSnapshot) {
            final streamPosition = positionSnapshot.data ?? Duration.zero;

            final streamMilliseconds = streamPosition.inMilliseconds
                .clamp(0, totalMilliseconds > 0 ? totalMilliseconds : 1)
                .toDouble();

            final sliderValue = _isSeeking && _dragPosition != null
                ? _dragPosition!
                      .clamp(0, totalMilliseconds > 0 ? totalMilliseconds : 1)
                      .toDouble()
                : streamMilliseconds;

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _ProgressSlider(
                  value: sliderValue,
                  maximum: totalMilliseconds > 0
                      ? totalMilliseconds.toDouble()
                      : 1.0,
                  enabled: totalMilliseconds > 0,
                  isMe: widget.isMe,
                  onChangeStart: totalMilliseconds > 0
                      ? (value) {
                          _onSeekStart(value);
                        }
                      : null,
                  onChanged: totalMilliseconds > 0
                      ? (value) {
                          _onSeekChanged(value);
                        }
                      : null,
                  onChangeEnd: totalMilliseconds > 0
                      ? (value) {
                          _onSeekEnd(value, widget.voiceUrl);
                        }
                      : null,
                ),
                _TimeRow(
                  context: context,
                  currentMilliseconds: _isSeeking && _dragPosition != null
                      ? _dragPosition!.round()
                      : streamMilliseconds.round(),
                  totalMilliseconds: totalMilliseconds,
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _onSeekStart(double value) {
    if (!mounted) return;

    setState(() {
      _isSeeking = true;
      _dragPosition = value;
    });
  }

  void _onSeekChanged(double value) {
    if (!mounted) return;

    setState(() {
      _dragPosition = value;
    });
  }

  Future<void> _onSeekEnd(double value, String voiceUrl) async {
    final player = widget.ref.read(voicePlayerServiceProvider);

    // Re-check the active URL at the moment the seek completes.
    // Do not trust an old build-time captured state.
    if (player.currentUrl != voiceUrl) {
      if (!mounted) return;

      setState(() {
        _isSeeking = false;
        _dragPosition = null;
      });

      return;
    }

    try {
      await player.seek(Duration(milliseconds: value.round()));
    } catch (e) {
      if (!widget.context.mounted) return;

      ScaffoldMessenger.of(widget.context).showSnackBar(
        SnackBar(content: Text('Unable to seek voice message: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSeeking = false;
          _dragPosition = null;
        });
      }
    }
  }
}

/// Inactive voice bubble.
///
/// IMPORTANT:
/// There is NO positionStream subscription here.
class _StaticVoiceProgress extends StatelessWidget {
  const _StaticVoiceProgress({
    required this.context,
    required this.message,
    required this.isMe,
  });

  final BuildContext context;
  final LegacyMessage message;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    final totalMilliseconds = _safeDuration(message.voiceDurationMs ?? 0);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ProgressSlider(
          value: 0,
          maximum: totalMilliseconds > 0 ? totalMilliseconds.toDouble() : 1.0,
          enabled: false,
          isMe: isMe,
          onChangeStart: null,
          onChanged: null,
          onChangeEnd: null,
        ),
        _TimeRow(
          context: context,
          currentMilliseconds: 0,
          totalMilliseconds: totalMilliseconds,
        ),
      ],
    );
  }
}

class _PlayPauseButton extends StatelessWidget {
  const _PlayPauseButton({
    required this.isPlaying,
    required this.isMe,
    required this.onPressed,
  });

  final bool isPlaying;
  final bool isMe;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: isPlaying ? 'Pause voice message' : 'Play voice message',
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(
          isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
        ),
        iconSize: 38,
        color: isMe ? context.primaryColor : context.textSecondaryColor,
        tooltip: isPlaying ? 'Pause voice message' : 'Play voice message',
      ),
    );
  }
}

class _ProgressSlider extends StatelessWidget {
  const _ProgressSlider({
    required this.value,
    required this.maximum,
    required this.enabled,
    required this.isMe,
    required this.onChangeStart,
    required this.onChanged,
    required this.onChangeEnd,
  });

  final double value;
  final double maximum;
  final bool enabled;
  final bool isMe;
  final ValueChanged<double>? onChangeStart;
  final ValueChanged<double>? onChanged;
  final ValueChanged<double>? onChangeEnd;

  @override
  Widget build(BuildContext context) {
    final safeMaximum = maximum > 0 ? maximum : 1.0;

    final safeValue = value.clamp(0.0, safeMaximum);

    return Semantics(
      slider: true,
      label: 'Voice message progress',
      value: '${safeValue.round()} milliseconds',
      child: Slider(
        value: safeValue,
        min: 0,
        max: safeMaximum,
        onChangeStart: enabled ? onChangeStart : null,
        onChanged: enabled ? onChanged : null,
        onChangeEnd: enabled ? onChangeEnd : null,
      ),
    );
  }
}

class _TimeRow extends StatelessWidget {
  const _TimeRow({
    required this.context,
    required this.currentMilliseconds,
    required this.totalMilliseconds,
  });

  final BuildContext context;
  final int currentMilliseconds;
  final int totalMilliseconds;

  @override
  Widget build(BuildContext context) {
    final current = _safeDuration(currentMilliseconds);
    final total = _safeDuration(totalMilliseconds);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          _formatDuration(current),
          style: this.context.captionText?.copyWith(
            color: this.context.textSecondaryColor,
          ),
        ),
        Text(
          _formatDuration(total),
          style: this.context.captionText?.copyWith(
            color: this.context.textSecondaryColor,
          ),
        ),
      ],
    );
  }
}

class _VoiceBubbleContainer extends StatelessWidget {
  const _VoiceBubbleContainer({
    required this.context,
    required this.isMe,
    required this.child,
  });

  final BuildContext context;
  final bool isMe;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 220, maxWidth: 300),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: isMe
            ? this.context.primaryColor.withValues(alpha: 0.12)
            : this.context.isDarkMode
            ? Colors.white.withValues(alpha: 0.06)
            : Colors.black.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }
}

class _UnavailableVoiceBubble extends StatelessWidget {
  const _UnavailableVoiceBubble({required this.context, required this.isMe});

  final BuildContext context;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    return _VoiceBubbleContainer(
      context: this.context,
      isMe: isMe,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.mic_off_outlined, color: this.context.textSecondaryColor),
          const SizedBox(width: 8),
          Text(
            'Voice message unavailable',
            style: this.context.bodyTextMedium?.copyWith(
              color: this.context.textSecondaryColor,
            ),
          ),
        ],
      ),
    );
  }
}

int _safeDuration(int milliseconds) {
  return milliseconds < 0 ? 0 : milliseconds;
}

String _formatDuration(int milliseconds) {
  final safeMilliseconds = _safeDuration(milliseconds);

  final duration = Duration(milliseconds: safeMilliseconds);

  final minutes = duration.inMinutes.toString().padLeft(2, '0');

  final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');

  return '$minutes:$seconds';
}
