// lib/core/theme/chat_bubble_theme_extension.dart
import 'package:flutter/material.dart';

class ChatBubbleThemeExtension
    extends ThemeExtension<ChatBubbleThemeExtension> {
  final Color myBubbleColor;
  final Color otherBubbleColor;
  final Color readReceiptColor;
  final Color unreadReceiptColor;

  const ChatBubbleThemeExtension({
    required this.myBubbleColor,
    required this.otherBubbleColor,
    required this.readReceiptColor,
    required this.unreadReceiptColor,
  });

  @override
  ThemeExtension<ChatBubbleThemeExtension> copyWith({
    Color? myBubbleColor,
    Color? otherBubbleColor,
    Color? readReceiptColor,
    Color? unreadReceiptColor,
  }) {
    return ChatBubbleThemeExtension(
      myBubbleColor: myBubbleColor ?? this.myBubbleColor,
      otherBubbleColor: otherBubbleColor ?? this.otherBubbleColor,
      readReceiptColor: readReceiptColor ?? this.readReceiptColor,
      unreadReceiptColor: unreadReceiptColor ?? this.unreadReceiptColor,
    );
  }

  @override
  ThemeExtension<ChatBubbleThemeExtension> lerp(
    ThemeExtension<ChatBubbleThemeExtension>? other,
    double t,
  ) {
    if (other is! ChatBubbleThemeExtension) return this;
    return ChatBubbleThemeExtension(
      myBubbleColor:
          Color.lerp(myBubbleColor, other.myBubbleColor, t) ?? myBubbleColor,
      otherBubbleColor:
          Color.lerp(otherBubbleColor, other.otherBubbleColor, t) ??
          other.otherBubbleColor,
      readReceiptColor:
          Color.lerp(readReceiptColor, other.readReceiptColor, t) ??
          other.readReceiptColor,
      unreadReceiptColor:
          Color.lerp(unreadReceiptColor, other.unreadReceiptColor, t) ??
          other.unreadReceiptColor,
    );
  }
}
