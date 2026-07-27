import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:chat_app/features/chat/data/repositories/reply_repository.dart';

final replyRepositoryProvider = Provider<ReplyRepository>((ref) {
  return const ReplyRepository();
});
