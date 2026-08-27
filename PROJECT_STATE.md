# Enterprise Chat Engine (ECE)

## Project State

Last Updated: 2026-07-30

---

# Current Version

v1.6.6

Release Name:
SearchMessages

---

# Flutter Environment

Flutter 3.41.x

Dart 3.11.x

Riverpod 3.x

Firebase

Cloud Firestore

Firebase Auth

Firebase Storage (planned)

---

# Architecture

Architecture Pattern

Feature-first Architecture

Riverpod State Management

Repository Pattern

Provider-driven UI

Conversation-based Messaging

Folder Structure

lib/

core/

features/

shared/

---

# Messaging Architecture

Database

conversations/

conversationId/

messages/

Features

✓ One-to-One Private Conversations

✓ Conversation List

✓ Message Repository

✓ Conversation Repository

✓ Reply System

✓ Forward System

✓ Message Search

✓ Reactions

✓ Read Receipts

✓ Presence

✓ Typing Indicator

✓ Connectivity Monitoring

---

# Authentication

✓ Login

✓ Register

✓ Logout

✓ Email Verification

✓ AuthGate

✓ Firebase Auth

---

# UI Features

✓ App Drawer

✓ Theme Support

✓ Conversation List

✓ Chat Screen

✓ Reply Preview

✓ Forward Preview

✓ Search Screen

✓ Search History

✓ Recent Searches

✓ Highlight Search Result

✓ Jump to Message

✓ Reaction Bar

✓ Forward Label

---

# Connectivity

✓ Internet Monitoring

✓ Offline Banner

✓ Online Banner

---

# Message Features

✓ Text Message

✓ Reply

✓ Forward

✓ Delete for Me

✓ Delete for Everyone

✓ Read Status

✓ Typing Status

✓ Presence

✓ Emoji Reactions

✓ Search

---

# Search Module

Status

Completed

Features

✓ Search Messages

✓ Highlight Keyword

✓ Search History

✓ Recent Searches

✓ Remove History

✓ Clear History

✓ Empty State

✓ Result Counter

✓ Jump to Message

✓ Auto Highlight

---

# Current Providers

Authentication

authProvider

AuthLoadingProvider

Messaging

conversationProvider

conversationMessagesProvider

replyProvider

forwardProvider

reactionProvider

searchProvider

searchHistoryProvider

Theme

themeProvider

Connectivity

connectivityProvider

Presence

presenceProvider

Typing

typingProvider

---

# Core Utilities

DateTimeFormatter

FirebaseErrorMapper

ConnectivityService

AppSnackBar

Theme Extensions

---

# Completed Phases

Phase 1

✓ Foundation

✓ Firebase

✓ Authentication

✓ Theme

Phase 2

✓ Messaging Foundation

✓ Conversation Architecture

✓ Reply

✓ Read Receipts

✓ Presence

✓ Typing

✓ Connectivity

Phase 3

✓ App Drawer

✓ Forward Messages

✓ Emoji Reactions

✓ Search Messages

---

# Current Roadmap

Current Phase

Phase 4

Media

Upcoming

□ Image Messages

□ Camera

□ Gallery

□ Firebase Storage

□ Image Viewer

□ Download

□ Share

Later

□ Voice Messages

□ Video Messages

□ File Sharing

□ Location Sharing

□ Group Chat

□ Message Pinning

□ Archive Chat

□ Starred Messages

□ Message Editing

□ Polls

---

# Known Improvements

Medium Priority

□ Better Highlight Animation

□ Search Suggestions

□ Message Date Chips

□ Search Filters

Low Priority

□ GIF Support

□ Sticker Support

□ Animated Emoji

---

# GitHub Releases

v1.6.4

ForwardMessage

v1.6.5

MessageReaction

v1.6.6

SearchMessages

---

# Notes

Current project is stable.

Search module completed.

Next development starts with Phase 4 (Media).

--------------------------------------------------------------
docs/

CHANGELOG.md

PROJECT_STATE.md

ROADMAP.md

VERSION_HISTORY.md

ARCHITECTURE.md

---------------------------------------------------
# 🚀 ECE Chat v1.6.9
## [Unreleased]
### — Phase 4 — Media Engine 
#### Added — Voice Messages Complete
---------------------------------------------------
# ECE Chat App — Project State

## Current Project State

ECE Chat App is currently in **Phase 4 — Media**.

## Completed Phases

### Phase 1 — Foundation

Status: COMPLETE

- Authentication
- Email verification
- User profile
- Riverpod architecture
- Firebase integration

### Phase 2 — Messaging Foundation

Status: COMPLETE

- One-to-one conversations
- Conversation creation
- Conversation list
- Message sending
- Read receipts
- Unread counts
- Typing indicator
- Presence
- Conversation ordering
- Conversation preview
- Connectivity monitoring
- Logout service
- Delete message

## Phase 3 — Messaging Features

Status: COMPLETE / IMPLEMENTED SCOPE

- Delete for everyone
- Delete for me
- Deleted message placeholder
- Edit message
- Reply
- Forward
- Emoji reactions
- Message search

## Phase 4 — Media

### 4.1 Profile Photos

Status: COMPLETE

### 4.2 Image Messages

Status: COMPLETE

### 4.3 File Attachments

Status: COMPLETE

Supported attachment scope includes:

- PDF
- DOCX
- ZIP
- APK

### 4.4 Voice Messages

Status: COMPLETE

Implemented:

- Recording
- Permission handling
- Start / stop / cancel
- Duration
- VoiceRecording model
- MediaDraft integration
- Cloudinary upload
- Firestore persistence
- Voice playback
- Play / pause / resume
- Single active playback
- Automatic completion reset
- Seek
- Backward seek recovery
- Codec completion protection
- VoiceMessageBubble

Tested on:

- Pixel 6
- Nokia 6
- Mi 9e

Voice recording and playback are currently considered stable
for the implemented scope.

### 4.6 Video Messages

Status: IN PROGRESS

Current focus.

Planned:

- Video picker
- Video recorder
- Video preview
- Video metadata
- Cloudinary upload
- Firestore persistence
- VideoMessageBubble
- Thumbnail
- Video playback
- Playback controls

## Phase 5 — Conversations

Status: PAUSED

Planned:

- Search Conversations
- Pin Conversations
- Archive
- Favorite
- Mute
- Conversation Filters

Phase 5 will resume after Phase 4.6 is completed.

## Current Development Target

**Phase 4.6 — Video Messages**

## Architecture Principle

Media follows:

UI
 ↓
MediaDraft
 ↓
Upload Service
 ↓
Media Message Sender
 ↓
Repository
 ↓
Firestore
 ↓
Media-specific UI

=====================================================
# Project State

_Last updated: v1.7.2 — Phase 4.7 (Location) complete._
=====================================================

## Phase 4 — Media & Attachments

| Phase | Feature              | Status              |
|-------|-----------------------|----------------------|
| 4.1   | Image messages         | ✅ Done (sends via `LegacyMessage`, not yet migrated to its own sealed subtype) |
| 4.2   | Fullscreen image viewer, save/share | ✅ Done |
| 4.3   | Document/file messages | ✅ Done (`LegacyMessage`) |
| 4.4   | Voice messages         | ✅ Done (`LegacyMessage`) |
| 4.5   | Video: capture/pick, compression, upload | ✅ Done |
| 4.6   | Video: send, playback, share/save, progress | ✅ Done — first type built as its own sealed `Message` subtype (`VideoMessage`) |
| 4.7   | Location messages      | ✅ Done (this release) — sealed `LocationMessage` |
| —     | Camera (photo + video capture) | ✅ Done, shares the existing image/video pipelines |
| 4.8   | **Live location** (continuous share) | 🕓 Deferred — scoped as a distinct future phase, not started |
| 4.9   | Contact messages       | 🚧 In progress — starting now |

## Known open items (not blocking, tracked)

- **`LegacyMessage` still holds image, voice, and file fields.** The
  sealed-message migration was intentionally done type-by-type
  (`Message` → `TextMessage` / `VideoMessage` / `LocationMessage` first,
  since those had no existing production data). Image/voice/file remain
  on the flat legacy shape until their turn.
- **No cleanup job for local temp files.** Video thumbnails
  (`video_thumbnails/`) and downloaded share-cache files
  (`share_cache/`) accumulate in the app's temp directory. A
  `MediaCacheCleanupService` exists and is ready to wire into app
  startup; the exact call site depends on `main.dart`, which hasn't
  been reviewed yet.
- **No "save to gallery" wiring confirmed end-to-end on-device** — code
  is in place (`gal` package) for both image and video fullscreen
  viewers; needs a device test pass.
- **Contact photos are intentionally out of scope** for the contact
  message feature — text-only (name/phone/email) to avoid adding a new
  upload step.

## Package/tooling notes worth remembering

- `ffmpeg_kit_flutter` — deprecated by its maintainer; not used.
- `flutter_compress` is used for video compression; new/less
  battle-tested than older alternatives — watch for regressions.
- Map tiles: CARTO basemap CDN (not raw OSM `tile.openstreetmap.org`,
  which rate-limits generic/shared app identifiers).
- Reverse geocoding: OSM Nominatim direct HTTP call (not the `geocoding`
  package — its on-device backend is unreliable on many Android
  configurations).

