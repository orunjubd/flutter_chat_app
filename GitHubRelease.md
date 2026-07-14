ECE Core v1.5.0

Highlights

• Production-ready messaging foundation
• Conversation architecture
• Presence
• Typing indicator
• Read receipts
• Unread badges
• Connectivity banner
• Logout pipeline

Tested

✓ Emulator
✓ Nokia Android 10
✓ Offline mode
✓ Online recovery
✓ Logout
✓ Messaging
✓ Read receipts

# ECE Chat v1.5.1

## Highlights

This release marks the completion of the core messaging foundation.

### New Features

- Private one-to-one conversations
- Conversation architecture
- Read receipts
- Typing indicator
- Presence system
- Unread badges
- Connectivity monitoring
- Smart connectivity banner
- Delete message
- Logout service

### Improvements

- Repository synchronization
- Better provider lifecycle management
- Improved conversation ordering
- Better timestamp formatting
- Cleaner logout workflow

### Security

Messages are now stored inside:

conversations/{conversationId}/messages

instead of a shared global collection, ensuring proper conversation isolation.

### Next Milestone

Phase 3.0

- Navigation Drawer
- Conversation synchronization engine
- Delete for Everyone
- Edit Message
- Reply
- Emoji reactions