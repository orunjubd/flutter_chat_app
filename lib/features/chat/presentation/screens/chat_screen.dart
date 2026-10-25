import 'dart:async';

import 'package:chat_app/core/dialogs/app_snackbar.dart';
import 'package:chat_app/core/notifications/providers/notification_provider.dart';
import 'package:chat_app/core/notifications/services/local_notification_service.dart';
import 'package:chat_app/features/authentication/providers/auth_provider.dart';
import 'package:chat_app/features/calls/core/controllers/group_call_controller.dart';
import 'package:chat_app/features/calls/core/models/call_type.dart';
import 'package:chat_app/features/calls/core/policies/group_call_policy.dart';
import 'package:chat_app/features/calls/core/utils/app_lifecycle_utils.dart';
import 'package:chat_app/features/calls/group_video_calls/screens/group_call_picker_screen.dart';
import 'package:chat_app/features/calls/group_video_calls/screens/group_video_call_screen.dart';
import 'package:chat_app/features/calls/group_voice_calls/screens/group_voice_call_screen.dart';
import 'package:chat_app/features/chat/data/repositories/conversation_repository.dart';
import 'package:chat_app/features/chat/presentation/screens/group_info_screen.dart';
import 'package:chat_app/features/chat/presentation/widgets/read_only_bar.dart';
//import 'package:chat_app/features/calls/group_video_calls/screens/group_video_call_screen.dart';
import 'package:chat_app/features/chat/search/screens/search_messages_screen.dart';
import 'package:chat_app/features/profile/presentation/screens/user_profile_screen.dart';
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
  ConversationRepository? _convRepo;
  ActiveConversationNotifier? _active;

  @override
  void initState() {
    super.initState();

    _convRepo = ref.read(conversationRepositoryProvider);
    _active = ref.read(activeConversationProvider.notifier);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _active?.enter(widget.conversation.id);
      unawaited(
        LocalNotificationService.instance.cancelForConversation(
          widget.conversation.id,
        ),
      );
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
    debugPrint('👤 [Chat] currentUser state: ${ref.read(currentUserProvider)}');
    debugPrint(
      '✉️ [Chat] send start conv=${conversation.id} group=${conversation.isGroup} '
      'canSend=${conversation.canSend(ref.read(currentUserIdProvider) ?? '')}',
    );

    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser == null) {
      debugPrint('❌ [Chat] no firebase user');
      return;
    }

    String senderName = 'Unknown User';
    final appUser = ref.read(currentUserProvider).value;

    // if (appUser == null) {
    //   debugPrint('❌ [Chat] user profile missing for ${firebaseUser.uid}');
    //   return;
    // }
    if (appUser != null) {
      senderName = appUser.username;
    } else {
      // 🚀 THE FALLBACK: If the stream is stuck in AsyncLoading, fire a direct one-time get() to the server!
      try {
        final u = await ref
            .read(firestoreRepositoryProvider)
            .getUser(firebaseUser.uid);
        if (u != null) {
          senderName = u.username;
        }
      } catch (e) {
        debugPrint(
          '⚠️ [Chat] Fallback one-time user fetch failed inside _sendMessage: $e',
        );
      }
    }

    try {
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
        senderName: senderName, //appUser.username,
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
      debugPrint('✅ [Chat] send ok');
    } catch (e, st) {
      // =======================================================================
      // ❌ FIREWALL EXCEPTION LOG CACHE (REQUIREMENT INTEGRITY MET)
      // =======================================================================
      debugPrint('❌ [Chat] send failed inside ChatScreen payload block: $e');
      debugPrintStack(stackTrace: st);
    }
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

  Future<String> _nameOf(String uid) async {
    try {
      final u = await ref
          .read(firestoreRepositoryProvider)
          .getUser(uid)
          .timeout(const Duration(seconds: 4));
      final name = u?.username ?? '';
      return name.isEmpty ? uid : name;
    } catch (e) {
      debugPrint('⚠️ [GroupChat] name lookup failed for $uid: $e');
      return uid; // the call must not wait on a name
    }
  }

  bool _calling = false;
  Future<void> _callFromGroup(
    Conversation c,
    CallType type, {
    required bool inCall, // 🚀 THE FIX: Injected parameter boundary lines
  }) async {
    debugPrint(
      '📞 [GroupChat] call tap type=$type members=${c.participantIds.length} inCall=$inCall',
    );
    if (inCall || _calling) return;

    _calling = true; // ২য় ক্লিকের রাস্তা লক করে দেওয়া হলো ব্রো
    try {
      debugPrint(
        '📞 [GroupChat] call tap type=$type members=${c.participantIds.length} inCall=$inCall',
      );
      final myUid = ref.read(currentUserIdProvider);
      if (myUid == null) return;
      final others = c.participantIds.where((id) => id != myUid).toList();

      // A group down to two people calls 1:1.
      if (others.length == 1) {
        //final peer = await ref.read(userByIdProvider(others.first).future);
        final peerName = await _nameOf(others.first);
        final peerUser = await ref
            .read(firestoreRepositoryProvider)
            .getUser(others.first)
            .timeout(const Duration(seconds: 4))
            .catchError((_) => null);
        final String? peerAvatar = peerUser?.imageUrl;
        if (!mounted) return;
        Navigator.of(context).push(
          MaterialPageRoute(
            settings: const RouteSettings(name: 'call_screen'),
            builder: (_) => CallScreen(
              peerId: others.first,
              peerName: peerName, // peer?.username ?? 'Unknown User',
              peerAvatarUrl: peerAvatar, // peer?.imageUrl,
              isOutgoing: true,
              type: type,
            ),
          ),
        );
        return;
      }

      // group branch
      final problem = const GroupCallPolicy().validateStart(
        type: type,
        inviteeCount: others.length,
      );
      if (problem != null) {
        AppSnackBar.info(context, problem); // e.g. "up to 8 people" for video
        return;
      }

      final myName = await _nameOf(myUid);
      final entries = await Future.wait(
        others.map((id) async => MapEntry(id, await _nameOf(id))),
      );
      final names = <String, String>{
        myUid: myName,
        for (final e in entries) e.key: e.value,
      };
      // for (final id in others) {
      //   names[id] =
      //       (await ref.read(userByIdProvider(id).future))?.username ?? id;
      // }
      if (!mounted) return;
      setState(() {
        // এই খালি স্টেট চেঞ্জারটি ফ্লাটারকে বাধ্য করবে ব্যাকগ্রাউন্ড ল্যাগ কাটিয়ে ১ম ক্লিকেই চ্যাট স্ক্রিন রিফ্রেশ করতে,
        // যার ফলে ড্রয়ার মেনু আইকন আর ছোঁয়াও লাগবে না ব্রো, ১ম ক্লিকেই রিংটোন বেজে স্ক্রিন সামনে চলে আসবে!
      });
      Navigator.of(context).push(
        MaterialPageRoute(
          settings: const RouteSettings(name: 'group_call_screen'),
          builder: (_) => type == CallType.voice
              ? GroupVoiceCallScreen.outgoing(
                  conversationId: c.id,
                  inviteeIds: others,
                  names: names,
                )
              : GroupVideoCallScreen.outgoing(
                  conversationId: c.id,
                  inviteeIds: others,
                  names: names,
                ),
        ),
      );
      WidgetsBinding.instance.scheduleFrame();
    } finally {
      _calling = false;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.resumed:
        clearUnread();
        _setOnline();
        unawaited(
          LocalNotificationService.instance.cancelForConversation(
            widget.conversation.id,
          ),
        );
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
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final id = widget.conversation.id;
    final repo = _convRepo;
    final active = _active;
    if (uid != null && repo != null) {
      Future(() => repo.clearUnread(conversationId: id, userId: uid));
    }
    Future(() => active?.leave(id));

    WidgetsBinding.instance.removeObserver(this);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final conversationId = widget.conversation.id;
    final inCall =
        ref.watch(callProvider.select((s) => s.phase.isBusy)) ||
        ref.watch(groupCallProvider.select((s) => s.phase.isBusy));
    final typingAsync = ref.watch(typingProvider(conversationId));
    final currentUserId = ref.watch(currentUserIdProvider);

    final live = ref
        .watch(conversationsProvider)
        .value
        ?.where((c) => c.id == widget.conversation.id)
        .firstOrNull;
    final conversation =
        live ?? widget.conversation; // shadows the getter on purpose
    final isGroup = conversation.isGroup;
    if (isGroup && live == null && ref.watch(conversationsProvider).hasValue) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && Navigator.canPop(context)) Navigator.pop(context);
      });
    }

    final otherUserId = isGroup
        ? ''
        : conversation.participantIds.firstWhere(
            (id) => id != currentUserId,
            orElse: () => '',
          );
    final presenceAsync = isGroup
        ? null
        : ref.watch(userPresenceProvider(otherUserId));
    // =======================================================================
    // 🛡️ ECE SAFE CONVERSATION TYPE GUARD BLOCK (INJECTED CRASH DEFENDER)
    // =======================================================================

    final otherUserAsync = isGroup
        ? null
        : ref.watch(userByIdProvider(otherUserId));
    final otherDeleted =
        !isGroup && (otherUserAsync?.value?.isDeleted ?? false);

    final cleared = conversation.clearedAt[currentUserId];
    final joined = conversation.joinedAt[currentUserId];
    final visibleFrom =
        (cleared != null && (joined == null || cleared.compareTo(joined) > 0))
        ? cleared
        : joined;
    ref.listen<AsyncValue<List<Conversation>>>(conversationsProvider, (
      _,
      next,
    ) {
      final me = FirebaseAuth.instance.currentUser?.uid;
      if (me == null || !mounted) return;
      final c = next.value
          ?.where((c) => c.id == widget.conversation.id)
          .firstOrNull;
      if (c != null && (c.unreadCounts[me] ?? 0) > 0 && isAppInForeground) {
        clearUnread();
      }
    });
    return Stack(
      children: [
        AppScaffold(
          backgroundColor: context.scaffoldBackgroundColor,
          appBar: AppBar(
            elevation: 0,
            title: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: isGroup
                  ? () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            GroupInfoScreen(groupId: conversationId),
                      ),
                    )
                  : null,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isGroup) ...[
                    Text(
                      conversation.name ?? 'Group',
                      style: context.titleText?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${conversation.participantIds.length} members',
                      style: context.captionText?.copyWith(
                        color: context.textSecondaryColor,
                      ),
                    ),
                  ] else ...[
                    otherUserAsync?.when(
                          loading: () =>
                              Text('Loading...', style: context.titleText),
                          error: (_, _) =>
                              Text('Unknown User', style: context.titleText),
                          data: (user) => Text(
                            user?.username ?? 'Unknown User',
                            style: context.titleText?.copyWith(
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ) ??
                        const SizedBox.shrink(),
                    presenceAsync?.when(
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
                        ) ??
                        const SizedBox.shrink(),
                  ],
                ],
              ),
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
                      builder: (_) => SearchMessagesScreen(
                        conversationId: conversationId,
                        visibleFrom: isGroup && currentUserId != null
                            ? conversation.joinedAt[currentUserId]?.toDate()
                            : null,
                      ),
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
                      if (inCall || otherDeleted) return;
                      if (isGroup) {
                        _callFromGroup(
                          conversation,
                          CallType.voice,
                          inCall: inCall,
                        );
                        break;
                      }
                      if (!context.mounted) return;

                      Navigator.of(context).push(
                        MaterialPageRoute(
                          settings: const RouteSettings(name: 'call_screen'),
                          builder: (_) => CallScreen(
                            peerId: otherUserId,
                            peerName:
                                otherUserAsync?.value?.username ??
                                'Unknown User',
                            peerAvatarUrl: otherUserAsync?.value?.imageUrl,
                            isOutgoing: true,
                          ),
                        ),
                      );
                      break;

                    case ChatMenuAction.videoCall:
                      if (inCall || otherDeleted) return;
                      if (isGroup) {
                        _callFromGroup(
                          conversation,
                          CallType.video,
                          inCall: inCall,
                        );
                        break;
                      }
                      if (!context.mounted) return;

                      Navigator.of(context).push(
                        MaterialPageRoute(
                          settings: const RouteSettings(name: 'call_screen'),
                          builder: (_) => CallScreen(
                            peerId: otherUserId,
                            peerName:
                                otherUserAsync?.value?.username ??
                                'Unknown User',
                            peerAvatarUrl: otherUserAsync?.value?.imageUrl,
                            isOutgoing: true,
                            type: CallType.video,
                          ),
                        ),
                      );
                      WidgetsBinding.instance.scheduleFrame();
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
                itemBuilder: (context) => isGroup
                    ? [
                        PopupMenuItem(
                          value: ChatMenuAction.voiceCall,
                          enabled: !inCall,
                          child: ListTile(
                            leading: const Icon(Icons.phone_forwarded),
                            title: Text(CallStrings.groupVoiceCall),
                          ),
                        ),
                        PopupMenuItem(
                          value: ChatMenuAction.videoCall,
                          enabled: !inCall,
                          child: const ListTile(
                            leading: Icon(Icons.video_call),
                            title: Text('Group video call'),
                          ),
                        ),
                      ]
                    : [
                        PopupMenuItem(
                          value: ChatMenuAction.voiceCall,
                          enabled: !inCall && !otherDeleted,
                          child: ListTile(
                            leading: const Icon(Icons.call_outlined),
                            title: Text(CallStrings.voiceCall),
                          ),
                        ),

                        PopupMenuItem(
                          value: ChatMenuAction.videoCall,
                          enabled: !inCall && !otherDeleted,
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
                  showSenderNames: conversation
                      .isGroup, // 🚀 Dynamically shows names only if group chat!
                  memberCount: conversation.participantIds.length,
                  visibleFrom: visibleFrom?.toDate(),
                  canDeleteOthers:
                      isGroup &&
                      currentUserId != null &&
                      conversation.can(
                        currentUserId,
                        GroupPermission.deleteMessages,
                      ),
                  onSenderTap: (uid) {
                    // =======================================================================
                    // 👤 FUTURE PROFILE LINK: Open the member's profile sheet here once built
                    // =======================================================================

                    if (uid == currentUserId) return;
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => UserProfileScreen(userId: uid),
                      ),
                    );

                    debugPrint(
                      '👤 [ChatScreenUI] Directing route transition to user profile sheet for UID: $uid',
                    );
                  },
                ),
              ),
              typingAsync.when(
                loading: () => const SizedBox.shrink(),
                error: (_, _) => const SizedBox.shrink(),
                data: (typingUsers) {
                  final others = typingUsers
                      .where(
                        (u) =>
                            u.userId != currentUserId &&
                            u.isTyping &&
                            DateTime.now()
                                    .difference(u.updatedAt.toDate())
                                    .inSeconds <
                                8,
                      )
                      .toList();
                  if (others.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  String typingText(
                    List<String> names,
                  ) => switch (names.length) {
                    0 => '',
                    1 => '${names[0]} is typing...',
                    2 => '${names[0]} and ${names[1]} are typing...',
                    _ =>
                      '${names[0]} and ${names.length - 1} others are typing...',
                  };

                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    child: Text(
                      typingText([for (final u in others) u.username]),
                      style: context.captionText?.copyWith(
                        fontStyle: FontStyle.italic,
                        color: context.textSecondaryColor,
                      ),
                    ),
                  );
                },
              ),
              if (currentUserId != null &&
                  conversation.canSend(currentUserId) &&
                  !otherDeleted) ...[
                // 🚀 Renders the message reply preview row cleanly if the user is authorized to text
                const ReplyPreview(),

                MessageInput(
                  conversationId: widget.conversation.id,
                  onSend: _sendMessage,
                ),
              ] else ...[
                ReadOnlyBar(
                  text: otherDeleted
                      ? 'This account was deleted' // Triggers if peer profile is a ghost tombstone
                      : 'Only admins can send messages', // Falls back to group control rules
                ),
              ],
            ],
          ),
        ),
        //const IncomingVoiceCallDialog(),
      ],
    );
  }
}
