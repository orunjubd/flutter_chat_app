import 'package:chat_app/features/calls/data/models/call_session.dart';
//import 'package:chat_app/features/calls/screens/call_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chat_app/features/calls/providers/call_provider.dart';
import 'package:chat_app/features/chat/providers/user_provider.dart';

class IncomingVoiceCallDialog extends ConsumerWidget {
  const IncomingVoiceCallDialog({super.key, required this.incomingCall});

  final CallSession incomingCall;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final callerAsync = ref.watch(userByIdProvider(incomingCall.callerId));
    //return Positioned.fill(
    return Container(
      color: Colors.black54,
      alignment: Alignment.center,
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 320,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.phone_in_talk, size: 56),

              const SizedBox(height: 16),

              Text(
                'Incoming Voice Call',
                style: Theme.of(context).textTheme.titleLarge,
              ),

              const SizedBox(height: 8),

              callerAsync.when(
                loading: () => Text(
                  'Loading caller...',
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                error: (_, _) => Text(
                  incomingCall.callerId,
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                data: (user) {
                  debugPrint(
                    '👤 [IncomingCall] Caller UID: ${incomingCall.callerId}',
                  );

                  debugPrint('👤 [IncomingCall] User object: $user');

                  debugPrint('👤 [IncomingCall] Username: ${user?.username}');

                  return Text(
                    user?.username ?? 'Unknown caller',
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  );
                },
              ),

              const SizedBox(height: 24),

              // ✅ FIX: Give Row a finite width.
              SizedBox(
                width: double.infinity,
                child: Row(
                  children: [
                    // ✅ Give Reject a finite share of the width.
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          ref
                              .read(callProvider.notifier)
                              .rejectVoiceCall(callId: incomingCall.id);
                        },
                        child: const Text('Reject'),
                      ),
                    ),

                    const SizedBox(width: 12),

                    // ✅ Give Accept a finite share of the width.
                    Expanded(
                      child: FilledButton(
                        // onPressed: () async {
                        //   final callerId = incomingCall.callerId;
                        //   await ref
                        //       .read(callProvider.notifier)
                        //       .acceptVoiceCall(
                        //         callId: incomingCall.id,
                        //         roomName: incomingCall.roomName,
                        //       );
                        //   if (!context.mounted) return;
                        //   Navigator.of(context).push(
                        //     MaterialPageRoute(
                        //       builder: (_) => CallScreen(otherUserId: callerId),
                        //     ),
                        //   );
                        // },
                        onPressed: () {
                          ref
                              .read(callProvider.notifier)
                              .acceptVoiceCall(
                                callId: incomingCall.id,
                                roomName: incomingCall.roomName,
                              );
                          // No navigation here — GlobalIncomingCallListener's ref.listen
                          // handles it once status actually becomes `connected`, whether
                          // this was a foreground accept or a resumed background one.
                        },
                        child: const Text('Accept'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
    //);
  }
}
