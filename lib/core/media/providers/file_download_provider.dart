import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/file_download_service.dart';

final fileDownloadServiceProvider = Provider<FileDownloadService>((ref) {
  return const FileDownloadService();
});
