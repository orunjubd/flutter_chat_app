import 'package:flutter/material.dart';

class GroupSenderLabel extends StatelessWidget {
  const GroupSenderLabel({
    super.key,
    required this.senderId,
    required this.name,
    this.onTap,
  });
  final String senderId;
  final String name;
  final VoidCallback? onTap;

  // --TODO(design-system): move to AppColors tokens.
  static const _palette = [
    Color(0xFFE57373),
    Color(0xFF64B5F6),
    Color(0xFF81C784),
    Color(0xFFFFB74D),
    Color(0xFFBA68C8),
    Color(0xFF4DB6AC),
    Color(0xFFF06292),
    Color(0xFFA1887F),
  ];

  /// Own hash: String.hashCode is not guaranteed stable across runs.
  static Color colorFor(String id) {
    var h = 0;
    for (final c in id.codeUnits) {
      h = (h * 31 + c) & 0x7fffffff;
    }
    return _palette[h % _palette.length];
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 6, top: 6, bottom: 2),
      child: GestureDetector(
        onTap: onTap,
        child: Text(
          name.isEmpty ? 'Unknown' : name,
          style: TextStyle(
            color: colorFor(senderId),
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
