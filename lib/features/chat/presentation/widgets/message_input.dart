import 'dart:async';
import 'package:chat_app/core/extensions/theme_extensions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:chat_app/features/chat/providers/typing_provider.dart';
import 'package:chat_app/features/chat/data/models/typing_status.dart';
import 'package:chat_app/features/chat/providers/user_provider.dart';
// final currentUserProvider = Provider<User?>((ref) {
//   return FirebaseAuth.instance.currentUser;
// });

class MessageInput extends ConsumerStatefulWidget {
  const MessageInput({super.key, required this.onSend});

  final Future<void> Function(String text) onSend;

  @override
  ConsumerState<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends ConsumerState<MessageInput> {
  final TextEditingController _controller = TextEditingController();

  Timer? _typingTimer;

  bool _isTyping = false;

  Future<void> _startTyping() async {
    if (_isTyping) return;

    _isTyping = true;

    final typingRepository = ref.read(typingRepositoryProvider);

    final firebaseUser = FirebaseAuth.instance.currentUser!;
    final appUser = await ref.read(currentUserProvider.future);

    if (appUser == null) return;

    await typingRepository.updateTypingStatus(
      status: TypingStatus(
        userId: firebaseUser.uid,
        username: appUser.username,
        isTyping: true,
        updatedAt:
            Timestamp.now(), // ignored by toFirestore() if using serverTimestamp()
      ),
    );
  }

  Future<void> _stopTyping() async {
    _typingTimer?.cancel();

    _typingTimer = Timer(const Duration(seconds: 2), () async {
      _isTyping = false;

      final typingRepository = ref.read(typingRepositoryProvider);

      final firebaseUser = FirebaseAuth.instance.currentUser!;

      await typingRepository.stopTyping(firebaseUser.uid);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _typingTimer?.cancel();
    super.dispose();
  }

  Future<void> _submit() async {
    final message = _controller.text.trim();

    if (message.isEmpty) {
      return;
    }

    _controller.clear();

    await widget.onSend(message);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Material(
        elevation: 8,
        color: context.cardColor,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  textCapitalization: TextCapitalization.sentences,
                  minLines: 1,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    hintText: 'Type a message...',
                  ),
                  onChanged: (_) async {
                    await _startTyping();

                    await _stopTyping();
                  },
                  onSubmitted: (_) => _submit(),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(onPressed: _submit, icon: const Icon(Icons.send)),
            ],
          ),
        ),
      ),
    );
  }
}
