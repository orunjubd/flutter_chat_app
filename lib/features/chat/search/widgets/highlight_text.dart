import 'package:flutter/material.dart';

import 'package:chat_app/core/extensions/theme_extensions.dart';

class HighlightText extends StatelessWidget {
  const HighlightText({
    super.key,
    required this.text,
    required this.query,
    this.maxLines,
    this.overflow,
  });

  final String text;
  final String query;

  final int? maxLines;
  final TextOverflow? overflow;

  @override
  Widget build(BuildContext context) {
    if (query.trim().isEmpty) {
      return Text(
        text,
        maxLines: maxLines,
        overflow: overflow,
        style: context.bodyText,
      );
    }

    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();

    final spans = <TextSpan>[];

    int start = 0;

    while (true) {
      final index = lowerText.indexOf(lowerQuery, start);

      if (index == -1) {
        spans.add(
          TextSpan(text: text.substring(start), style: context.bodyText),
        );
        break;
      }

      if (index > start) {
        spans.add(
          TextSpan(text: text.substring(start, index), style: context.bodyText),
        );
      }

      spans.add(
        TextSpan(
          text: text.substring(index, index + query.length),
          style: context.bodyText?.copyWith(
            fontWeight: FontWeight.bold,
            color: context.primaryColor,
            backgroundColor: context.primaryColor.withValues(alpha: .15),
          ),
        ),
      );

      start = index + query.length;
    }

    return RichText(
      maxLines: maxLines,
      overflow: overflow ?? TextOverflow.clip,
      text: TextSpan(children: spans),
    );
  }
}
