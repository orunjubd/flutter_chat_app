import 'package:chat_app/core/utils/firebase_error_mapper.dart';
import 'package:chat_app/features/chat/constants/conversation_strings.dart';
import 'package:chat_app/features/chat/data/models/conversation_filter.dart';
import 'package:chat_app/features/chat/presentation/screens/chat_screen.dart';
import 'package:chat_app/features/chat/presentation/widgets/conversation_tile.dart';
import 'package:chat_app/features/chat/providers/conversation_search_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ArchivedConversationsScreen extends ConsumerWidget {
  const ArchivedConversationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(
      filteredConversationsProvider((
        query: '',
        archived: true,
        filter: ConversationFilter.all,
      )),
    );
    return Scaffold(
      appBar: AppBar(title: const Text(ConversationStrings.archived)),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(FirebaseErrorMapper.message(e))),
        data: (items) => items.isEmpty
            ? const Center(child: Text(ConversationStrings.noArchived))
            : ListView.builder(
                itemCount: items.length,
                itemBuilder: (_, i) => ConversationTile(
                  conversation: items[i],
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ChatScreen(conversation: items[i]),
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
