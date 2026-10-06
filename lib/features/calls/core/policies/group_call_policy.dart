import '../models/call_type.dart';

/// Group-call limits live here, not in widgets (ECERules §3).
class GroupCallPolicy {
  const GroupCallPolicy();

  static const maxVideoParticipants = 8;
  static const maxVoiceParticipants = 16;
  static const minParticipants = 3; // creator + 2 invitees
  static const ringTimeout = Duration(seconds: 30);

  int maxFor(CallType type) =>
      type == CallType.video ? maxVideoParticipants : maxVoiceParticipants;

  /// Returns a user-facing error, or null if the call may start.
  String? validateStart({required CallType type, required int inviteeCount}) {
    final total = inviteeCount + 1;
    if (total < minParticipants) {
      return 'Select at least ${minParticipants - 1} people.';
    }
    if (total > maxFor(type)) {
      return 'A group ${type.name} call allows up to ${maxFor(type)} people.';
    }
    return null;
  }
}
