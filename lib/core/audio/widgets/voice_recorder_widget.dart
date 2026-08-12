import 'dart:io';

import 'package:chat_app/core/audio/models/voice_recording.dart';
import 'package:chat_app/core/audio/providers/audio_recorder_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:chat_app/core/audio/services/audio_recorder_service.dart';
//import 'package:chat_app/core/audio/providers/audio_recorder_provider.dart';

class VoiceRecorderWidget extends ConsumerStatefulWidget {
  const VoiceRecorderWidget({
    super.key,
    required this.onRecordingComplete,
    this.onCancel,
  });

  final ValueChanged<VoiceRecording> onRecordingComplete;
  final VoidCallback? onCancel;

  @override
  ConsumerState<VoiceRecorderWidget> createState() =>
      _VoiceRecorderWidgetState();
}

class _VoiceRecorderWidgetState extends ConsumerState<VoiceRecorderWidget> {
  AudioRecorderService get _recorder => ref.read(audioRecorderServiceProvider);

  String? _recordingPath;
  bool _isRecording = false;
  bool _isStopping = false;

  DateTime? _recordingStartedAt;
  Duration _duration = Duration.zero;

  @override
  void initState() {
    super.initState();

    debugPrint('🎙️ [VoiceUI] VoiceRecorderWidget initialized.');
  }

  @override
  void dispose() {
    debugPrint('🧼 [VoiceUI] VoiceRecorderWidget disposed.');
    super.dispose();
  }

  Future<void> _startRecording() async {
    if (_isRecording || _isStopping) {
      debugPrint(
        '⚠️ [VoiceUI] Recording request ignored because another '
        'recording operation is already active.',
      );
      return;
    }

    try {
      debugPrint('🎙️ [VoiceUI] User requested voice recording.');

      final permissionGranted = await _recorder.hasPermission();

      if (!permissionGranted) {
        debugPrint('❌ [VoiceUI] Microphone permission was not granted.');

        if (!mounted) return;

        _showMessage(
          'Microphone permission is required to record voice messages.',
        );

        return;
      }

      final path = await _recorder.startRecording();

      if (!mounted) return;

      setState(() {
        _isRecording = true;
        _recordingStartedAt = DateTime.now();
        _duration = Duration.zero;
        _recordingPath = path;
      });

      debugPrint('✅ [VoiceUI] Recording started.');
      debugPrint('📂 [VoiceUI] Temporary path: $path');

      _startDurationTicker();
    } catch (e, stackTrace) {
      debugPrint('💥 [VoiceUI] Failed to start recording: $e');
      debugPrint('$stackTrace');

      if (!mounted) return;

      _showMessage('Unable to start voice recording.');
    }
  }

  void _startDurationTicker() {
    Future<void>.delayed(const Duration(milliseconds: 100), () {
      if (!mounted || !_isRecording || _recordingStartedAt == null) {
        return;
      }

      setState(() {
        _duration = DateTime.now().difference(_recordingStartedAt!);
      });

      _startDurationTicker();
    });
  }

  Future<void> _stopRecording() async {
    if (!_isRecording) return;

    debugPrint('🛑 [VoiceUI] User stopped recording.');

    try {
      final path = await ref.read(audioRecorderServiceProvider).stopRecording();

      if (path == null) {
        debugPrint('⚠️ [VoiceUI] Recording stopped but path was null.');
        return;
      }

      final file = File(path);

      if (!await file.exists()) {
        debugPrint('❌ [VoiceUI] Recording file does not exist.');
        return;
      }

      final fileSize = await file.length();

      final recording = VoiceRecording(
        path: path,
        duration: _duration,
        fileSize: fileSize,
        mimeType: 'audio/mp4',
        waveform: const [],
      );

      debugPrint('✅ [VoiceUI] Recording completed.');
      debugPrint('📂 [VoiceUI] Final path: $path');
      debugPrint('📦 [VoiceUI] Bytes: $fileSize');
      debugPrint(
        '⏱️ [VoiceUI] Duration: '
        '${_duration.inMinutes.toString().padLeft(2, '0')}:'
        '${(_duration.inSeconds % 60).toString().padLeft(2, '0')}',
      );

      if (!mounted) return;

      widget.onRecordingComplete(recording);
    } catch (e, stackTrace) {
      debugPrint('💥 [VoiceUI] Failed to stop recording: $e');
      debugPrint('$stackTrace');
    }
  }

  Future<void> _cancelRecording() async {
    if (!_isRecording || _isStopping) {
      return;
    }

    debugPrint('🗑️ [VoiceUI] User cancelled recording.');

    try {
      await _recorder.cancelRecording();

      if (!mounted) return;

      setState(() {
        _isRecording = false;
        _isStopping = false;
        _recordingStartedAt = null;
        _duration = Duration.zero;
        _recordingPath = null;
      });

      debugPrint('✅ [VoiceUI] Recording cancelled safely.');

      widget.onCancel?.call();
    } catch (e, stackTrace) {
      debugPrint('💥 [VoiceUI] Failed to cancel recording: $e');
      debugPrint('$stackTrace');
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');

    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');

    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    if (!_isRecording) {
      return _buildMicrophoneButton();
    }

    return _buildRecordingControls();
  }

  Widget _buildMicrophoneButton() {
    return IconButton(
      tooltip: 'Record voice message',
      onPressed: _startRecording,
      icon: const Icon(Icons.mic),
    );
  }

  Widget _buildRecordingControls() {
    if (_recordingPath != null) {
      debugPrint(
        '🎙️ [AudioUI] Current active record buffer link tracked: $_recordingPath',
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(24)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: 'Cancel recording',
            onPressed: _isStopping ? null : _cancelRecording,
            icon: const Icon(Icons.delete_outline),
          ),

          const SizedBox(width: 4),

          Icon(
            Icons.fiber_manual_record,
            size: 14,
            color: Theme.of(context).colorScheme.error,
          ),

          const SizedBox(width: 6),

          Text(
            _formatDuration(_duration),
            style: const TextStyle(
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),

          const SizedBox(width: 8),

          IconButton(
            tooltip: 'Send voice recording',
            onPressed: _isStopping ? null : _stopRecording,
            icon: _isStopping
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.send),
          ),
        ],
      ),
    );
  }
}
