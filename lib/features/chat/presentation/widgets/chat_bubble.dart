//import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:chat_app/core/extensions/theme_extensions.dart';
import 'package:chat_app/core/theme/app_colors.dart';
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
    topLeft: const Radius.circular(18),
    topRight: const Radius.circular(18),
    bottomLeft: Radius.circular(isMe ? 18 : 4),
    bottomRight: Radius.circular(isMe ? 4 : 18),
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
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
        child: Material(
          elevation: 1.5,
          color: AppColors.transparent,
          borderRadius: bubbleRadius,
          child: Container(
            constraints: BoxConstraints(maxWidth: context.screenWidth * .72),
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

                //------------------------------------
                // Message
                //------------------------------------
                _deleted
                    ? Text(
                        _displayMessage,
                        style: context.bodyText?.copyWith(
                          fontStyle: FontStyle.italic,
                          color: context.textSecondaryColor,
                        ),
                      )
                    : MediaContent(
                        message:
                            messageData, // Passes your non-nullable Message data model token down seamlessly! [INDEX]
                        isMe: isMe,
                      ),

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
    );
  }
}
