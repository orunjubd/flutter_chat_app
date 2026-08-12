class VoiceRecording {
  const VoiceRecording({
    required this.path,
    required this.duration,
    required this.fileSize,
    required this.mimeType,
    this.waveform = const [],
  });

  final String path;
  final Duration duration;
  final int fileSize;
  final String mimeType;
  final List<double> waveform;

  int get durationMs => duration.inMilliseconds;

  Map<String, dynamic> toMap() {
    return {
      'path': path,
      'durationMs': duration.inMilliseconds,
      'fileSize': fileSize,
      'mimeType': mimeType,
      'waveform': waveform,
    };
  }

  factory VoiceRecording.fromMap(Map<String, dynamic> data) {
    return VoiceRecording(
      path: data['path'] as String,
      duration: Duration(
        milliseconds: (data['durationMs'] as num?)?.toInt() ?? 0,
      ),
      fileSize: (data['fileSize'] as num?)?.toInt() ?? 0,
      mimeType: data['mimeType'] as String? ?? 'audio/mp4',
      waveform:
          (data['waveform'] as List?)
              ?.map((value) => (value as num).toDouble())
              .toList() ??
          const [],
    );
  }
}
