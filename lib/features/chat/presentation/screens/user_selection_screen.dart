import 'package:chat_app/core/widgets/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:chat_app/features/chat/providers/user_directory_provider.dart';
import 'package:chat_app/features/chat/providers/conversation_provider.dart';
import 'package:chat_app/features/chat/data/models/conversation.dart';
//import 'package:chat_app/features/chat/data/repositories/conversation_repository.dart';
import 'package:chat_app/features/chat/presentation/screens/chat_screen.dart';
//import 'package:chat_app/features/authentication/providers/logout_provider.dart';
import 'package:chat_app/core/utils/firebase_error_mapper.dart';

class UserSelectionScreen extends ConsumerStatefulWidget {
  const UserSelectionScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _UserSelectionScreenState();
}

class _UserSelectionScreenState extends ConsumerState<UserSelectionScreen> {
  final TextEditingController _searchController = TextEditingController();

  String _searchText = '';

  Future<void> _startConversation(String otherUserId) async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return;
    }

    final repository = ref.read(conversationRepositoryProvider);

    debugPrint('Current User: ${currentUser.uid}');
    debugPrint('Other User: $otherUserId');

    final Conversation conversation = await repository.createOrOpenConversation(
      currentUserId: currentUser.uid,
      otherUserId: otherUserId,
    );

    debugPrint('Conversation ID: ${conversation.id}');

    if (!mounted) return;

    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ChatScreen(conversation: conversation)),
    );

    debugPrint('Conversation Ready: ${conversation.id}');
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(usersDirectoryProvider);

    return AppScaffold(
      backgroundColor: const Color(0xFF1E4D40),
      appBar: AppBar(title: const Text('Select User'), actions: []),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search users...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchText = value.trim().toLowerCase();
                });
              },
            ),
          ),

          Expanded(
            child: usersAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),

              error: (error, _) =>
                  Center(child: Text(FirebaseErrorMapper.message(error))),

              data: (users) {
                final filteredUsers = users.where((user) {
                  return user.username.toLowerCase().contains(_searchText) ||
                      user.email.toLowerCase().contains(_searchText);
                }).toList();

                if (filteredUsers.isEmpty) {
                  return const Center(
                    child: Text(
                      'No users found.',
                      style: TextStyle(fontSize: 18),
                    ),
                  );
                }

                return ListView.separated(
                  itemCount: filteredUsers.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),

                  itemBuilder: (context, index) {
                    final user = filteredUsers[index];

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: user.imageUrl.isNotEmpty
                            ? NetworkImage(user.imageUrl)
                            : null,
                        child: user.imageUrl.isEmpty
                            ? const Icon(Icons.person)
                            : null,
                      ),

                      title: Text(user.username),

                      subtitle: Text(user.email),

                      trailing: Icon(
                        user.isOnline ? Icons.circle : Icons.access_time,
                        color: user.isOnline ? Colors.green : Colors.grey,
                        size: 14,
                      ),

                      onTap: () async {
                        await _startConversation(user.id);
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
