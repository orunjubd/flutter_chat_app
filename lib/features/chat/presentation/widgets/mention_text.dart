import 'package:flutter/material.dart';

class MentionText extends StatelessWidget {
  const MentionText({
    super.key,
    required this.text,
    required this.mentions,
    required this.style,
    required this.highlight,
  });
  final String text;
  final Map<String, String> mentions; // uid -> name
  final TextStyle? style;
  final Color highlight;

  @override
  Widget build(BuildContext context) {
    if (mentions.isEmpty) return Text(text, style: style);
    final names = mentions.values.map(RegExp.escape).toList()
      ..sort((a, b) => b.length.compareTo(a.length)); // longest first
    final re = RegExp('@(${names.join('|')})');
    final spans = <InlineSpan>[];
    var last = 0;
    for (final m in re.allMatches(text)) {
      if (m.start > last) {
        spans.add(TextSpan(text: text.substring(last, m.start)));
      }
      spans.add(
        TextSpan(
          text: m.group(0),
          style: TextStyle(color: highlight, fontWeight: FontWeight.w700),
        ),
      );
      last = m.end;
    }
    if (last < text.length) spans.add(TextSpan(text: text.substring(last)));
    return Text.rich(TextSpan(style: style, children: spans));
  }
}
