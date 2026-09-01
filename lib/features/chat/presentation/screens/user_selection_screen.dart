// UserSelectionScreen — full updated file
import 'package:chat_app/core/widgets/app_scaffold.dart';
import 'package:chat_app/features/chat/presentation/widgets/forward_preview.dart';
import 'package:chat_app/features/peoples/presentation/screens/new_contact_screen.dart';
import 'package:chat_app/features/peoples/presentation/widgets/invite_friends_tile.dart';
import 'package:chat_app/features/peoples/presentation/widgets/people_more_options_menu.dart';
import 'package:chat_app/features/peoples/presentation/widgets/people_sort_button.dart';
import 'package:chat_app/features/peoples/providers/people_sort_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
//import 'package:chat_app/features/chat/providers/user_directory_provider.dart';
//import 'package:chat_app/features/chat/presentation/screens/chat_screen.dart';
import 'package:chat_app/features/chat/providers/forward_provider.dart';
import 'package:chat_app/features/chat/utils/start_conversation.dart';
//import 'package:chat_app/features/peoples/providers/people_search_provider.dart';
import 'package:chat_app/features/peoples/presentation/widgets/people_search_field.dart';
import 'package:chat_app/features/peoples/presentation/widgets/app_users_list.dart';
import 'package:chat_app/features/chat/data/models/app_user.dart';

class UserSelectionScreen extends ConsumerStatefulWidget {
  const UserSelectionScreen({super.key});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _UserSelectionScreenState();
}

class _UserSelectionScreenState extends ConsumerState<UserSelectionScreen> {
  Future<void> _startConversation(String otherUserId) async {
    await startConversationWithUser(
      context: context,
      ref: ref,
      otherUserId: otherUserId,
    );
  }

  @override
  Widget build(BuildContext context) {
    final forwardMessage = ref.watch(forwardProvider);
    final usersAsync = ref.watch(sortedPeopleProvider);

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) ref.read(forwardProvider.notifier).clear();
      },
      child: AppScaffold(
        backgroundColor: const Color(0xFF1E4D40),
        appBar: AppBar(
          title: Text(
            forwardMessage == null ? 'Select User' : 'Forward Message',
          ),
          actions: const [PeopleSortButton(), PeopleMoreOptionsMenu()],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const NewContactScreen()));
          },
          child: const Icon(Icons.person_add),
        ),
        body: Column(
          children: [
            // Invite Friends only makes sense when picking a real
            // person to chat with, not while choosing a forward target.
            if (forwardMessage == null) ...[
              const InviteFriendsTile(),
              const Divider(height: 1),
            ],
            const PeopleSearchField(),
            if (forwardMessage != null) ...[
              const ForwardPreview(),
              const Divider(height: 1),
              const SizedBox(height: 8),
            ],
            Expanded(
              child: usersAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) =>
                    Center(child: Text('Unable to load users: $error')),
                data: (users) => AppUsersList(
                  users: users,
                  onUserTap: (AppUser user) => _startConversation(user.id),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
