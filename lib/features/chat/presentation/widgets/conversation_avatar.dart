import 'package:flutter/material.dart';

import 'package:chat_app/features/chat/data/models/app_user.dart';

class ConversationAvatar extends StatelessWidget {
  const ConversationAvatar({super.key, required this.user});

  final AppUser? user;

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return const CircleAvatar(child: Icon(Icons.person));
    }

    if (user!.imageUrl.isNotEmpty) {
      return CircleAvatar(backgroundImage: NetworkImage(user!.imageUrl));
    }

    return CircleAvatar(
      child: Text(
        user!.username.isEmpty ? '?' : user!.username[0].toUpperCase(),
      ),
    );
  }
}
