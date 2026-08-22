import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';

/// Provides a VideoPlayerController for a remote video URL.
///
/// The provider owns the controller lifecycle:
/// - creates the controller
/// - initializes it
/// - disposes it automatically when the provider is destroyed
///   (autoDispose — once nothing is watching a given video's
///   controller, it's torn down rather than kept alive forever)
///
/// The video URL is the provider's identity, so different videos
/// receive different controllers.
final videoPlayerProvider = FutureProvider.autoDispose
    .family<VideoPlayerController, String>((ref, videoUrl) async {
      if (videoUrl.trim().isEmpty) {
        throw ArgumentError('Video URL cannot be empty.');
      }

      final controller = VideoPlayerController.networkUrl(Uri.parse(videoUrl));

      try {
        await controller.initialize();
      } catch (e) {
        await controller.dispose();
        rethrow;
      }

      ref.onDispose(() {
        controller.dispose();
      });

      return controller;
    });
