import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:chat_app/core/media/models/media_draft.dart';
import 'package:chat_app/core/media/repositories/media_upload_repository.dart';
import 'media_upload_state.dart';
import 'media_upload_provider.dart';

final mediaUploadNotifierProvider =
    NotifierProvider<MediaUploadNotifier, MediaUploadState>(
      MediaUploadNotifier.new,
    );

class MediaUploadNotifier extends Notifier<MediaUploadState> {
  late final MediaUploadRepository _repository;

  @override
  MediaUploadState build() {
    _repository = ref.read(mediaUploadRepositoryProvider);

    return const MediaUploadState();
  }

  Future<void> upload(MediaDraft draft) async {
    try {
      state = state.copyWith(status: MediaUploadStatus.preparing);

      state = state.copyWith(status: MediaUploadStatus.uploading);

      final result = await _repository.uploadMedia(draft);

      state = state.copyWith(status: MediaUploadStatus.success, result: result);
    } catch (e) {
      state = state.copyWith(
        status: MediaUploadStatus.failure,
        error: e.toString(),
      );
    }
  }

  void reset() {
    state = const MediaUploadState();
  }
}
