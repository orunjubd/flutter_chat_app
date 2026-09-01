import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chat_app/features/peoples/data/models/new_contact_draft.dart';
import 'package:chat_app/features/peoples/data/models/country_code.dart';
import 'package:chat_app/features/peoples/providers/new_contact_provider.dart';
import 'package:chat_app/features/peoples/presentation/widgets/new_contact_form.dart';

class NewContactScreen extends ConsumerStatefulWidget {
  const NewContactScreen({super.key});

  @override
  ConsumerState<NewContactScreen> createState() => _NewContactScreenState();
}

class _NewContactScreenState extends ConsumerState<NewContactScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();

  CountryCode _countryCode = kCountryCodes.first; // defaults to Bangladesh here
  bool _saving = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);

    final draft = NewContactDraft(
      firstName: _firstNameController.text,
      lastName: _lastNameController.text,
      countryCode: _countryCode.dialCode,
      phoneNumber: _phoneController.text,
      email: _emailController.text.trim().isEmpty
          ? null
          : _emailController.text,
      address: _addressController.text.trim().isEmpty
          ? null
          : _addressController.text,
    );

    try {
      await ref.read(newContactServiceProvider).saveContact(draft);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Contact saved.')));
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Unable to save contact: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Contact')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: NewContactForm(
                  firstNameController: _firstNameController,
                  lastNameController: _lastNameController,
                  phoneController: _phoneController,
                  emailController: _emailController,
                  addressController: _addressController,
                  countryCode: _countryCode,
                  onCountryCodeChanged: (c) => setState(() => _countryCode = c),
                ),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _saving ? null : _save,
                icon: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save),
                label: const Text('Save Contact'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
