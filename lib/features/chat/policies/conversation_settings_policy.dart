class ConversationSettingsPolicy {
  const ConversationSettingsPolicy();
  static const maxPinned = 3;

  String? validatePin(int currentlyPinned) => currentlyPinned >= maxPinned
      ? 'You can pin up to $maxPinned chats.'
      : null;
}
