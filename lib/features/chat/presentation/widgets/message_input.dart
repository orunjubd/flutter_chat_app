import 'dart:async';
import 'package:chat_app/core/extensions/theme_extensions.dart';
import 'package:chat_app/core/media/widgets/attachment_sheet.dart';
import 'package:chat_app/features/authentication/providers/auth_provider.dart';
import 'package:chat_app/features/chat/data/repositories/typing_repository.dart';
import 'package:chat_app/features/chat/presentation/widgets/mention_suggestions.dart';
import 'package:chat_app/features/chat/providers/user_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
//import 'package:firebase_auth/firebase_auth.dart';

import 'package:chat_app/features/chat/providers/typing_provider.dart';
import 'package:chat_app/features/chat/data/models/typing_status.dart';
//import 'package:chat_app/features/chat/providers/user_provider.dart';
import 'package:chat_app/core/media/factories/attachment_actions.dart';

class MessageInput extends ConsumerStatefulWidget {
  const MessageInput({
    super.key,
    required this.onSend,
    required this.conversationId,
    this.mentionCandidates = const {},
  });

  final Future<void> Function(String text, Map<String, String> mentions) onSend;
  final String conversationId;
  final Map<String, String> mentionCandidates;

  @override
  ConsumerState<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends ConsumerState<MessageInput> {
  final TextEditingController _controller = TextEditingController();
  final Map<String, String> _picked = {}; // uid -> name inserted into the text
  List<MapEntry<String, String>> _matches = const [];

  Timer? _typingTimer;
  bool _isTyping = false;
  late final TypingRepository _typing;
  //  String? get _uid => ref.read(currentUserIdProvider);
  String? _uid;
  String _username = '';

  // VoidCallback get _updateMentionQuery => null;

  @override
  void initState() {
    super.initState();
    _typing = ref.read(typingRepositoryProvider);
    //_uid = FirebaseAuth.instance.currentUser?.uid;
    _uid = ref.read(currentUserIdProvider);
    _controller.addListener(_updateMentionQuery);
    debugPrint('[MessageInput] Initialized with UID: $_uid');
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

  void _updateMentionQuery() {
    if (widget.mentionCandidates.isEmpty) return;
    // if (widget.mentionCandidates.isEmpty) {
    //   _setMatches(const []);
    //   debugPrint('💬 [Mention] No mention candidates available.');
    //   return;
    // }
    final sel = _controller.selection;
    if (!sel.isValid || !sel.isCollapsed) {
      _setMatches(const []);
      return;
    }
    final text = _controller.text;
    final cursor = sel.baseOffset;
    final at = text.lastIndexOf('@', cursor > 0 ? cursor - 1 : 0);
    final validStart =
        at >= 0 && at < cursor && (at == 0 || text[at - 1].trim().isEmpty);
    if (!validStart) {
      _setMatches(const []);
      return;
    }
    final query = text.substring(at + 1, cursor).toLowerCase();
    debugPrint('💬 [Mention] Text: $text');
    debugPrint('💬 [Mention] Query: "$query"');
    debugPrint(
      '💬 [Mention] Candidate count: ${widget.mentionCandidates.length}',
    );
    if (query.contains('\n') || query.length > 20) {
      _setMatches(const []);
      return;
    }
    final results = widget.mentionCandidates.entries
        .where(
          (e) =>
              !_picked.containsKey(e.key) &&
              e.value.toLowerCase().startsWith(query),
        )
        .take(5)
        .toList();
    debugPrint('💬 [Mention] Matches found: ${results.length}');
    _setMatches(results);
  }

  void _setMatches(List<MapEntry<String, String>> m) {
    if (m.length == _matches.length &&
        m.every((e) => _matches.any((o) => o.key == e.key))) {
      return;
    }
    setState(() => _matches = m);
  }

  void _pick(String uid, String name) {
    final text = _controller.text;
    final cursor = _controller.selection.baseOffset;
    final at = text.lastIndexOf('@', cursor > 0 ? cursor - 1 : 0);
    if (at < 0) return;
    final inserted = '@$name ';
    _controller.value = TextEditingValue(
      text: text.replaceRange(at, cursor, inserted),
      selection: TextSelection.collapsed(offset: at + inserted.length),
    );
    _picked[uid] = name;
    setState(() => _matches = const []);
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
    debugPrint('[MessageInput] dispose() called.');
    _typingTimer?.cancel();
    final uid = _uid;
    if (_isTyping && uid != null) {
      debugPrint('[MessageInput] Stopping typing for UID: $uid');

      unawaited(_typing.stopTyping(uid));
    }
    _controller.removeListener(_updateMentionQuery);
    _controller.dispose();
    super.dispose();
  }

  // Future<void> _submit() async {
  //   final message = _controller.text.trim();
  //   if (message.isEmpty) {
  //     return;
  //   }
  //  final mentions = {
  //     for (final e in _picked.entries)
  //       if (message.contains('@${e.value}')) e.key: e.value,
  //   };
  //   _controller.clear();
  //   if (_isTyping && _uid != null) {
  //     _typingTimer
  //         ?.cancel(); // Terminate any pending background execution tickers safely
  //     _isTyping = false; // Reset the local state tracker flag instantly

  //     // Fires an unawaited asynchronous cloud write loop so it updates the server without blocking message transmission speed
  //     unawaited(_typing.stopTyping(_uid!));
  //   }
  //   await widget.onSend(message, mentions);
  // }
  Future<void> _submit() async {
    final message = _controller.text.trim();
    if (message.isEmpty) return;
    final mentions = {
      for (final e in _picked.entries)
        if (message.contains('@${e.value}')) e.key: e.value,
    };
    _controller.clear();
    _picked.clear();
    setState(() => _matches = const []);
    await widget.onSend(message, mentions);
  }

  @override
  Widget build(BuildContext context) {
    //final replyMessage = ref.watch(replyProvider);
    return SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          MentionSuggestions(matches: _matches, onPick: _pick),
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
                        // _updateMentionQuery();
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
