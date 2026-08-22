# chat_app

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

###############################################################################
# ECE Chat
###############################################################################

> A modern, scalable Flutter chat application built with Firebase, Riverpod, and Material 3.

ECE Chat is designed using clean architecture principles with a focus on maintainability, reusable components, adaptive theming, and enterprise-grade code organization. The project serves both as a production-ready messaging application and as a learning resource for advanced Flutter development.

---

# Features

## Authentication

- Firebase Authentication
- Email & Password Sign In
- User Registration
- Email Verification
- Secure Logout

---

## Messaging

- One-to-One Private Conversations
- Real-Time Messaging
- Read Receipts
- Typing Indicator
- Online / Offline Presence
- Conversation Ordering
- Unread Message Counter
- Message Timestamp Formatting

---

## User Experience

- Material 3 Design
- Adaptive Light & Dark Themes
- Theme Selector
- Responsive Layout Helper
- Connectivity Banner
- Loading Overlay
- Confirmation Dialogs
- Reusable SnackBars
- Navigation Drawer

---

## Theme Architecture

ECE Chat uses a centralized theme system to keep the UI consistent and easy to maintain.

### Core Theme

- AppTheme
- AppComponentTheme
- AppTextTheme
- AppColors

### Theme Extensions

- ThemeContextExtension
- ChatBubbleThemeExtension

### Material Components

- AppBarTheme
- CardTheme
- DividerTheme
- DialogTheme
- BottomSheetTheme
- NavigationDrawerTheme
- MenuTheme
- ListTileTheme
- FilledButtonTheme
- ElevatedButtonTheme
- OutlinedButtonTheme
- InputDecorationTheme
- ProgressIndicatorTheme
- CheckboxTheme
- RadioTheme
- SwitchTheme

---

# Architecture

```
lib/
│
├── core/
│   ├── theme/
│   ├── extensions/
│   ├── providers/
│   ├── utils/
│   ├── widgets/
│   └── services/
│
├── features/
│   ├── authentication/
│   ├── chat/
│   ├── conversations/
│   ├── settings/
│   └── users/
│
└── main.dart
```

The project follows a feature-first architecture using:

- Flutter
- Riverpod
- Firebase Authentication
- Cloud Firestore
- Firebase Storage (planned)
- Firebase Cloud Messaging (planned)

---

# Technology Stack

- Flutter
- Dart
- Riverpod
- Firebase Authentication
- Cloud Firestore
- Material 3
- Intl
- Shared Preferences

---

# Current Release

**Version:** v1.6.1

Current status:

- Stable Theme System
- Stable Messaging Foundation
- Stable One-to-One Conversations
- Stable UI Standardization
- Documentation Updated

---

# Roadmap

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

---

# Documentation

Additional documentation is available in:

- CHANGELOG.md
- ARCHITECTURE.md
- ROADMAP.md
- TESTING.md
- VERSION_HISTORY.md
- TODO.md

---

# Development Status

Current branch is under active development.

The project continues to evolve with new messaging features, improved architecture, and enhanced user experience while maintaining a clean, scalable codebase.

---

# License

This project is intended for educational and personal development purposes.

---------------------------------------------------
# 🚀 ECE Chat v1.7.0
## [1.7.0] — Video Architecture
--------------------------------------------------- 
The video messaging architecture is now complete.

### Video Messaging

- Video selection and attachment
- Video metadata extraction
- Video thumbnail generation
- Cloudinary video upload
- Video compression
- H.264 compatibility
- Maximum 1080-resolution compression target
- Firestore `VideoMessage` persistence
- Video captions
- Real upload progress
- Video message bubble
- Fullscreen video player
- Responsive portrait and landscape playback

### Video Playback

The video player supports:

- Play
- Pause
- Resume
- Seek
- Mute / Unmute
- Duration
- Current position
- Buffering indicator
- Completion handling
- Lifecycle and controller disposal
- Portrait and landscape videos
- Fullscreen playback

### Video Pipeline

Video Selection
      ↓
MediaDraft
      ↓
Video Metadata
      ↓
Video Compression
      ↓
H.264 / 1080 Target
      ↓
Cloudinary Upload
      ↓
Upload Progress
      ↓
VideoMessage
      ↓
ConversationMessageRepository
      ↓
Firestore
      ↓
VideoMessageBubble
      ↓
FullscreenVideoPlayer