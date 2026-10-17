import 'dart:async';
import 'package:chat_app/core/extensions/theme_extensions.dart';
import 'package:chat_app/core/media/widgets/attachment_sheet.dart';
import 'package:chat_app/features/authentication/providers/auth_provider.dart';
import 'package:chat_app/features/chat/data/repositories/typing_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:chat_app/features/chat/providers/typing_provider.dart';
import 'package:chat_app/features/chat/data/models/typing_status.dart';
//import 'package:chat_app/features/chat/providers/user_provider.dart';
import 'package:chat_app/core/media/factories/attachment_actions.dart';

class MessageInput extends ConsumerStatefulWidget {
  const MessageInput({
    super.key,
    required this.onSend,
    required this.conversationId,
  });

  final Future<void> Function(String text) onSend;

  final String conversationId;

  @override
  ConsumerState<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends ConsumerState<MessageInput> {
  final TextEditingController _controller = TextEditingController();

  Timer? _typingTimer;
  bool _isTyping = false;
  late final TypingRepository _typing;
  String? _uid;
  String _username = '';

  @override
  void initState() {
    super.initState();
    _typing = ref.read(typingRepositoryProvider);
    _uid = FirebaseAuth.instance.currentUser?.uid;
  }

  Future<void> _startTyping() async {
    if (_isTyping || _uid == null) return;
    debugPrint('⌨️ [Typing] start uid=$_uid conv=${widget.conversationId}');
    try {
      if (_username.isEmpty) {
        final u = await ref.read(firestoreRepositoryProvider).getUser(_uid!);
        debugPrint('⌨️ [Typing] user loaded: ${u?.username}');
        if (!mounted || u == null) return;
        _username = u.username;
      }
      await _typing.updateTypingStatus(
        status: TypingStatus(
          userId: _uid!,
          username: _username,
          isTyping: true,
          updatedAt: Timestamp.now(),
          conversationId: widget.conversationId,
        ),
      );
      _isTyping = true; // only after a successful write
      debugPrint('⌨️ [Typing] written');
    } catch (e, st) {
      debugPrint('❌ [Typing] failed: $e');
      debugPrintStack(stackTrace: st);
    }
  }

  void _stopTyping() {
    _typingTimer?.cancel();
    _typingTimer = Timer(const Duration(seconds: 2), () async {
      _isTyping = false;
      if (_uid != null) await _typing.stopTyping(_uid!); // no ref here
    });
  }

  @override
  void dispose() {
    _typingTimer?.cancel();
    if (_isTyping && _uid != null) unawaited(_typing.stopTyping(_uid!));
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final message = _controller.text.trim();
    if (message.isEmpty) {
      return;
    }
    _controller.clear();
    if (_isTyping && _uid != null) {
      _typingTimer
          ?.cancel(); // Terminate any pending background execution tickers safely
      _isTyping = false; // Reset the local state tracker flag instantly

      // Fires an unawaited asynchronous cloud write loop so it updates the server without blocking message transmission speed
      unawaited(_typing.stopTyping(_uid!));
    }
    await widget.onSend(message);
  }

  @override
  Widget build(BuildContext context) {
    //final replyMessage = ref.watch(replyProvider);
    return SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Material(
            elevation: 1,
            color: context.cardColor,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.attach_file,
                      color: context.textSecondaryColor,
                    ),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        showDragHandle:
                            true, // Displays modern material slider indicator drag bars on top [INDEX]
                        backgroundColor: context
                            .surfaceColor, // Seamless day/night alignment [INDEX]
                        builder: (_) {
                          return AttachmentSheet(
                            actions: AttachmentActions.build(
                              context: context,
                              ref: ref,
                              conversationId: widget.conversationId,
                            ),
                          );
                        },
                      );
                    },
                  ),

                  Expanded(
                    child: TextField(
                      controller: _controller,
                      textCapitalization: TextCapitalization.sentences,
                      minLines: 1,
                      maxLines: 5,
                      style: context.bodyTextMedium,
                      decoration: const InputDecoration(
                        hintText: 'Type a message...',
                      ),
                      onChanged: (_) async {
                        _startTyping();

                        _stopTyping();
                      },
                      onSubmitted: (_) => _submit(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _submit,
                    icon: Icon(Icons.send, color: context.primaryColor),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
