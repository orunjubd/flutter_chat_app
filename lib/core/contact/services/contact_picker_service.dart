import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:chat_app/core/contact/models/contact_draft.dart';

class ContactPickerService {
  const ContactPickerService();

  /// Opens the native OS contact picker. Returns null if the user
  /// cancelled or the picked contact has no usable phone number.
  Future<ContactDraft?> pickContact() async {
    final status = await FlutterContacts.permissions.request(
      PermissionType.readWrite,
    );
    if (status != PermissionStatus.granted) {
      throw StateError('Contacts permission was denied.');
    }
    final contact = await FlutterContacts.native.showPicker(
      properties: {
        ContactProperty.name,
        ContactProperty.phone,
        ContactProperty.email,
        ContactProperty.address,
      },
    );
    if (contact == null) return null;

    if (contact.phones.isEmpty) {
      throw StateError('Selected contact has no phone number.');
    }

    debugPrint('✅ [ContactEngine] Contact picked: ${contact.displayName}');
    return ContactDraft(
      name: contact.displayName?.trim().isNotEmpty == true
          ? contact.displayName!.trim()
          : 'Unknown Contact',
      phone: contact.phones.first.number,
      email: contact.emails.isNotEmpty ? contact.emails.first.address : null,
      address: contact.addresses.isNotEmpty
          ? contact.addresses.first.formatted?.trim()
          : null,
    );
  }
}
