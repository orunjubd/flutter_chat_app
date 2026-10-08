import 'package:chat_app/features/calls/core/controllers/group_call_controller.dart';
import 'package:chat_app/features/calls/core/models/call_type.dart';
import 'package:chat_app/features/calls/group_video_calls/screens/group_call_picker_screen.dart';
//import 'package:chat_app/features/calls/group_video_calls/screens/group_video_call_screen.dart';
import 'package:chat_app/features/chat/search/screens/search_messages_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:chat_app/core/extensions/theme_extensions.dart';
//import 'package:chat_app/core/theme/app_colors.dart';
import 'package:chat_app/core/utils/date_time_formatter.dart';
import 'package:chat_app/core/widgets/app_scaffold.dart';
import 'package:chat_app/features/calls/core/controllers/call_controller.dart'; // callProvider
//import 'package:chat_app/features/calls/core/models/call_phase.dart'; // CallUiState
import 'package:chat_app/features/calls/core/models/call_state.dart'; // CallState
import 'package:chat_app/features/calls/core/screens/call_screen.dart';
import 'package:chat_app/features/chat/presentation/widgets/reply_preview.dart';
import 'package:chat_app/features/chat/providers/reply_repository_provider.dart';

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
import 'package:chat_app/features/chat/providers/reply_provider.dart';
import 'package:chat_app/features/chat/providers/message_scroll_provider.dart';
import 'package:chat_app/features/calls/core/constants/call_strings.dart';

enum ChatMenuAction { voiceCall, videoCall, groupVoiceCall, groupVideoCall }

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key, required this.conversation});

  final Conversation conversation;

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen>
    with WidgetsBindingObserver {
  final ScrollController _scrollController = ScrollController();
  String? _highlightMessageId;

  Conversation get conversation => widget.conversation;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _initializeChatScreen();
    });

    WidgetsBinding.instance.addObserver(this);
  }

  Future<void> _initializeChatScreen() async {
    await clearUnread();
    if (!mounted) return;
    await _setOnline();
  }

  Future<void> clearUnread() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;
    if (!mounted) return;

    await ref
        .read(conversationRepositoryProvider)
        .clearUnread(conversationId: conversation.id, userId: currentUser.uid);
  }

  //Future<void> _sendMessage(WidgetRef ref, String text) async {
  Future<void> _sendMessage(String text) async {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser == null) return;

    final appUser = ref.read(currentUserProvider).value;
    if (appUser == null) return;

    // 👇 Current reply (if any)
    final reply = ref.read(replyProvider);

    final repository = ref.read(
      conversationMessageRepositoryProvider(widget.conversation.id),
    );

    final replyRepository = ref.read(replyRepositoryProvider);
    final document = repository.createMessageDocument();
    final draftMessage = TextMessage(
      id: document.id,
      senderId: firebaseUser.uid,
      senderName: appUser.username,
      text: text,
      createdAt: Timestamp.now(),
      readBy: [firebaseUser.uid],

      //type: 'text',
      deletedForEveryone: false,
      deletedBy: const [],
      deletedAt: null,
    );

    final message = replyRepository.attachReply(
      draft: draftMessage,
      reply: reply,
    );

    await repository.sendMessage(message);

    // Clear reply after successful send
    ref.read(replyProvider.notifier).clear();
  }

  Future<void> _jumpToMessage(Message message) async {
    final messages = ref
        .read(conversationMessagesProvider(widget.conversation.id))
        .value;

    if (messages == null) return;

    final index = messages.indexWhere((item) => item.id == message.id);

    if (index == -1) return;

    await ref.read(messageScrollControllerProvider).scrollToIndex(index);

    if (!mounted) return;

    setState(() {
      _highlightMessageId = message.id;
    });

    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    setState(() {
      _highlightMessageId = null;
    });
  }

  Future<void> _setOnline() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    if (!mounted) return;

    final repository = ref.read(presenceRepositoryProvider);
    await repository.updatePresence(
      Presence(userId: user.uid, isOnline: true, lastSeen: Timestamp.now()),
    );
  }

  Future<void> _setOffline() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    if (!mounted) return;

    final repository = ref.read(presenceRepositoryProvider);
    await repository.setOffline(user.uid);
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
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final inCall =
        ref.watch(callProvider.select((s) => s.phase.isBusy)) ||
        ref.watch(groupCallProvider.select((s) => s.phase.isBusy));
    final typingAsync = ref.watch(typingProvider);
    final currentUserId = ref.watch(currentUserIdProvider);
    final conversationId = widget.conversation.id;
    final otherUserId = conversation.participantIds.firstWhere(
      (id) => id != currentUserId,
      orElse: () => '',
    );

    final presenceAsync = ref.watch(userPresenceProvider(otherUserId));
    final otherUserAsync = ref.watch(userByIdProvider(otherUserId));
    // final callState = ref.watch(callProvider);
    //final otherUser = otherUserAsync.valueOrNull;

    return Stack(
      children: [
        AppScaffold(
          backgroundColor: context.scaffoldBackgroundColor,
          appBar: AppBar(
            elevation: 0,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                otherUserAsync.when(
                  loading: () => Text('Loading...', style: context.titleText),
                  error: (_, _) =>
                      Text('Unknown User', style: context.titleText),
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
                            ? const Color.fromARGB(255, 253, 149, 51)
                            : context.textSecondaryColor,
                      ),
                    );
                  },
                ),
              ],
            ),
            actions: [
              // ------------------------------------------------------------
              // Search
              // Primary conversation action — keep visible.
              // ------------------------------------------------------------
              IconButton(
                icon: const Icon(Icons.search),
                tooltip: 'Search messages',
                onPressed: () async {
                  final selectedMessage = await Navigator.push<Message>(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          SearchMessagesScreen(conversationId: conversationId),
                    ),
                  );

                  if (!context.mounted || selectedMessage == null) {
                    return;
                  }

                  await _jumpToMessage(selectedMessage);
                },
              ),

              // ------------------------------------------------------------
              // More actions
              // Secondary conversation/call actions.
              // ------------------------------------------------------------
              PopupMenuButton<ChatMenuAction>(
                tooltip: 'More options',
                icon: const Icon(Icons.more_vert),
                onSelected: (action) async {
                  switch (action) {
                    case ChatMenuAction.voiceCall:
                      if (inCall) return;

                      if (!context.mounted) return;

                      Navigator.of(context).push(
                        MaterialPageRoute(
                          settings: const RouteSettings(name: 'call_screen'),
                          builder: (_) => CallScreen(
                            peerId: otherUserId,
                            peerName:
                                otherUserAsync.value?.username ??
                                'Unknown User',
                            peerAvatarUrl: otherUserAsync.value?.imageUrl,
                            isOutgoing: true,
                          ),
                        ),
                      );
                      break;

                    case ChatMenuAction.videoCall:
                      if (inCall) return;

                      if (!context.mounted) return;

                      Navigator.of(context).push(
                        MaterialPageRoute(
                          settings: const RouteSettings(name: 'call_screen'),
                          builder: (_) => CallScreen(
                            peerId: otherUserId,
                            peerName:
                                otherUserAsync.value?.username ??
                                'Unknown User',
                            peerAvatarUrl: otherUserAsync.value?.imageUrl,
                            isOutgoing: true,
                            type: CallType.video,
                          ),
                        ),
                      );
                      break;

                    case ChatMenuAction.groupVoiceCall:
                      if (inCall) return;

                      Navigator.of(context).push(
                        MaterialPageRoute(
                          settings: const RouteSettings(
                            name: 'group_call_picker',
                          ),
                          builder: (_) =>
                              const GroupCallPickerScreen(type: CallType.voice),
                        ),
                      );
                      break;

                    case ChatMenuAction.groupVideoCall:
                      if (inCall) return;

                      Navigator.of(context).push(
                        MaterialPageRoute(
                          settings: const RouteSettings(
                            name: 'group_call_picker',
                          ),
                          builder: (_) =>
                              const GroupCallPickerScreen(type: CallType.video),
                        ),
                      );
                      break;
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: ChatMenuAction.voiceCall,
                    enabled: !inCall,
                    child: ListTile(
                      leading: const Icon(Icons.call_outlined),
                      title: Text(CallStrings.voiceCall),
                    ),
                  ),

                  PopupMenuItem(
                    value: ChatMenuAction.videoCall,
                    enabled: !inCall,
                    child: ListTile(
                      leading: const Icon(Icons.videocam_outlined),
                      title: Text(CallStrings.videoCall),
                    ),
                  ),

                  const PopupMenuDivider(),

                  PopupMenuItem(
                    value: ChatMenuAction.groupVoiceCall,
                    enabled: !inCall,
                    child: ListTile(
                      leading: const Icon(Icons.phone_forwarded),
                      title: Text(CallStrings.groupVoiceCall),
                    ),
                  ),

                  PopupMenuItem(
                    value: ChatMenuAction.groupVideoCall,
                    enabled: !inCall,
                    child: const ListTile(
                      leading: Icon(Icons.video_call),
                      title: Text('Group video call'),
                    ),
                  ),
                ],
              ),

              const SizedBox(width: 8),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: MessageList(
                  scrollController: _scrollController,
                  conversationId: widget.conversation.id,
                  highlightMessageId: _highlightMessageId,
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
              const ReplyPreview(),
              MessageInput(
                conversationId: widget.conversation.id,
                onSend: _sendMessage,
              ),
            ],
          ),
        ),
        //const IncomingVoiceCallDialog(),
      ],
    );
  }
}
