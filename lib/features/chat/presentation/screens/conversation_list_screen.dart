import 'package:chat_app/core/widgets/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:chat_app/features/chat/providers/conversation_provider.dart';
import 'package:chat_app/features/chat/presentation/widgets/conversation_tile.dart';
import 'package:chat_app/features/chat/presentation/screens/chat_screen.dart';
import 'package:chat_app/features/chat/presentation/screens/user_selection_screen.dart';
//import 'package:chat_app/features/authentication/providers/logout_provider.dart';
import 'package:chat_app/core/utils/firebase_error_mapper.dart';

class ConversationListScreen extends ConsumerWidget {
  const ConversationListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conversationsAsync = ref.watch(conversationsProvider);

    return AppScaffold(
      //backgroundColor:
      appBar: AppBar(title: const Text('Chats'), actions: []),

      body: conversationsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),

        error: (error, _) =>
            Center(child: Text(FirebaseErrorMapper.message(error))),

        data: (conversations) {
          if (conversations.isEmpty) {
            return const Center(
              child: Text(
                'No conversations yet.',
                style: TextStyle(fontSize: 18),
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
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const UserSelectionScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
