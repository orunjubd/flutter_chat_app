//import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:firebase_auth/firebase_auth.dart';
//import 'package:chat_app/core/video/models/video_message.dart';
import 'package:chat_app/core/contact/widgets/contact_message_bubble.dart';
//import 'package:chat_app/core/extensions/chat_bubble_theme_extension.dart';
import 'package:chat_app/core/location/widgets/location_message_bubble.dart';
import 'package:chat_app/core/video/widgets/fullscreen_video_player.dart';
import 'package:chat_app/features/calls/core/widgets/call_system_message_bubble.dart';
import 'package:chat_app/features/chat/presentation/widgets/file_message_bubble.dart';
import 'package:chat_app/features/chat/presentation/widgets/video_message_bubble.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:chat_app/core/extensions/theme_extensions.dart';
//import 'package:chat_app/core/theme/app_colors.dart';
import 'package:chat_app/core/utils/date_time_formatter.dart';
// import 'package:chat_app/features/chat/providers/reply_provider.dart';
import 'package:chat_app/features/chat/data/models/message.dart';
import 'package:chat_app/features/chat/presentation/widgets/reply_card.dart';
import 'package:chat_app/features/chat/presentation/widgets/message_menu.dart';
import 'package:chat_app/features/chat/providers/forward_provider.dart';
import 'package:chat_app/features/chat/presentation/screens/user_selection_screen.dart';
import 'package:chat_app/features/chat/presentation/widgets/reaction_bar.dart';
import 'package:chat_app/core/media/widgets/media_content.dart';
//----------------------------------------------------------------------------
// Perfect. This is the final cleanup of ChatBubble. After this step:

// ✅ ChatBubble = UI only
// ✅ MessageMenu = menu logic
// ✅ ReplyCard = reply UI
// ✅ ReplyPreview = input preview
// ✅ ReplyProvider = state
// ✅ Repository = database

//This is exactly the architecture we wanted.
//---------------------------------------------------------------------------

class ChatBubble extends ConsumerWidget {
  const ChatBubble({
    super.key,
    //required this.senderName,
    required this.messageData,
    required this.isMe,
    required this.isRead,
    required this.onDeleteForMe,
    required this.onDeleteForEveryone,

    required this.onReaction,

    required this.highlight,
  });

  final Message messageData;
  final bool isMe;
  final bool isRead;

  final VoidCallback onDeleteForMe;
  final VoidCallback? onDeleteForEveryone;

  final ValueChanged<String> onReaction;

  final bool highlight;

  bool get _deleted =>
      messageData.deletedForEveryone || messageData.deletedBy.isNotEmpty;

  String get _displayMessage {
    if (messageData.deletedForEveryone) {
      return 'This message was deleted';
    }

    return messageData.text;
  }

  BorderRadius get bubbleRadius => BorderRadius.only(
    topLeft: const Radius.circular(14),
    topRight: const Radius.circular(14),
    bottomLeft: Radius.circular(isMe ? 14 : 4),
    bottomRight: Radius.circular(isMe ? 0 : 14),
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
    // 📞 Call logs use their own dedicated bubble layout.
    //
    // IMPORTANT:
    // Do not place CallSystemMessage inside the generic
    // Material → Container message bubble.
    //
    // This removes the double-box inheritance problem and
    // allows the call log to control its own alignment,
    // background and shape.
    if (messageData is CallSystemMessage) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: CallSystemMessageBubble(
          message: messageData as CallSystemMessage,
          isMe: isMe,
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: GestureDetector(
        onLongPress: _deleted
            ? null
            : () {
                MessageMenu.show(
                  context: context,
                  ref: ref,
                  message: messageData,

                  canDeleteForEveryone: onDeleteForEveryone != null,

                  onDeleteForMe: onDeleteForMe,

                  onDeleteForEveryone: onDeleteForEveryone,

                  onReaction: onReaction,

                  onForward: () {
                    ref.read(forwardProvider.notifier).forward(messageData);

                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const UserSelectionScreen(),
                      ),
                    );
                  },
                );
              },

        child: Align(
          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
          child: Material(
            elevation: 1.5,
            color: Colors.transparent,
            borderRadius: isMe
                ? const BorderRadius.only(
                    topLeft: Radius.circular(14),
                    topRight: Radius.circular(14),
                    bottomLeft: Radius.circular(14),
                    bottomRight: Radius.circular(
                      4,
                    ), // Sharp tail corner on the bottom-right side!
                  )
                : const BorderRadius.only(
                    topLeft: Radius.circular(14),
                    topRight: Radius.circular(14),
                    bottomLeft: Radius.circular(
                      4,
                    ), // Sharp tail corner on the bottom-left side!
                    bottomRight: Radius.circular(14),
                  ),

            child: Container(
              width: messageData is CallSystemMessage
                  ? MediaQuery.of(context).size.width * 0.60
                  : null,
              constraints: messageData is CallSystemMessage
                  ? null
                  : BoxConstraints(maxWidth: context.screenWidth * .72),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: highlight
                    ? context.primaryColor.withValues(alpha: .30)
                    : _deleted
                    ? context.colorScheme.surfaceContainerHighest
                    : isMe
                    ? context.myBubbleColor
                    : context.otherBubbleColor,
                borderRadius: bubbleRadius,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //------------------------------------
                  // Sender
                  //------------------------------------
                  Text(
                    messageData.senderName,
                    style: context.bodyTextMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isMe
                          ? context.myBubbleTextPrimary
                          : context.colorScheme.onSurface,
                    ),
                  ),

                  //--------------------------------------------
                  // Forwarded
                  //------------------------------------
                  if (messageData.forwarded) ...[
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.forward,
                          size: 14,
                          color: context.textSecondaryColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          messageData.forwardedFromUserName == null
                              ? 'Forwarded'
                              : 'Forwarded from ${messageData.forwardedFromUserName}',
                          style: context.captionText?.copyWith(
                            fontStyle: FontStyle.italic,
                            color: context.textSecondaryColor,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 6),
                  ],

                  //------------------------------------
                  // Reply Card
                  //------------------------------------
                  if (messageData.replyToMessageId != null) ...[
                    const SizedBox(height: 6),

                    ReplyCard(
                      senderName: messageData.replyToSenderName ?? '',
                      message: messageData.replyToText ?? '',
                      compact: true,
                    ),
                  ],

                  const SizedBox(height: 6),
                  _deleted
                      ? Text(
                          _displayMessage,
                          style: context.bodyText?.copyWith(
                            fontStyle: FontStyle.italic,
                            color: context.textSecondaryColor,
                          ),
                        )
                      : switch (messageData) {
                          // 📞 CallSystemMessage is handled above the generic
                          // message container, so this case should never execute here.
                          CallSystemMessage m => CallSystemMessageBubble(
                            message: m,
                            isMe: isMe,
                          ),
                          // ChatBubble switch
                          ContactMessage m => ContactMessageBubble(
                            message: m,
                            isMe: isMe,
                          ),
                          VideoMessage m => VideoMessageBubble(
                            message: m,
                            isMe: isMe,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      FullscreenVideoPlayer(message: m),
                                ),
                              );
                            },
                          ),
                          LocationMessage m => LocationMessageBubble(
                            message: m,
                            isMe: isMe,
                          ),
                          TextMessage() => Text(
                            _displayMessage,
                            style: context.bodyText?.copyWith(
                              color: isMe
                                  ? context.myBubbleTextPrimary
                                  : context.colorScheme.onSurface,
                            ),
                          ),
                          LegacyMessage m when m.type == 'file' =>
                            FileMessageBubble(message: m, isMe: isMe),
                          LegacyMessage m => MediaContent(
                            message: m,
                            isMe: isMe,
                          ),
                        },

                  const SizedBox(height: 8),

                  //------------------------------------
                  // Reactions
                  //------------------------------------
                  if (messageData.reactions.isNotEmpty) ...[
                    const SizedBox(height: 6),

                    ReactionBar(
                      reactions: messageData.reactions,
                      currentUserId: currentUserId,
                    ),
                  ],

                  const SizedBox(height: 8),

                  //------------------------------------
                  // Time + Read receipt
                  //------------------------------------
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        DateTimeFormatter.messageTime(
                          messageData.createdAt.toDate(),
                        ),
                        style: context.captionText?.copyWith(
                          color: isMe
                              ? context.unreadReceiptColor
                              : context.textSecondaryColor,
                        ),
                      ),

                      if (isMe) ...[
                        const SizedBox(width: 4),

                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          child: Icon(
                            isRead ? Icons.done_all : Icons.done,
                            key: ValueKey(isRead),
                            size: 16,
                            color: isRead
                                ? context.readReceiptColor
                                : context.unreadReceiptColor,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
