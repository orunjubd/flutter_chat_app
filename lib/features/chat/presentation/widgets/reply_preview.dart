import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:chat_app/features/chat/providers/reply_provider.dart';
import 'package:chat_app/features/chat/presentation/widgets/reply_card.dart';

class ReplyPreview extends ConsumerWidget {
  const ReplyPreview({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reply = ref.watch(replyProvider);

    if (reply == null) {
      return const SizedBox.shrink();
    }

    return ReplyCard(
      senderName: reply.senderName,
      message: reply.text,
      onClose: () {
        ref.read(replyProvider.notifier).clear();
      },
    );
  }
}
