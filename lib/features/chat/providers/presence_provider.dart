import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:chat_app/features/chat/data/models/presence.dart';
import 'package:chat_app/features/chat/data/repositories/presence_repository.dart';

///------------------------------------------------------------
/// Presence Repository Provider
///------------------------------------------------------------
final presenceRepositoryProvider = Provider<PresenceRepository>((ref) {
  return PresenceRepository();
});

///------------------------------------------------------------
/// Current User Presence Stream
///------------------------------------------------------------
final currentUserPresenceProvider = StreamProvider.autoDispose<Presence?>((
  ref,
) {
  final user = FirebaseAuth.instance.currentUser;

  if (user == null) {
    return Stream.value(null);
  }

  final repository = ref.read(presenceRepositoryProvider);

  return repository.presenceStream(user.uid);
});
