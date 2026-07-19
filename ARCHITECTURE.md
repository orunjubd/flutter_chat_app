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

v1.6.0 -2026-07-19
### 🏗 Architecture

Implemented the Enterprise Theme Engine:

```
AppColors
        ↓
AppTextTheme
        ↓
AppComponentTheme
        ↓
AppTheme
        ↓
MaterialApp
```

The project now follows a centralized design system where reusable widgets inherit their appearance from the global theme instead of relying on hard-coded colors.



