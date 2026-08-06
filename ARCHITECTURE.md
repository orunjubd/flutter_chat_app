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
