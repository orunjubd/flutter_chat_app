import 'package:chat_app/core/extensions/theme_extensions.dart';
import 'package:chat_app/core/theme/app_colors.dart';
import 'package:chat_app/core/utils/date_time_formatter.dart';
import 'package:chat_app/core/widgets/app_scaffold.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
//import 'package:intl/intl.dart';

import 'package:chat_app/features/chat/providers/user_provider.dart';
import 'package:chat_app/features/chat/data/models/message.dart';
import 'package:chat_app/features/chat/presentation/widgets/message_input.dart';
import 'package:chat_app/features/chat/presentation/widgets/message_list.dart';
import 'package:chat_app/features/chat/data/models/presence.dart';
import 'package:chat_app/features/chat/providers/presence_provider.dart';
import 'package:chat_app/features/chat/providers/typing_provider.dart';
import 'package:chat_app/features/chat/data/models/conversation.dart';
import 'package:chat_app/features/chat/providers/conversation_message_provider.dart';
import 'package:chat_app/features/chat/providers/conversation_provider.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key, required this.conversation});

  final Conversation conversation;

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen>
    with WidgetsBindingObserver {
  final ScrollController _scrollController = ScrollController();

  Conversation get conversation => widget.conversation;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await clearUnread();
      await _setOnline();
    });

    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> clearUnread() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;
    await ref
        .read(conversationRepositoryProvider)
        .clearUnread(conversationId: conversation.id, userId: currentUser.uid);
    debugPrint('Unread cleared for ${currentUser.uid} in ${conversation.id}');
  }

  //Future<void> _sendMessage(WidgetRef ref, String text) async {
  Future<void> _sendMessage(String text) async {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser == null) {
      return;
    }
    final appUser = await ref.read(currentUserProvider.future);
    if (appUser == null) {
      return;
    }
    final repository = ref.read(
      conversationMessageRepositoryProvider(conversation.id),
    );
    final document = repository.createMessageDocument();
    final message = Message(
      id: document.id,
      senderId: firebaseUser.uid,
      senderName: appUser.username,
      text: text,
      createdAt: Timestamp.now(),
      readBy: [firebaseUser.uid],
      type: 'text',
    );

    await repository.sendMessage(message);
    await ref
        .read(conversationRepositoryProvider)
        .updateConversationAfterMessage(
          conversationId: conversation.id,
          lastMessage: text,
        );
    await ref
        .read(conversationRepositoryProvider)
        .incrementUnread(
          conversation: conversation,
          senderId: firebaseUser.uid,
        );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;

      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _setOnline() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    final repository = ref.read(presenceRepositoryProvider);

    await repository.updatePresence(
      Presence(userId: user.uid, isOnline: true, lastSeen: Timestamp.now()),
    );

    debugPrint('Presence -> ONLINE');
  }

  Future<void> _setOffline() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    final repository = ref.read(presenceRepositoryProvider);

    await repository.setOffline(user.uid);

    debugPrint('Presence -> OFFLINE');
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.resumed:
        clearUnread();
        _setOnline();
        break;

      case AppLifecycleState.paused:
        _setOffline();
        break;

      case AppLifecycleState.detached:
        _setOffline();
        break;

      case AppLifecycleState.inactive:
        break;

      case AppLifecycleState.hidden:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final typingAsync = ref.watch(typingProvider);
    final currentUserId = ref.watch(currentUserIdProvider);

    // 1. Safely extract the other user's ID
    final otherUserId = conversation.participantIds.firstWhere(
      (id) => id != currentUserId,
      orElse: () => '',
    );

    final presenceAsync = ref.watch(userPresenceProvider(otherUserId));

    // 2. Safely watch the user profile data locally inside the build tree
    final otherUserAsync = ref.watch(userByIdProvider(otherUserId));

    return AppScaffold(
      backgroundColor: context.scaffoldBackgroundColor,
      // 🚀 1. THE APPBAR ENGINE
      appBar: AppBar(
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            otherUserAsync.when(
              loading: () => Text('Loading...', style: context.titleText),
              error: (_, __) => Text('Unknown User', style: context.titleText),
              data: (user) => Text(
                user?.username ?? 'Unknown User',
                style: context.titleText?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            presenceAsync.when(
              loading: () => const SizedBox.shrink(),

              error: (_, _) => const SizedBox.shrink(),

              data: (presence) {
                if (presence == null) {
                  return const SizedBox.shrink();
                }

                return Text(
                  presence.isOnline
                      ? '● Online'
                      : 'Last seen ${DateTimeFormatter.formatLastSeen(presence.lastSeen)}',
                  style: context.captionText?.copyWith(
                    color: presence.isOnline
                        ? AppColors.lastSeen
                        : context.textSecondaryColor,
                  ),
                );
              },
            ),
          ],
        ),
      ),

      // 🚀 2. THE EMPTY MESSAGE LIST PLACEHOLDER CONTAINER (For now)
      body: Column(
        children: [
          Expanded(
            child: MessageList(
              scrollController: _scrollController,
              conversationId: conversation.id,
            ),
          ),

          typingAsync.when(
            loading: () => const SizedBox.shrink(),

            error: (_, _) => const SizedBox.shrink(),

            data: (typingUsers) {
              final others = typingUsers
                  .where(
                    (user) => user.userId != currentUserId && user.isTyping,
                  )
                  .toList();

              if (others.isEmpty) {
                return const SizedBox.shrink();
              }

              return Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                child: Text(
                  '${others.first.username} is typing...',
                  style: context.captionText?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: context.textSecondaryColor,
                  ),
                ),
              );
            },
          ),

          MessageInput(onSend: _sendMessage),
        ],
      ),
    );
  }
}
