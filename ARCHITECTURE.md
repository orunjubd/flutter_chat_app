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

####################################################################
# ECE Chat Architecture
####################################################################

This document describes the architecture of the ECE Chat application.

ECE Chat follows a feature-first, clean architecture approach with centralized theming, Riverpod state management, Firebase backend services, and reusable UI components.

---

# Architecture Overview

```
                Flutter UI
                     │
                     ▼
              Presentation Layer
                     │
                     ▼
                 Riverpod
              State Management
                     │
                     ▼
          Repository / Services Layer
                     │
                     ▼
            Firebase Backend
```

---

# Project Structure

```
lib/
│
├── core/
│   ├── extensions/
│   ├── providers/
│   ├── services/
│   ├── theme/
│   ├── utils/
│   └── widgets/
│
├── features/
│   ├── authentication/
│   ├── chat/
│   ├── settings/
│   └── users/
│
├── firebase_options.dart
│
└── main.dart
```

---

# Core Layer

The `core` module contains reusable infrastructure shared by every feature.

```
core/
│
├── extensions/
├── providers/
├── services/
├── theme/
├── utils/
└── widgets/
```

The Core layer must never depend on any feature module.

---

# Feature Layer

Each feature owns its own:

- data
- repositories
- providers
- presentation
- widgets

Example:

```
chat/
│
├── data/
├── providers/
├── presentation/
└── widgets/
```

This keeps features isolated and easier to maintain.

---

# Theme Architecture

ECE Chat uses a centralized Material 3 theme system.

```
AppTheme
      │
      ▼
AppComponentTheme
      │
      ▼
Material Components
```

The application never styles Material widgets individually unless absolutely necessary.

Instead, components inherit styling from the global theme.

---

# Theme Files

```
core/theme/

AppTheme
AppComponentTheme
AppTextTheme
AppColors
ThemePreference
```

Responsibilities

## AppTheme

Creates the Light and Dark ThemeData objects.

Responsible for:

- ColorScheme
- Typography
- Theme Extensions
- Material component registration

---

## AppComponentTheme

Central registry for every Material component.

Contains:

- AppBarTheme
- CardTheme
- DividerTheme
- DialogTheme
- BottomSheetTheme
- NavigationDrawerTheme
- MenuTheme
- ListTileTheme
- ElevatedButtonTheme
- FilledButtonTheme
- OutlinedButtonTheme
- InputDecorationTheme
- CheckboxTheme
- RadioTheme
- SwitchTheme
- ProgressIndicatorTheme

---

## AppTextTheme

Defines global typography.

The UI should consume:

- titleLarge
- titleMedium
- bodyLarge
- bodyMedium
- labelLarge
- labelMedium
- labelSmall

instead of creating custom TextStyles.

---

## AppColors

Contains reusable color tokens.

There are two categories:

### Theme-aware colors

Used automatically through ThemeData.

Examples:

- background
- surface
- outline
- onSurface

### Functional colors

Remain fixed regardless of theme.

Examples:

- success
- error
- warning
- online
- offline

---

# Theme Extensions

ECE Chat uses Theme Extensions for feature-specific colors.

Current extensions:

```
ThemeContextExtension
        │
        ▼
ChatBubbleThemeExtension
```

These provide semantic accessors such as:

```
context.myBubbleColor

context.otherBubbleColor

context.readReceiptColor

context.unreadReceiptColor

context.bodyText

context.captionText

context.titleText
```

This keeps UI widgets independent from hard-coded colors.

---

# State Management

Riverpod manages application state.

Examples:

```
Authentication

↓

currentUserProvider

↓

currentUserIdProvider

↓

userByIdProvider

↓

UI
```

Features communicate through providers rather than directly accessing Firebase.

---

# Repository Pattern

Every feature communicates with Firebase through repositories.

```
Presentation

↓

Provider

↓

Repository

↓

Firebase
```

Benefits:

- easier testing
- reusable logic
- separation of concerns

---

# Firebase Architecture

Current services

- Firebase Authentication
- Cloud Firestore

Future services

- Firebase Storage
- Firebase Cloud Messaging

---

# Conversation Architecture

Current model:

```
Conversation

↓

participantIds

↓

Messages

↓

Message
```

One Conversation

↓

Many Messages

Each conversation currently supports two participants.

---

# Message Flow

```
MessageInput

↓

ConversationMessageRepository

↓

Firestore

↓

MessageList

↓

ChatBubble
```

---

# Presence Flow

```
Lifecycle

↓

PresenceRepository

↓

Firestore

↓

Presence Provider

↓

Chat Screen
```

---

# UI Components

Reusable widgets include:

- AppDrawer
- AppScaffold
- LoadingOverlay
- ConnectivityBanner
- ConfirmationDialog
- ThemeSelectorTile
- ChatBubble
- MessageInput

---

# Responsive Design

The project includes a lightweight responsive helper.

Purpose:

- screen width breakpoints
- future tablet support
- future desktop support

---

# Design Principles

ECE Chat follows these principles:

- Feature-first architecture
- Reusable widgets
- Centralized theming
- Semantic styling
- Repository pattern
- Riverpod state management
- Material 3
- Minimal duplicated code
- Maintainable structure
- Enterprise scalability

---

# Current Status

Current Release

**v1.6.1**

Completed

- Authentication
- One-to-One Messaging
- Read Receipts
- Typing Indicator
- Presence
- Theme System
- Material Component Standardization
- Theme Extensions
- Responsive Helper

Next Milestone

- Production Logout
- Regression Testing

Future

- Delete Message
- Delete for Everyone
- Edit Message
- Reply
- Forward
- Emoji Reactions
- Message Search
- Voice Messages
- File Sharing
- Group Chat

-----------------------------------------------
core/
 └── media/
      config/
      factories/
      models/
      providers/
      repositories/
      services/
      widgets/

features/
 └── chat/
      media/

------------------------------------------------
# ARCHITECTURE.md ⭐⭐⭐⭐⭐
# ECE Chat App Architecture

## Overview

ECE Chat App follows a Feature-First architecture with Repository Pattern, Riverpod state management, Firebase backend services, and Cloudinary media storage.

The primary goals are:

* Scalability
* Maintainability
* Testability
* Separation of concerns
* Enterprise-ready code structure

---

## Project Structure

```text
lib/
│
├── core/
│   ├── dialogs/
│   ├── extensions/
│   ├── media/
│   ├── providers/
│   ├── services/
│   ├── theme/
│   ├── utils/
│   └── widgets/
│
├── features/
│   ├── authentication/
│   ├── chat/
│   ├── presence/
│   ├── search/
│   ├── settings/
│   └── users/
│
└── firebase_options.dart
```

---

# Architecture Layers

## Presentation Layer

Responsible for UI.

Examples:

* ChatScreen
* ConversationListScreen
* MessageInput
* MessageList
* ChatBubble
* MediaContent
* ReplyPreview
* SearchMessagesScreen

---

## Provider Layer

Riverpod providers coordinate state and repositories.

Examples:

* conversationProvider
* conversationMessagesProvider
* currentUserProvider
* typingProvider
* replyProvider
* themeProvider

---

## Repository Layer

Contains business logic and Firebase communication.

Examples:

* ConversationRepository
* ConversationMessageRepository
* MessageRepository
* PresenceRepository
* MediaUploadRepository

Repositories never contain UI.

---

## Service Layer

Reusable business services.

Examples:

* MediaMessageSender
* ReplyRepository
* RegistrationService

---

## Models

Immutable application models.

Examples:

* Message
* Conversation
* AppUser
* Presence
* MediaDraft

---

# Messaging Flow

```text
MessageInput

↓

ConversationMessageRepository

↓

MessageRepository

↓

Firestore

↓

conversationMessagesProvider

↓

MessageList

↓

ChatBubble
```

---

# Media Upload Flow

```text
Gallery

↓

Image Preview

↓

Caption

↓

Compression

↓

Cloudinary Upload

↓

MediaMessageSender

↓

ConversationMessageRepository

↓

Firestore

↓

Message Stream

↓

MediaContent
```

---

# Conversation Preview Flow

```text
Message Sent

↓

ConversationRepository

↓

updateConversationAfterMessage()

↓

Firestore

↓

Conversation Stream

↓

ConversationListScreen
```

---

# Current Features

Authentication

* Email & Password
* Registration
* Login
* Logout

Messaging

* One-to-one conversations
* Text messages
* Image messages
* Read receipts
* Reply
* Forward
* Reactions
* Search
* Delete for me
* Delete for everyone

Presence

* Online status
* Last seen
* Typing indicator

Media

* Cloudinary upload
* Image preview
* Compression
* Caption support
* Stable image layout
* Animated loading
* Metadata storage

---

# Future Architecture

Planned modules:

* Voice Messages
* Full Screen Image Viewer
* Video Messages
* Multi-image Upload
* Group Chat
* Push Notifications
* Archive
* Message Pinning
* Story/Status System
* End-to-End Encryption

---------------------------------------------------
# 🚀 ECE Chat v1.6.9
## [Unreleased]
### — Phase 4 — Media Engine 
#### Added — Voice Messages Complete
---------------------------------------------------
The media system follows a draft → upload → message-send architecture.

AttachmentActions
        │
        ▼
     Media UI
        │
        ▼
    MediaDraft
        │
        ▼
CloudinaryUploadService
        │
        ▼
 MediaMessageSender
        │
        ▼
 MessageRepository
        │
        ▼
   Firestore Message
        │
        ▼
    MediaContent

Voice Messages

Voice messages are implemented as a dedicated media type

VoiceRecorderWidget
        ↓
VoiceRecording
        ↓
MediaDraft(type: audio)
        ↓
CloudinaryUploadService
        ↓
MediaMessageSender.sendVoice()
        ↓
MessageRepository
        ↓
Firestore
        ↓
VoiceMessageBubble    

---------------------------------------------------
# 🚀 ECE Chat v1.7.0
## [Unreleased]
### — Phase 4 — Media Engine 
#### Added — Video Messages Complete
---------------------------------------------------

---

c

For the architecture document, I would add this under the current architecture/release section:

```md
## v1.7.0 — Video Architecture

The video messaging architecture is now complete.

### Video Module

```text
lib/
│
├── core/
│   ├── media/
│   │   	├── models/
│   │       	├── media_draft.dart		# Holds the uncompressed local file path on the phone's disk before upload
│   │      	└── upload_result.dart		# A universal model that catches the final Cloudinary link after upload
│   └── video/
│       ├── models/
│       │   ├── video_attachment.dart		# Holds raw link assets for incoming/outgoing multimedia files [INDEX
│       │   └── video_message_payload.dart	 # Combines the VideoUploadResult together with the user's custom text caption string
│       │   ├── video_message.dart		 # The final, safe data packet serialized into Firestore database collections
│       │   └── video_upload_result.dart	 # Extends UploadResult specifically to add movie width, height, and duration metrics
│       │
│       ├── providers/
│       │   ├── video_compression_service_provider.dart
│       │   ├── video_message_sender_provider.dart	<-- Global anchors that feed network routes straight to your 
│       │							chat screen buttons
│       │   ├── video_picker_provider.dart
│       │   ├── video_player_provider.dart		<-- A family provider that boots up isolated player instances 
│       │							 matching specific file links
│       │   ├── video_upload_provider.dart
│       │   ├── video_upload_progress_provider.dart	<-- Tracks the live, real-time download/upload numbers 
│       │ 							(0% to 100% rereding ring loader)
│       │   ├── video_upload_repository_provider.dart	<-- Global anchors that feed network routes straight to your 
│       │							chat screen buttons
│       │   └── video_thumbnail_provider.dart
│       │
│       ├── repositories/
│       │   └── video_upload_repository.dart		# Coordinates between your local storage workers and cloud network endpoints	
│       │
│       ├── services/
│       │   ├── video_upload_service.dart 
│       │   ├── video_compression_plugin_service.dart	<-- The concrete class that uses flutter_compress to shrink massive video 
│       │													bytes down before transmission
│       │   ├── video_compression_service.dart	<-- The parent interface blueprint contract rule sheet.
│       │   ├── video_message_sender.dart		<-- Gathers up your files, thumbnails, and captions, and commits the clean node 
│       │											payload directly into Firestore pipelines 
│       │   ├── video_metadata_service.dart
│       │   ├── video_picker_service.dart		<-- Triggers the phone's native system camera or media gallery selection sheets 
│       │   ├── video_thumbnail_service.dart		<-- Generates the lightweight preview image frame instantly so the chat layout doesn't lag
│       │   └── cloudinary_video_upload_service.dart	#Pipes the binary streams chunk-by-chunk up onto Cloudinary multimedia tracks
│       │
│       └── widgets/
│           ├── video_send_preview.dart	<-- The full-screen black overlay dialog where users watch their clip preview 
│											and type their captions before sending
│           ├── video_message_bubble_controller.dart 	<-- The lazy-loaded core engine that boots up native video 
│														streams only when the user taps play
│           └── fullscreen_video_player.dart	<-- Opens a full landscape view layout for immersive, uninterrupted video watching	 
│												
│												
├── features/
│   └── chat/
│       └── presentation/
│           └── widgets/
│               ├── chat_bubble.dart
│               ├── voice_message_bubble.dart
│               └── video_message_bubble.dart	<-- The message wrapper floating inside the chat feed layout that 
│														displays the lightweight thumbnail preview
│ 

=================
Video Data Flow
=================

VideoPickerService
        ↓
     MediaDraft
        ↓
VideoMetadataService
        ↓
VideoCompressionService
        ↓
VideoUploadService
        ↓
Cloudinary
        ↓
VideoMessageSender
        ↓
ConversationMessageRepository
        ↓
MessageRepository
        ↓
Firestore
        ↓
VideoMessage
        ↓
VideoMessageBubble
        ↓
FullscreenVideoPlayer

============================
Shared Message Architecture
============================
Video messages do not use a separate repository for common message persistence.

The shared flow is:

await _messageRepository.sendMessage(
  conversationId: conversationId,
  message: message,
);

"
await _conversationRepository.updateConversationAfterMessage(
  conversationId: conversationId,
  lastMessage: switch (message.type) {
    'image' => '📷 Photo',
    'video' => '🎥 Video',
    'voice' => '🎤 Voice message',
    'file' => '📎 File',
    _ => message.text,
  },
);
"
This ensures video messages participate in the same:

conversation activity updates
latest-message ordering
conversation preview
unread-message behavior
message persistence

as other message types.

===========================
Video Compression
===========================
The compression layer follows an abstraction-first design:

VideoCompressionService
        ↑
FlutterCompressVideoCompressionService

The application therefore depends on the compression contract rather than directly coupling callers to a specific compression implementation.

Current compression behavior:

Maximum target: 1080 × 1080
H.264 codec
Downscale-only
Already optimized videos can bypass compression
Metadata is re-extracted from the compressed output
Original media remains untouched

============================
Video Player Architecture
============================
VideoMessage
      ↓
VideoMessageBubble
      ↓
FullscreenVideoPlayer
      ↓
VideoMessageBubbleController
      ↓
VideoPlayerController

The player supports:

initialization
playback
pause/resume
seeking
mute/unmute
duration
position
buffering
completion
lifecycle/disposal
portrait/landscape rendering

The rendering layer uses responsive fitting rather than assuming a fixed video orientation, preventing layout overflow when portrait videos are rotated.

=======================
Video Upload Progress
=======================
Upload progress is handled as part of the video sending pipeline rather than being implemented as a second upload mechanism.

Video Selection
      ↓
Compression
      ↓
Upload
      ↓
Progress
      ↓
VideoMessage
      ↓
Firestore

The UI can therefore display upload progress while maintaining the same underlying message pipeline.

---------------------------------------------------
# 🚀 ECE Chat v1.7.2
## [Unreleased]
### — Phase 4 — Media Engine 
#### Added — # Architecture — Phase 4.7: Location Messages
---------------------------------------------------
## Overview

Location messages let a user share a one-time coordinate (optionally with a
human-readable address) inside a conversation. The feature follows the same
layered pattern established by Video (4.6) and reuses the existing message
engine — no new Firestore collections, no new repository class.

```
core/location/
├── models/
│   ├── location_draft.dart      ← pre-send, local-only data
│   └── location_message.dart    ← part of message.dart (sealed subtype)
├── providers/
│   ├── location_service_provider.dart
│   └── location_message_sender_provider.dart   (Provider.family<_, conversationId>)
├── screens/
│   └── location_preview_screen.dart   ← draggable-pin confirm screen
├── services/
│   └── location_service.dart          ← GPS capture + reverse geocoding
└── widgets/
    └── location_message_bubble.dart

core/media/widgets/  (shared, not location-specific)
└── fullscreen_map_viewer.dart

## Data flow

AttachmentActions
      │  (tap "Location")
      ▼
LocationService.getCurrentLocation()
      │  geolocator → coordinates
      │  LocationService.reverseGeocode() → OSM Nominatim → address
      ▼
LocationDraft (latitude, longitude, address?)
      │
      ▼
LocationPreviewScreen
      │  flutter_map, draggable center-pin, live re-geocode on drag
      ▼
LocationDraft (final, user-confirmed)
      │
      ▼
LocationMessageSender.sendLocation()
      │
      ▼
ConversationMessageRepository.sendMessage()
      │  (same repository every message type uses — no separate
      │   location repository; there is nothing location-specific
      │   about writing a message document or updating conversation
      │   preview/unread counts)
      ▼
Firestore: conversations/{id}/messages/{id}
      │
      ▼
Message.fromMap() → LocationMessage (sealed subtype)
      │
      ▼
ChatBubble → LocationMessageBubble
      │  tap
      ▼
FullscreenMapViewer (flutter_map, interactive pan/zoom,
                     "open in native Maps app")

## Key decisions

- **`LocationMessage` was built as its own sealed `Message` subtype from
  day one** — never routed through `LegacyMessage`. Unlike image/audio/
  document, there is no existing production Firestore data for this type
  to stay backward-compatible with, so there was no cost to doing it
  correctly immediately.
- **No repository layer specific to location.** `ConversationMessageRepository`
  already handles "write a message + update conversation preview/unread
  count" generically for every type. A location-specific repository would
  have duplicated that logic without doing anything location needs that
  the shared one doesn't already provide.
- **Reverse geocoding uses OSM Nominatim over HTTP, not the `geocoding`
  package.** The on-device Android `Geocoder` backend this package wraps
  depends on Google Play Services and is frequently unavailable (confirmed
  via emulator/device testing: `ex = ipiw: UNAVAILABLE`). Nominatim has no
  such dependency. Usage is rate-limited (~1 req/sec) and requires a real,
  identifying `User-Agent` header per OSM's policy.
- **Map tiles are served from CARTO's basemap CDN, not raw
  `tile.openstreetmap.org`.** Hitting OSM's tile servers directly under a
  generic `userAgentPackageName` (e.g. the default `com.example.*`
  template id) triggers OSM's fair-use blocking, which presented as a
  blank/white map with only the marker visible. CARTO's free tier is more
  tolerant of small/hobby-scale apps. Attribution is still required and
  displayed via `RichAttributionWidget`.
- **The draggable-pin UX uses a fixed screen-centered icon over a
  pannable map**, not a draggable `Marker` (flutter_map has no built-in
  marker drag). The map moves under a stationary pin; whatever sits at
  the exact center on release becomes the selected coordinate, debounced
  before triggering a re-geocode.
- **"Live location" (continuously updating shared position, matching
  WhatsApp/Telegram's separate live-share feature) is explicitly out of
  scope for this phase.** It requires background location streaming, a
  running Firestore update loop, an expiry window, and its own privacy
  UX — deferred to a future phase rather than folded into this one-time
  share.

## Known limitations (tracked, not blocking)

- Address resolution depends on a third-party public service (Nominatim)
  with rate limits; failures degrade gracefully to lat/long text, never
  block sending.
- No cleanup job yet for any locally cached data this feature might
  produce (none currently written to disk — flagged for parity with the
  existing video-thumbnail/share-cache cleanup debt already tracked).

---------------------------------------------------
# 🚀 ECE Chat v1.7.3
## [Unreleased]
### — Phase 4 — Media Engine 
#### Added — # Architecture — Phase 4.7: Contact (Share)
---------------------------------------------------

This phase is **only** the in-conversation "share a device contact as a
message" feature. It is deliberately separate from Phase 4.8
(Contacts / People-discovery screen — a navigation surface for finding
and starting conversations with people, living in the Drawer, not in
`ChatScreen`). The two share a name; they do not share code, screens,
or data model. Do not merge them.

## Folder structure

core/contact/
├── models/
│   ├── contact_draft.dart      ← pre-send, local-only
│   └── contact_message.dart    ← part of message.dart (sealed subtype)
├── providers/
│   ├── contact_picker_service_provider.dart
│   └── contact_message_sender_provider.dart
├── screens/
│   └── contact_preview_screen.dart
├── services/
│   └── contact_picker_service.dart
└── widgets/
    └── contact_message_bubble.dart

## Data flow

AttachmentActions ("Contact")
      │
      ▼
ContactPickerService.pickContact()
      │  1. request READ_CONTACTS at runtime (declaration alone is
      │     insufficient — flutter_contacts v2 enforces this explicitly)
      │  2. FlutterContacts.native.showPicker() — native OS picker
      ▼
ContactDraft (name, phone, email?, address?)
      │
      ▼
ContactPreviewScreen  → confirm/send
      │
      ▼
ContactMessageSender.sendContact()
      │
      ▼
ConversationMessageRepository.sendMessage()
      │  (same repository every message type uses)
      ▼
Firestore → Message.fromMap() → ContactMessage
      │
      ▼
ChatBubble → ContactMessageBubble

## Key decisions

- **Built as its own sealed `Message` subtype immediately** — same
  reasoning as Video and Location: no existing production data to stay
  backward-compatible with, so no reason to route through
  `LegacyMessage`.
- **No contact photo, no upload pipeline.** Deliberately text-only
  (name/phone/email/address) to avoid adding a new Cloudinary/upload
  step for a feature that doesn't need one.
- **No dedicated repository.** `ConversationMessageRepository` already
  handles message write + conversation preview/unread updates
  generically; nothing about sharing a contact needs different
  behavior there.
- **`flutter_contacts` v2 API, not v1.** `FlutterContacts.openExternalPick()`
  (v1) does not exist in v2 — the equivalent is
  `FlutterContacts.native.showPicker()`, a different namespace, not a
  renamed method. Permission must be explicitly requested via
  `FlutterContacts.permissions.request(PermissionType.readWrite)`
  before calling the picker; the Android manifest entry alone does not
  satisfy the runtime check.