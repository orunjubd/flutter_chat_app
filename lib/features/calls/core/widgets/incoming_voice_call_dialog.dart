//import 'package:chat_app/features/chat/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chat_app/features/calls/core/controllers/call_controller.dart'; // callProvider
import 'package:chat_app/features/calls/core/models/call_session.dart';

class IncomingVoiceCallDialog extends ConsumerWidget {
  const IncomingVoiceCallDialog({super.key, required this.incomingCall});
  final CallSession incomingCall;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    //final callerAsync = ref.watch(userByIdProvider(incomingCall.callerId));

    // Simplified: was a separate async userByIdProvider lookup here. Now
    // uses the denormalized callerName from the call document directly —
    // faster, no extra Firestore read, and guaranteed to match what CallKit's
    // native screen shows for the same call (same field, same value).
    final callerName = incomingCall.callerName ?? 'Unknown caller';

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
              Text(
                callerName,
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),

              // callerAsync.when(
              //   loading: () => Text(
              //     'Loading caller...',
              //     style: Theme.of(context).textTheme.titleMedium,
              //     textAlign: TextAlign.center,
              //   ),
              //   error: (_, _) => Text(
              //     incomingCall.callerId,
              //     style: Theme.of(context).textTheme.titleMedium,
              //     textAlign: TextAlign.center,
              //   ),
              //   data: (user) {
              //     debugPrint(
              //       '👤 [IncomingCall] Caller UID: ${incomingCall.callerId}',
              //     );

              //     debugPrint('👤 [IncomingCall] User object: $user');

              //     debugPrint('👤 [IncomingCall] Username: ${user?.username}');

              //     return Text(
              //       user?.username ?? 'Unknown caller',
              //       style: Theme.of(context).textTheme.titleMedium,
              //       textAlign: TextAlign.center,
              //     );
              //   },
              // ),
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
                              .rejectCall(callId: incomingCall.id);
                        },
                        child: const Text('Reject'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // ✅ Give Accept a finite share of the width.
                    Expanded(
                      child: FilledButton(
                        onPressed: () {
                          ref
                              .read(callProvider.notifier)
                              .acceptCall(
                                callId: incomingCall.id,
                                roomName: incomingCall.roomName,
                              );
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
  }
}
