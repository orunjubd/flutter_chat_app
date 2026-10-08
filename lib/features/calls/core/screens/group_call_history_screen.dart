import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chat_app/core/extensions/theme_extensions.dart';
import 'package:chat_app/core/utils/date_time_formatter.dart';
import 'package:chat_app/features/calls/core/models/call_type.dart';
import 'package:chat_app/features/calls/core/models/group_call_history_entry.dart';
import 'package:chat_app/features/calls/core/providers/group_call_history_provider.dart';

class GroupCallHistoryScreen extends ConsumerWidget {
  const GroupCallHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = ref.watch(groupCallHistoryProvider).value ?? const [];
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Group calls'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.videocam_outlined), text: 'Video'),
              Tab(icon: Icon(Icons.call_outlined), text: 'Voice'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _List(entries.where((e) => e.type == CallType.video).toList()),
            _List(entries.where((e) => e.type == CallType.voice).toList()),
          ],
        ),
      ),
    );
  }
}

class _List extends StatelessWidget {
  const _List(this.items);
  final List<GroupCallHistoryEntry> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const Center(child: Text('No group calls yet'));
    return ListView.separated(
      itemCount: items.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, i) {
        final e = items[i];
        final bad = e.outcome != GroupCallOutcome.joined;
        final label = switch (e.outcome) {
          GroupCallOutcome.joined =>
            e.durationSeconds == null
                ? 'Joined'
                : 'Joined · ${e.durationSeconds! ~/ 60}:${(e.durationSeconds! % 60).toString().padLeft(2, '0')}',
          GroupCallOutcome.missed => 'Missed',
          GroupCallOutcome.declined => 'Declined',
        };
        return ListTile(
          leading: Icon(
            e.outcome == GroupCallOutcome.missed
                ? Icons.call_missed
                : Icons.groups,
            color: bad ? context.errorColor : null,
          ),
          title: Text(
            e.participantNames.join(', '),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            '$label · ${DateTimeFormatter.messageTime(e.startedAt.toDate())}',
          ),
        );
      },
    );
  }
}
