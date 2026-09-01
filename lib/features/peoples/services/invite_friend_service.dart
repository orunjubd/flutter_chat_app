// lib/features/peoples/services/invite_friend_service.dart
import 'package:share_plus/share_plus.dart';

class InviteFriendService {
  const InviteFriendService();
  // TODO: replace with a real app store / deep link once available
  // (e.g. Firebase Dynamic Links or a plain Play Store / App Store URL).
  static const _inviteMessage = '''
Join me on our Chat App! Let's connect and chat together. Download the app and find me there.''';

  Future<void> shareInvite() async {
    await SharePlus.instance.share(
      ShareParams(text: _inviteMessage, subject: 'Join me on Chat App'),
    );
  }
}
