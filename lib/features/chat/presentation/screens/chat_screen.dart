import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:chat_app/features/authentication/providers/auth_provider.dart';
import 'package:chat_app/features/chat/providers/user_provider.dart';
import 'package:chat_app/core/dialogs/app_dialogs.dart';
import 'package:chat_app/features/chat/data/models/message.dart';
import 'package:chat_app/features/chat/providers/message_provider.dart';
import 'package:chat_app/features/chat/presentation/widgets/message_input.dart';
import 'package:chat_app/features/chat/presentation/widgets/message_list.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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

    final repository = ref.read(messageRepositoryProvider);

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;

      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Colors.white12, // Sleek deep monochromatic styling canvas
      // 🚀 1. THE APPBAR ENGINE
      appBar: AppBar(
        backgroundColor: Colors.white12,
        elevation: 0,
        // A. User Avatar Placeholder Frame
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Colors.grey[800],
            child: const Icon(
              Icons.person_outline_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
        // B. App Center/Left Title Text Canvas
        title: const Text(
          'Chat App',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
        // C. Interactive Logout Button Unit Actions Bar
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            tooltip: 'Logout',
            onPressed: () async {
              final shouldLogout = await AppDialogs.confirm(
                context: context,
                title: 'Logout',
                message: 'Are you sure you want to sign out?',
                confirmText: 'Logout',
              );

              if (shouldLogout) {
                await ref.read(authRepositoryProvider).signOut();
              }
            },
          ),
        ],
      ),

      // 🚀 2. THE EMPTY MESSAGE LIST PLACEHOLDER CONTAINER (For now)
      body: Column(
        children: [
          Expanded(child: MessageList(scrollController: _scrollController)),

          MessageInput(onSend: _sendMessage),
        ],
      ),
    );
  }
}
