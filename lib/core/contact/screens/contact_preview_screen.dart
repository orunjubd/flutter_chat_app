import 'package:flutter/material.dart';
import 'package:chat_app/core/contact/models/contact_draft.dart';

class ContactPreviewScreen extends StatefulWidget {
  const ContactPreviewScreen({
    super.key,
    required this.draft,
    required this.onSend,
  });
  final ContactDraft draft;
  final Future<void> Function(ContactDraft draft) onSend;

  @override
  State<ContactPreviewScreen> createState() => _ContactPreviewScreenState();
}

class _ContactPreviewScreenState extends State<ContactPreviewScreen> {
  bool _sending = false;

  Future<void> _send() async {
    if (_sending) return;
    setState(() => _sending = true);
    try {
      await widget.onSend(widget.draft);
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      setState(() => _sending = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to send contact: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Send contact')),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircleAvatar(
                      radius: 40,
                      child: Icon(Icons.person, size: 40),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.draft.name,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Text(
                      widget.draft.phone,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    if (widget.draft.email != null) Text(widget.draft.email!),
                    if (widget.draft.address?.trim().isNotEmpty == true)
                      Text(widget.draft.address!, softWrap: true),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _sending ? null : _send,
                icon: _sending
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.send),
                label: const Text('Send'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
