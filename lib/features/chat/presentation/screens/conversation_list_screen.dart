import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:chat_app/core/search/providers/search_history_provider.dart';
import 'package:chat_app/core/search/widget/recent_search_list.dart';
import 'package:chat_app/features/calls/core/widgets/group_call_join_banner.dart';
import 'package:chat_app/features/chat/providers/conversation_search_provider.dart';
import 'package:chat_app/core/extensions/theme_extensions.dart';
import 'package:chat_app/core/widgets/app_scaffold.dart';
//import 'package:chat_app/features/calls/core/constants/call_strings.dart';
import 'package:chat_app/features/calls/core/controllers/call_controller.dart';
import 'package:chat_app/features/calls/core/controllers/group_call_controller.dart';
import 'package:chat_app/features/calls/core/models/call_state.dart';
import 'package:chat_app/features/calls/core/models/call_type.dart';
import 'package:chat_app/features/calls/core/screens/group_call_history_screen.dart';
import 'package:chat_app/features/calls/group_video_calls/screens/group_call_picker_screen.dart';
//import 'package:chat_app/features/chat/providers/conversation_provider.dart';
import 'package:chat_app/features/chat/presentation/widgets/conversation_tile.dart';
import 'package:chat_app/features/chat/presentation/screens/chat_screen.dart';
import 'package:chat_app/features/chat/presentation/screens/user_selection_screen.dart';
//import 'package:chat_app/features/authentication/providers/logout_provider.dart';
import 'package:chat_app/core/utils/firebase_error_mapper.dart';

enum ChatMenuAction { callHistory, groupVoiceCall, groupVideoCall }

class ConversationListScreen extends ConsumerStatefulWidget {
  const ConversationListScreen({super.key});
  @override
  ConsumerState<ConversationListScreen> createState() =>
      _ConversationListScreenState();
}

class _ConversationListScreenState
    extends ConsumerState<ConversationListScreen> {
  final _controller = TextEditingController();
  final _focus = FocusNode();
  bool _searching = false;
  String _query = '';
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _openSearch() {
    setState(() => _searching = true);
    _focus.requestFocus();
  }

  void _closeSearch() {
    _debounce?.cancel();
    _controller.clear();
    _focus.unfocus();
    setState(() {
      _searching = false;
      _query = '';
    });
  }

  void _onChanged(String v) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), () {
      if (mounted) setState(() => _query = v);
    });
    setState(() {}); // refresh the clear button immediately
  }

  void _submit(String v) {
    ref.read(searchHistoryProvider.notifier).add(v);
    setState(() => _query = v);
  }

  @override
  Widget build(BuildContext context) {
    final inCall =
        ref.watch(callProvider.select((s) => s.phase.isBusy)) ||
        ref.watch(groupCallProvider.select((s) => s.phase.isBusy));

    return PopScope(
      canPop: !_searching,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _closeSearch();
      },
      child: AppScaffold(
        appBar: AppBar(
          leading: _searching
              ? IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: _closeSearch,
                )
              : null,
          title: _searching
              ? TextField(
                  controller: _controller,
                  focusNode: _focus,
                  onChanged: _onChanged,
                  onSubmitted: _submit,
                  textInputAction: TextInputAction.search,
                  decoration: const InputDecoration(
                    hintText: 'Search conversations',
                    border: InputBorder.none,
                  ),
                )
              : const Text('Chats'),
          actions: _searching
              ? [
                  if (_controller.text.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        _controller.clear();
                        setState(() => _query = '');
                      },
                    ),
                ]
              : [
                  // ------------------------------------------------------------
                  // Search
                  // Primary conversation action — always visible
                  // ------------------------------------------------------------
                  IconButton(
                    icon: const Icon(Icons.search),
                    tooltip: 'Search conversations',
                    onPressed: _openSearch,
                  ),

                  // ------------------------------------------------------------
                  // More actions
                  // ------------------------------------------------------------
                  PopupMenuButton<ChatMenuAction>(
                    tooltip: 'More',
                    onSelected: (action) {
                      switch (action) {
                        case ChatMenuAction.callHistory:
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const GroupCallHistoryScreen(),
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
                              builder: (_) => const GroupCallPickerScreen(
                                type: CallType.voice,
                              ),
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
                              builder: (_) => const GroupCallPickerScreen(
                                type: CallType.video,
                              ),
                            ),
                          );
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      // --------------------------------------------------------
                      // Call History
                      // --------------------------------------------------------
                      PopupMenuItem<ChatMenuAction>(
                        value: ChatMenuAction.callHistory,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.history, size: 20),
                            const SizedBox(width: 10),
                            // Vertical separator
                            Container(
                              width: 1,
                              height: 22,
                              color: Theme.of(context).dividerColor,
                            ),
                            const SizedBox(width: 10),
                            const Text('Call History'),
                          ],
                        ),
                      ),
                      const PopupMenuDivider(),
                      // --------------------------------------------------------
                      // Group Voice Call
                      // --------------------------------------------------------
                      PopupMenuItem<ChatMenuAction>(
                        value: ChatMenuAction.groupVoiceCall,
                        enabled: !inCall,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.phone_forwarded, size: 20),
                            const SizedBox(width: 10),
                            // Vertical separator
                            Container(
                              width: 1,
                              height: 22,
                              color: Theme.of(context).dividerColor,
                            ),
                            const SizedBox(width: 10),
                            const Text('Group voice call'),
                          ],
                        ),
                      ),

                      // --------------------------------------------------------
                      // Group Video Call
                      // --------------------------------------------------------
                      PopupMenuItem<ChatMenuAction>(
                        value: ChatMenuAction.groupVideoCall,
                        enabled: !inCall,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.video_call, size: 20),
                            const SizedBox(width: 10),
                            // Vertical separator
                            Container(
                              width: 1,
                              height: 22,
                              color: Theme.of(context).dividerColor,
                            ),
                            const SizedBox(width: 10),
                            const Text('Group video call'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
        ),
        body: Column(
          children: [
            if (!_searching) const GroupCallJoinBanner(),
            Expanded(child: _body()),
          ],
        ),
        floatingActionButton: _searching
            ? null
            : FloatingActionButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const UserSelectionScreen(),
                  ),
                ),
                child: const Icon(Icons.add),
              ),
      ),
    );
  }

  Widget _body() {
    // Searching with nothing typed: show recent searches.
    if (_searching && _controller.text.trim().isEmpty) {
      return RecentSearchList(
        emptyHint: "Search conversations to quickly find past active chats.",
        onSelected: (q) {
          _controller.text = q;
          _controller.selection = TextSelection.collapsed(offset: q.length);
          _submit(q);
        },
      );
    }

    final async = ref.watch(filteredConversationsProvider(_query));
    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text(FirebaseErrorMapper.message(e))),
      data: (conversations) {
        if (conversations.isEmpty) {
          return Center(
            child: Text(
              _query.trim().isEmpty
                  ? 'No conversations yet.'
                  : 'No results for "$_query"',
              style: context.labelTextMedium?.copyWith(fontSize: 18),
            ),
          );
        }
        return ListView.builder(
          itemCount: conversations.length,
          itemBuilder: (context, index) {
            final conversation = conversations[index];
            return ConversationTile(
              conversation: conversation,
              onTap: () {
                if (_query.trim().isNotEmpty) {
                  ref.read(searchHistoryProvider.notifier).add(_query);
                }
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ChatScreen(conversation: conversation),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
