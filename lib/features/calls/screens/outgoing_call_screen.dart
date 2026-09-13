// features/calls/screens/outgoing_call_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:chat_app/features/calls/providers/call_provider.dart';
import 'package:chat_app/features/calls/screens/call_screen.dart';
import 'package:chat_app/features/chat/providers/user_provider.dart';

class OutgoingCallScreen extends ConsumerWidget {
  const OutgoingCallScreen({super.key, required this.calleeId});

  final String calleeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final calleeAsync = ref.watch(userByIdProvider(calleeId));

    final size = MediaQuery.sizeOf(context);
    final isSmallScreen = size.height < 650;

    ref.listen<CallState>(callProvider, (previous, next) {
      if (next.status == CallConnectionStatus.connected) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => CallScreen(otherUserId: calleeId)),
        );
        return;
      }

      if (next.status == CallConnectionStatus.ended ||
          next.status == CallConnectionStatus.failed) {
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
      }
    });

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final contentWidth = constraints.maxWidth.clamp(0.0, 420.0);

              return Center(
                child: SizedBox(
                  width: contentWidth,
                  height: constraints.maxHeight,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: isSmallScreen ? 20 : 32,
                    ),
                    child: Column(
                      children: [
                        const Spacer(),

                        // -------------------------------------------------
                        // PROFILE
                        // -------------------------------------------------
                        _CallerAvatar(size: isSmallScreen ? 82 : 104),

                        SizedBox(height: isSmallScreen ? 16 : 22),

                        // -------------------------------------------------
                        // USER NAME
                        // -------------------------------------------------
                        calleeAsync.when(
                          loading: () => Text(
                            'Calling...',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          error: (_, _) => Text(
                            'Unknown User',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          data: (user) => Text(
                            user?.username ?? 'Unknown User',
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ),

                        const SizedBox(height: 8),

                        // -------------------------------------------------
                        // CALL STATUS
                        // -------------------------------------------------
                        Text(
                          'Ringing...',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                        ),

                        const Spacer(),

                        // -------------------------------------------------
                        // END CALL BUTTON
                        // -------------------------------------------------
                        Padding(
                          padding: EdgeInsets.only(
                            bottom: isSmallScreen ? 20 : 32,
                          ),
                          child: _EndCallButton(
                            onPressed: () {
                              ref.read(callProvider.notifier).endCurrentCall();
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _CallerAvatar extends StatelessWidget {
  const _CallerAvatar({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Icon(
        Icons.person,
        size: size * 0.48,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}

class _EndCallButton extends StatelessWidget {
  const _EndCallButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    final buttonSize = size.width < 360 ? 64.0 : 72.0;

    return SizedBox(
      width: buttonSize,
      height: buttonSize,
      child: FloatingActionButton(
        heroTag: 'outgoing_call_end',
        onPressed: onPressed,
        backgroundColor: Theme.of(context).colorScheme.error,
        foregroundColor: Theme.of(context).colorScheme.onError,
        elevation: 4,
        child: const Icon(Icons.call_end_rounded, size: 30),
      ),
    );
  }
}
