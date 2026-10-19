import 'package:flutter/material.dart';

class EditMessageDialog extends StatefulWidget {
  const EditMessageDialog({super.key, required this.initialText});
  final String initialText;

  @override
  State<EditMessageDialog> createState() => _EditMessageDialogState();
}

class _EditMessageDialogState extends State<EditMessageDialog> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initialText,
  );

  @override
  void dispose() {
    _controller.dispose(); // runs only after the dialog is fully gone
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit message'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        minLines: 1,
        maxLines: 5,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),

          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _controller.text.trim()),
          child: const Text('Save'),
        ),
      ],
    );
  }
}
