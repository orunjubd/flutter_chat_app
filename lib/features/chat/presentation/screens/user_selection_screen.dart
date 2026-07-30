import 'package:chat_app/core/extensions/theme_extensions.dart';
import 'package:chat_app/core/theme/app_colors.dart';
import 'package:chat_app/core/widgets/app_scaffold.dart';
import 'package:chat_app/features/chat/presentation/widgets/forward_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:chat_app/features/chat/providers/user_directory_provider.dart';
import 'package:chat_app/features/chat/providers/conversation_provider.dart';
import 'package:chat_app/features/chat/data/models/conversation.dart';
import 'package:chat_app/features/chat/presentation/screens/chat_screen.dart';
import 'package:chat_app/core/utils/firebase_error_mapper.dart';

import 'package:chat_app/features/chat/providers/forward_provider.dart';
//import 'package:chat_app/features/chat/data/repositories/conversation_message_repository.dart';
import 'package:chat_app/features/chat/providers/conversation_message_provider.dart';

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
    final Conversation conversation = await repository.createOrOpenConversation(
      currentUserId: currentUser.uid,
      otherUserId: otherUserId,
    );

    if (!mounted) return;

    // ==========================================================
    // FORWARD MODE
    // ==========================================================
    // 🚀 EXTRACED LOCALLY WITHIN METHOD SCOPE
    final forwardMessage = ref.read(forwardProvider);

    if (forwardMessage != null) {
      final repository = ref.read(
        conversationMessageRepositoryProvider(conversation.id),
      );

      await repository.forwardMessage(
        originalMessage: forwardMessage,
        currentUserId: currentUser.uid,
        currentUserName: currentUser.displayName ?? '',
      );

      ref.read(forwardProvider.notifier).clear();

      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => ChatScreen(conversation: conversation),
        ),
      );

      return;
    }

    // ==========================================================
    // NORMAL CHAT MODE
    // ==========================================================

    if (!mounted) return;

    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ChatScreen(conversation: conversation)),
    );

    // A forward is in progress.
    // We'll send the message in the next step.
    //ref.read(forwardProvider.notifier).clear();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(usersDirectoryProvider);
    final forwardMessage = ref.watch(forwardProvider);

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          ref.read(forwardProvider.notifier).clear();
        }
      },
      child: AppScaffold(
        backgroundColor: const Color(0xFF1E4D40),
        appBar: AppBar(
          title: Text(
            forwardMessage == null ? 'Select User' : 'Forward Message',
          ),
          actions: [],
        ),

        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search users...',
                  prefixIcon: const Icon(Icons.search),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchText = value.trim().toLowerCase();
                  });
                },
              ),
            ),

            // =======================================================================
            // 📥 THE INJECTED LIVE SYSTEM FORWARD PREVIEW WINDOW STRIP
            // =======================================================================
            // ✅ ফিক্সড: সিলেক্ট ইউজার স্ক্রিনের ঠিক ওপরে এখন ফরোয়ার্ড করা মেসেজের প্রিভিউ প্যানেলটি ভেসে উঠবে!
            if (forwardMessage != null) ...[
              const ForwardPreview(),
              const Divider(height: 1),
              const SizedBox(height: 8),
            ],

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
                    return Center(
                      child: Text(
                        'No users found.',
                        style: context.labelTextMedium?.copyWith(fontSize: 18),
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
                          color: user.isOnline
                              ? AppColors.online
                              : AppColors.offline,
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
      ),
    );
  }
}
