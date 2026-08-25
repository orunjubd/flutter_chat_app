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