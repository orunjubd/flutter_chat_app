import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chat_app/features/peoples/services/new_contact_service.dart';

final newContactServiceProvider = Provider<NewContactService>((ref) {
  return const NewContactService();
});
