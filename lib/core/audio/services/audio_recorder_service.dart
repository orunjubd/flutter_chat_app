import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

class AudioRecorderService {
  AudioRecorderService();

  final AudioRecorder _recorder = AudioRecorder();

  bool _isRecording = false;

  bool get isRecording => _isRecording;

  /// Checks whether microphone permission is available.
  Future<bool> hasPermission() async {
    //return _recorder.hasPermission();
    //debugPrint('🎙️ [AudioEngine] Querying OS microphone permission status...');
    final bool status = await _recorder.hasPermission();
    //debugPrint('🎙️ [AudioEngine] OS Permission granted status: $status');
    return status;
  }

  /// Starts a new voice recording.
  Future<String> startRecording() async {
    //debugPrint('🎙️ [AudioEngine] startRecording() called.');
    if (_isRecording) {
      //debugPrint(
      //  '⚠️ [AudioEngine] Aborted: A voice recording is already in progress.',
      //);
      throw StateError('A voice recording is already in progress.');
    }

    final permissionGranted = await _recorder.hasPermission();

    if (!permissionGranted) {
      //debugPrint('💥 [AudioEngine] Microphone permission was not granted.');
      throw StateError('Microphone permission was not granted.');
    }

    final directory = await getTemporaryDirectory();

    final fileName = 'voice_${DateTime.now().millisecondsSinceEpoch}.m4a';

    final path = File('${directory.path}/$fileName').path;

    await _recorder.start(
      const RecordConfig(
        encoder: AudioEncoder.aacLc,
        bitRate: 64000,
        sampleRate: 44100,
        numChannels: 1,
      ),
      path: path,
    );

    _isRecording = true;

    // 🚀 TEST PRINT 2: HARDWARE ENGINE STATUS CONFIRMATION
    // debugPrint(
    //   '✅ [AudioEngine] MIC CAPTURE ACTIVE! Hardware stream is writing live bytes.',
    // );

    return path;
  }

  /// Stops recording and returns the local file path.
  Future<String?> stopRecording() async {
    if (!_isRecording) {
      return null;
    }

    final path = await _recorder.stop();

    _isRecording = false;

    if (path == null || path.isEmpty) {
      return null;
    }

    final file = File(path);

    if (!await file.exists()) {
      return null;
    }

    // 📊 SUCCESS LOGGING: Safe region hit, print metrics cleanly [INDEX]!
    final int fileLength = await file.length();
    debugPrint(
      '🏁 [AudioEngine] MIC CAPTURE STOPPED. Final asset verified at: $path',
    );
    debugPrint(
      '📦 [AudioEngine] Confirmed storage payload size: $fileLength bytes',
    );

    return path;
  }

  /// Cancels the current recording and removes the temporary file.
  Future<void> cancelRecording() async {
    if (!_isRecording) {
      return;
    }

    try {
      await _recorder.cancel();
    } finally {
      _isRecording = false;
    }
  }

  /// Returns the current recording amplitude.
  ///
  /// This will be useful later for the waveform/volume indicator.
  Future<Amplitude> getAmplitude() {
    return _recorder.getAmplitude();
  }

  Future<void> dispose() async {
    if (_isRecording) {
      try {
        await _recorder.cancel();
      } catch (e) {
        debugPrint('⚠️ [AudioEngine] Recording cleanup failed: $e');
      }

      _isRecording = false;
    }

    await _recorder.dispose();
  }
}
