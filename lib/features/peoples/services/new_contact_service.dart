import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:chat_app/features/peoples/data/models/new_contact_draft.dart';

class NewContactService {
  const NewContactService();

  Future<void> saveContact(NewContactDraft draft) async {
    if (draft.firstName.trim().isEmpty) {
      throw ArgumentError('First name is required.');
    }
    if (draft.phoneNumber.trim().isEmpty) {
      throw ArgumentError('Phone number is required.');
    }

    final status = await FlutterContacts.permissions.request(
      PermissionType.readWrite,
    );
    if (status != PermissionStatus.granted) {
      throw StateError('Contacts permission was denied.');
    }

    final contact = Contact(
      name: Name(first: draft.firstName.trim(), last: draft.lastName.trim()),
      phones: [Phone(number: draft.fullPhoneNumber.trim())],
      emails: draft.email != null && draft.email!.trim().isNotEmpty
          ? [Email(address: draft.email!.trim())]
          : [],
      addresses: draft.address != null && draft.address!.trim().isNotEmpty
          ? [Address(formatted: draft.address!.trim())]
          : [],
    );

    await FlutterContacts.create(contact);
  }
}
