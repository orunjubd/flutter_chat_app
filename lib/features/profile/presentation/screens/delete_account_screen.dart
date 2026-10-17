import 'package:chat_app/features/profile/services/account_deletion_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DeleteAccountScreen extends ConsumerStatefulWidget {
  const DeleteAccountScreen({super.key});
  @override
  ConsumerState<DeleteAccountScreen> createState() =>
      _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends ConsumerState<DeleteAccountScreen> {
  final _password = TextEditingController();
  bool _understood = false;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }

  Future<void> _delete() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref
          .read(accountDeletionServiceProvider)
          .delete(password: _password.text);
      if (mounted) Navigator.of(context).popUntil((r) => r.isFirst);
    } on AccountDeletionException catch (e) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = e.message;
        });
      }
    } catch (e, st) {
      debugPrint('❌ [Delete] failed: $e');
      debugPrintStack(stackTrace: st);
      if (mounted) {
        setState(() {
          _busy = false;
          _error = 'Could not delete the account. Try again.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Delete account')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Icon(Icons.warning_amber_rounded, size: 48, color: scheme.error),
          const SizedBox(height: 12),
          const Text(
            'This permanently deletes your account. You will leave all groups, your profile '
            'photo and contact details are removed, and other people will see "Deleted account" '
            'in your chats. This cannot be undone.',
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _password,
            obscureText: true,
            enabled: !_busy,
            decoration: const InputDecoration(
              labelText: 'Confirm your password',
            ),
            onChanged: (_) => setState(() {}),
          ),
          CheckboxListTile(
            value: _understood,
            onChanged: _busy
                ? null
                : (v) => setState(() => _understood = v ?? false),
            title: const Text('I understand this cannot be undone'),
            controlAffinity: ListTileControlAffinity.leading,
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(_error!, style: TextStyle(color: scheme.error)),
            ),
          const SizedBox(height: 12),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: scheme.error),
            onPressed: (_busy || !_understood || _password.text.isEmpty)
                ? null
                : _delete,
            child: _busy
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Delete my account'),
          ),
        ],
      ),
    );
  }
}
