# ARCHITECTURE.md ⭐⭐⭐⭐⭐

Authentication

AuthRepository
↓

Riverpod Provider
↓

AuthGate

-----------------

Conversation

ConversationRepository
↓

ConversationProvider
↓

ConversationListScreen

-----------------

Messages

ConversationMessageRepository
↓

ConversationMessageProvider
↓

ChatScreen

-----------------

Presence

PresenceRepository
↓

PresenceProvider

-----------------

Typing

TypingRepository
↓

TypingProvider