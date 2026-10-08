import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Animated sine-wave indicator used to show active voice/speaking state.
///
/// When [active] is false, the wave becomes a flat line.
/// The animation automatically stops while inactive to reduce unnecessary work.
class SineWave extends StatefulWidget {
  const SineWave({
    super.key,
    required this.active,
    required this.color,
    this.height = 28,
    this.strokeWidth = 2,
  });

  final bool active;
  final Color color;

  /// Height of the waveform.
  final double height;

  /// Stroke width of the waveform.
  final double strokeWidth;

  @override
  State<SineWave> createState() => _SineWaveState();
}

class _SineWaveState extends State<SineWave>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    _updateAnimation();
  }

  @override
  void didUpdateWidget(covariant SineWave oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.active != widget.active) {
      _updateAnimation();
    }
  }

  void _updateAnimation() {
    if (widget.active) {
      _controller.repeat();
    } else {
      _controller.stop();
      _controller.value = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: widget.active ? 1 : 0),
      duration: const Duration(milliseconds: 250),
      builder: (context, amplitude, child) {
        return SizedBox(
          height: widget.height,
          width: double.infinity,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                painter: _WavePainter(
                  phase: _controller.value * 2 * math.pi,
                  amplitude: amplitude,
                  color: widget.color,
                  strokeWidth: widget.strokeWidth,
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _WavePainter extends CustomPainter {
  const _WavePainter({
    required this.phase,
    required this.amplitude,
    required this.color,
    required this.strokeWidth,
  });

  final double phase;
  final double amplitude;
  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) {
      return;
    }

    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();

    final centerY = size.height / 2;
    final amplitudeHeight = centerY * 0.8 * amplitude;

    const cycles = 2;

    for (double x = 0; x <= size.width; x++) {
      final normalizedX = x / size.width;

      final y =
          centerY +
          math.sin(normalizedX * cycles * 2 * math.pi + phase) *
              amplitudeHeight;

      if (x == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _WavePainter oldDelegate) {
    return oldDelegate.phase != phase ||
        oldDelegate.amplitude != amplitude ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
