import 'package:chat_app/features/calls/core/controllers/call_controller.dart';
import 'package:chat_app/features/calls/core/models/call_video_tracks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final callVideoTracksProvider = StreamProvider.autoDispose<CallVideoTracks>((
  ref,
) async* {
  final service = ref.watch(liveKitCallServiceProvider);
  yield service.videoTracks; // initial value, then changes
  yield* service.onVideoTracksChanged;
});
