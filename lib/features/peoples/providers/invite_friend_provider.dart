// lib/features/peoples/providers/invite_friend_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chat_app/features/peoples/services/invite_friend_service.dart';

final inviteFriendServiceProvider = Provider<InviteFriendService>((ref) {
  return const InviteFriendService();
});
