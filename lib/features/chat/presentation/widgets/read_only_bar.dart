import 'package:flutter/material.dart';

class ReadOnlyBar extends StatelessWidget {
  const ReadOnlyBar({super.key, required this.text});
  final String text;
  @override
  Widget build(BuildContext context) => SafeArea(
    top: false,
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).cardColor,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
      ),
    ),
  );
}
