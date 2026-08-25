// core/media/widgets/share_choice_sheet.dart
import 'package:flutter/material.dart';

enum ShareChoice { file, link }

Future<ShareChoice?> showShareChoiceSheet(BuildContext context) {
  return showModalBottomSheet<ShareChoice>(
    context: context,
    backgroundColor: const Color(0xFF1C1C1E),
    builder: (context) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.image_outlined, color: Colors.white),
            title: const Text(
              'Share photo/video',
              style: TextStyle(color: Colors.white),
            ),
            onTap: () => Navigator.pop(context, ShareChoice.file),
          ),
          ListTile(
            leading: const Icon(Icons.link, color: Colors.white),
            title: const Text(
              'Share link',
              style: TextStyle(color: Colors.white),
            ),
            onTap: () => Navigator.pop(context, ShareChoice.link),
          ),
        ],
      ),
    ),
  );
}
