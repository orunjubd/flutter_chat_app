import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:chat_app/core/extensions/theme_extensions.dart';

import 'package:chat_app/features/chat/providers/forward_provider.dart';
import 'package:chat_app/features/chat/presentation/widgets/reply_card.dart';

class ForwardPreview extends ConsumerWidget {
  const ForwardPreview({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final forward = ref.watch(forwardProvider);

    if (forward == null) {
      return const SizedBox.shrink();
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
          child: Row(
            children: [
              Icon(Icons.forward, size: 18, color: context.primaryColor),

              const SizedBox(width: 8),

              Expanded(
                child: Text(
                  'Forward message',
                  style: context.bodyTextMedium?.copyWith(
                    color: context.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),

        ReplyCard(
          senderName: forward.senderName,
          message: forward.text,
          onClose: () {
            ref.read(forwardProvider.notifier).clear();
          },
        ),
      ],
    );
  }
}
