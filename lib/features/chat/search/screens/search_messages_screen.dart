import 'package:flutter/material.dart' hide SearchBar;
import 'package:flutter_riverpod/flutter_riverpod.dart';

//import 'package:chat_app/features/chat/data/models/message.dart';
import 'package:chat_app/features/chat/search/providers/search_provider.dart';
import 'package:chat_app/features/chat/search/repositories/search_repository.dart';
import 'package:chat_app/features/chat/search/widgets/search_bar.dart';
//import 'package:chat_app/core/extensions/theme_extensions.dart';
import 'package:chat_app/features/chat/search/widgets/highlight_text.dart';
import 'package:chat_app/features/chat/providers/conversation_message_provider.dart';
import 'package:chat_app/core/search/providers/search_history_provider.dart';
import 'package:chat_app/core/search/widget/recent_search_list.dart';

class SearchMessagesScreen extends ConsumerStatefulWidget {
  const SearchMessagesScreen({super.key, required this.conversationId});

  final String conversationId;

  @override
  ConsumerState<SearchMessagesScreen> createState() =>
      _SearchMessagesScreenState();
}

class _SearchMessagesScreenState extends ConsumerState<SearchMessagesScreen> {
  late final TextEditingController _controller;

  final SearchRepository _repository = const SearchRepository();

  @override
  void initState() {
    super.initState();

    _controller = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(searchProvider.notifier).clear();
    });
  }

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = ref.watch(searchProvider);
    final queryRead = ref.read(searchProvider.notifier);

    final messagesAsync = ref.watch(
      conversationMessagesProvider(widget.conversationId),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Search Messages')),

      body: Column(
        children: [
          SearchBar(
            controller: _controller,
            autofocus: true,
            onChanged: (value) {
              queryRead.update(value);
            },
            onSubmitted: (value) async {
              final query = value.trim();

              if (query.isEmpty) return;

              await ref.read(searchHistoryProvider.notifier).add(query);
            },
            onClear: () {
              queryRead.clear();
            },
          ),

          Expanded(
            child: query.isEmpty
                ? RecentSearchList(
                    onSelected: (value) {
                      _controller.text = value;

                      ref.read(searchProvider.notifier).update(value);

                      ref.read(searchHistoryProvider.notifier).add(value);
                    },
                  )
                : messagesAsync.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),

                    error: (error, _) => Center(child: Text(error.toString())),

                    data: (messages) {
                      final results = _repository.search(
                        messages: messages,
                        query: query,
                      );
                      final resultCount = results.length;

                      if (results.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.search_off_rounded,
                                  size: 64,
                                  color: Theme.of(context).colorScheme.outline,
                                ),

                                const SizedBox(height: 20),

                                Text(
                                  'No Messages Found',
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),

                                const SizedBox(height: 8),

                                Text(
                                  'Try another keyword or phrase.',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSurfaceVariant,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      return Column(
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            color: Theme.of(
                              context,
                            ).colorScheme.surfaceContainerHighest,
                            child: Text(
                              resultCount == 1
                                  ? '1 result found'
                                  : '$resultCount results found',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                          Expanded(
                            child: ListView.separated(
                              itemCount: results.length,
                              separatorBuilder: (_, _) =>
                                  const Divider(height: 1),
                              itemBuilder: (context, index) {
                                final message = results[index];

                                return ListTile(
                                  leading: const Icon(
                                    Icons.chat_bubble_outline,
                                  ),

                                  title: HighlightText(
                                    text: message.senderName,
                                    query: query,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),

                                  subtitle: HighlightText(
                                    text: message.text,
                                    query: query,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),

                                  trailing: const Icon(
                                    Icons.arrow_forward_ios,
                                    size: 16,
                                  ),

                                  onTap: () {
                                    Navigator.pop(context, message);
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
