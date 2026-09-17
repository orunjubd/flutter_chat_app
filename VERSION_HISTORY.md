v1.0.0
Authentication

v1.1.0
Firebase

v1.2.0
Presence

v1.3.0
Messaging

v1.4.0
    Conversation architecture

↓

v1.5.0
    Connectivity
    Presence
    Logout
    Smart Banner
    Production polish

↓

v1.5.1
    One-to-one security fix
    Conversation-scoped messages
    Repository refactor
    Private messaging stabilization

#########################################################################
# Version History
#########################################################################

This document provides a high-level overview of the ECE Chat release history.

---

# v1.6.1
**Status:** Current Stable Documentation Release

Release Date: July 2026

## Highlights

### Documentation
- Updated all project documentation.
- Synchronized architecture documents with the current codebase.
- Improved GitHub release documentation.
- Updated roadmap and testing guides.

### Theme Architecture
- Centralized Material 3 component theming.
- Introduced semantic Theme Extensions.
- Added ChatBubbleThemeExtension.
- Standardized reusable UI components.
- Completed Light/Dark adaptive theme migration.

### Code Quality
- Reduced duplicated styling.
- Improved maintainability.
- Cleaner theme architecture.
- Better reusable component design.

---

# v1.6.0
**Status:** Stable Feature Release

## Highlights

### Messaging
- One-to-one private conversations
- Read receipts
- Typing indicator
- Online / Offline presence
- Conversation ordering
- Unread message counters

### User Experience
- Theme selector
- Responsive helper
- Improved chat interface
- Connectivity monitoring

### Infrastructure
- Repository improvements
- Logout service foundation
- Provider architecture improvements
- Navigation cleanup

---

# v1.5.0
**Status:** Stable

## Highlights

- Firebase Authentication
- Cloud Firestore integration
- Conversation architecture
- Basic messaging
- Navigation Drawer
- Theme switching foundation

---

# Planned Releases

## v1.6.x
- Production Logout
- Regression Testing

## v1.7.x
- Delete Message
- Delete for Everyone
- Edit Message
- Reply to Message

## v1.8.x
- Forward Message
- Emoji Reactions
- Message Search
- Voice Messages
- File Sharing

## v2.0.0
- Group Chat
- Push Notifications
- End-to-End Message Encryption

## v1.6.2

Release Date:
2026

Highlights

✓ Delete for Me
✓ Delete for Everyone
✓ Firestore soft delete
✓ Deleted placeholder
✓ Future-ready delete architecture
## GitHub v1.8.1

**Project:** ECE Chat\
**Phase:** Phase 4 --- Media\
**Completed step:** 4.9 --- Voice Call\
**Status:** COMPLETE / STABLE

### Step 4.9 --- Voice Call

The current implementation includes the complete one-to-one voice-call
flow: - outgoing call - incoming call - accept - reject - LiveKit
connection - microphone control - speaker control - call termination -
repeated calls - call history - call system messages -
CallKit/background acceptance support - incoming listener restoration

### Next Version Work

The next development target is:

**Phase 4 → Step 4.10 --- Video Call**

The first video-call task is:

**Step 4.10.1 --- Video Call Signaling**

### Versioning Rule

Future releases should extend this current baseline rather than
restoring obsolete roadmap states from older documentation.

===========================================
# Version History

| Version | Summary |
|---|---|
| v1.8.1 | Phase 4.9 —  Voice Call: Speaker, mute/unmute, incomingCallScreen correction, Black Screen / Red Screen correction, use copyWith.State, update GlobalIncomingCalllistner, few method update CallProvider |
| v1.8.0 | Phase 4.9 —  Voice Call: includes the complete one-to-one voice-call; flow: - outgoing call - incoming call - accept - reject - LiveKit
connection - microphone control - speaker control - call termination - repeated calls - call history - call system messages - CallKit/background acceptance support - incoming listener restoration|
| v1.7.4 | Phase 4.8 — Peoples: search, sort, invite friends, save new device contact, Group/Community entry-point stubs. |
| v1.7.3 | Phase 4.7 — Contact sharing: native contact picker, name/phone/email/address, preview, sealed `ContactMessage`. |
| v1.7.2 | Phase 4.6 — Location messages: capture, adjustable-pin preview, address resolution, full-screen map view. Fixed sender-name race condition, a `ref`-after-dispose crash in `ChatScreen`, and blank/white map tiles. |
| v1.7.1 | Phase 4.5 —  Video messages complete: send, playback (play/pause/seek/mute/buffering), upload progress indicator, save-to-gallery and share (file or link) for both image and video fullscreen viewers. |
| v1.7.0 | Phase 4.5 — Video capture, compression (`flutter_compress`, H.264, downscale-only to a configurable max dimension), and Cloudinary upload pipeline. |
| v1.6.x | Phase 4.6 — Camera integration — photo and video capture routed through the existing image/video pipelines, with shared validation. |
| v1.5.x | Sealed `Message` migration begins — `TextMessage` and `VideoMessage` built as proper subtypes; `LegacyMessage` introduced as a temporary holding type for image/voice/file. |
| v1.4.x | Voice messages — recording, upload, waveform-style playback bubble. |
| v1.3.x | Document/file messages — picker, upload, download-and-open, share. |
| v1.2.x | Image messages — gallery/camera picker, compression, preview, fullscreen viewer. |
| v1.1.x | Core messaging — text, reply, forward, reactions, read receipts, presence/typing indicators. |
| v1.0.0 | Initial release — authentication, conversation list, one-to-one chat. |

_Earlier pre-1.0 history not tracked in this file._
