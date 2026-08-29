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

---------------------------------------------------------------
# 🚀 ECE Chat v1.6.1
### Enterprise Theme Customization Architecture
---------------------------------------------------------------
---

## ✨ Overview

Version **1.6.1** introduces the completion of the Enterprise Theme Customization architecture.

Instead of styling widgets individually, the application now follows a centralized design system built on Flutter's Material 3 theme engine. Nearly every UI component automatically adapts between Light and Dark modes through reusable theme infrastructure.

This release focuses on maintainability, consistency, and future scalability rather than adding new messaging features.

---

# 🌟 Highlights

## 🎨 Complete Theme Customization

Implemented a fully centralized theme architecture including:

- AppTheme
- AppComponentTheme
- AppTextTheme
- Theme Extensions
- Theme Provider
- Theme Persistence
- Semantic Theme Getters

All widgets now obtain styling from the active ThemeData instead of using hardcoded colors.

---

## 💬 Chat Bubble Theme Extension

Introduced a dedicated ThemeExtension for chat bubbles.

Supports:

- My Bubble Color
- Other Bubble Color
- Read Receipt Color
- Unread Receipt Color

This removes chat-specific color logic from widgets and allows automatic adaptation between Light and Dark themes.

---

## 🧩 Material Component Registry

Centralized theming for:

- AppBar
- Card
- Dialog
- Navigation Drawer
- Menu
- Divider
- Bottom Sheet
- SnackBar
- FilledButton
- ElevatedButton
- OutlinedButton
- InputDecoration
- Checkbox
- Radio
- Switch
- ProgressIndicator
- ListTile

Individual widgets now rely entirely on the global component registry.

---

## 📝 Semantic Typography

Introduced reusable semantic typography helpers.

Examples:

- context.titleText
- context.subtitleText
- context.bodyText
- context.bodyTextMedium
- context.captionText
- context.labelTextLarge
- context.labelTextMedium
- context.errorText

This eliminates repeated TextStyle definitions across the project.

---

## 🎯 Theme Migration

Migrated UI widgets away from hardcoded styling.

Migration completed for:

- Chat Screen
- Chat Bubble
- Navigation Drawer
- Authentication Screens
- Input Fields
- Connectivity Banner
- Loading Overlay
- Conversation Components
- User Selection
- Message List
- Theme Selector

The UI is now almost completely theme-driven.

---

## 🧹 Codebase Cleanup

Reduced duplicated UI styling by centralizing:

- Colors
- Typography
- Borders
- Button Styles
- Input Decorations
- Component Themes

Resulting in a smaller, cleaner, and easier-to-maintain codebase.

---

# 🏗 Architecture Improvements

Added:

- ChatBubbleThemeExtension
- ThemeContextExtension shortcuts
- Private Theme Builder
- Reusable border helpers
- Theme persistence support

The architecture now separates:

Business Logic

↓

Presentation

↓

Theme Infrastructure

↓

Material Components

↓

Flutter Rendering

---

# 📈 Benefits

✔ Cleaner widgets

✔ Less duplicated code

✔ Easier maintenance

✔ Automatic Light/Dark adaptation

✔ Enterprise-ready design system

✔ Improved scalability

✔ Consistent UI throughout the application

---

# 🔜 Coming Next

The next development phase focuses on advanced messaging capabilities.

Planned features include:

- Delete for Everyone
- Delete for Me
- Edited Messages
- Reply to Messages
- Forward Messages
- Emoji Reactions
- Message Search

---

# Version

Current Version:

ECE Chat **v1.6.1**

Built with:

- Flutter
- Riverpod
- Firebase Authentication
- Cloud Firestore
- Material 3

---

Thank you for using ECE Chat.

The project continues to evolve toward a production-ready enterprise messaging platform.

-------------------------------------------------------------
ECE Chat v1.6.2 — Delete Messages
-------------------------------------------------------------
## 🚀 What's New

This release introduces Enterprise Soft Delete architecture.

### Features

- Delete for Me
- Delete for Everyone
- Deleted placeholder
- Firestore soft delete
- Future-ready messaging model

### Internal Improvements

- Message model upgraded
- Repository architecture improved
- UI rendering optimized
- Firestore updates simplified

This release prepares the project for:

- Edit Message
- Reply Message
- Emoji Reactions
- Forward Message

-------------------------------------------------------------
# 🚀 ECE Chat v1.6.7
### Enterprise Media upload architecture pipeline
-------------------------------------------------------------
Added
✅ Enterprise Media Pipeline (ECE)
✅ MediaDraft architecture
✅ MediaUploadRepository abstraction
✅ UploadService abstraction
✅ CloudinaryUploadService
✅ Backend-independent media design
✅ Image Preview screen
✅ Caption support
✅ Image compression pipeline
✅ Media upload provider
✅ Media upload notifier/state
✅ MediaMessageSender
✅ Image message Firestore model
✅ Chat bubble image rendering
✅ Caption rendering
✅ Cloudinary integration
✅ AttachmentSheet modular architecture
✅ ImagePickerService
✅ MediaContent widget
✅ Media configuration layer
✅ UploadResult model
✅ UploadConfig model

✅ Cloudinary upload
✅ Media upload architecture
✅ MediaMessageSender
✅ MediaUploadRepository
✅ Conversation Preview Engine
✅ Automatic conversation preview updates
✅ Animated loading
✅ Conversation preview updates
✅ Cross-device synchronization
✅ Stable image bubble layout
✅ Aspect-ratio based image rendering
✅ Media metadata persistence (dimensions, MIME type, size)
✅ Read receipts
✅ Reply
✅ Forward
✅ Reactions
✅ Search
✅ Presence
✅ Typing indicator
### Improved

• Better provider separation
• Cleaner repository architecture
• Backend independence (Cloudinary today, Firebase Storage or S3 tomorrow)
• Attachment actions architecture
• Image preview workflow
• Media model extensibility

• Cross-device conversation synchronization
• Chat scrolling after image upload
• Image rendering performance
• Bubble layout stability
• Caption rendering
• Sender name consistency

### Fixed

• Sender username now comes from currentUserProvider
• Image messages render correctly
• Caption rendering fixed
• Firestore media metadata stored correctly
• Media upload pipeline completed

• Conversation preview not updating
• Username showing as "Unknown" for media messages
• Bubble jumping while image loads
• Scroll behavior after image upload

---------------------------------------------------
# 🚀 ECE Chat v1.6.8
### — File Attachment Engine Complete
--------------------------------------------------- 

Added:
- Android file download engine
- Local temporary file handling
- PDF download/open support
- DOCX download/open support
- ZIP download support
- RAR download support
- APK download/open support
- File download progress/error handling
- MIME-aware file handling
- File Action Sheet
- Preview/Download actions
- MIME/type-based preview availability
- Android-compatible external file opening

Improved:
- Cloudinary raw file delivery
- File message bubble
- File metadata handling
- File attachment upload pipeline

Fixed:
- Cloudinary PDF/ZIP delivery restriction
- HTTP 401 raw-file delivery issue
- Incorrect image resource-type handling for documents
- Direct URL opening failures
- Unsupported file preview behavior

Testing:
- Pixel 6 ✅
- Nokia 6 ✅
- Xiaomi/MI Android device ✅
- Android emulator ⚠️ limited by installed compatible applications

Phase 4 File Attachment: COMPLETE ✅

---------------------------------------------------
# 🚀 ECE Chat v1.6.9
## [Unreleased]
### — Phase 4 — Media Engine 
#### Added — Voice Messages Complete
---------------------------------------------------
## Media Expansion Update

### Completed

#### Voice Messages

Phase 4.4 Voice Messages has been completed.

Implemented:

- Voice recording
- Microphone permission handling
- Start / stop / cancel recording
- Recording duration
- Voice file metadata
- Cloudinary upload
- Firestore voice message persistence
- Voice playback
- Play / pause / resume
- Single active voice playback
- Playback completion reset
- Seeking
- Backward-seek recovery
- Android codec recovery handling
- Voice message bubble
- Pixel 6 testing
- Nokia 6 testing
- Mi 9e testing

### Current Development

#### Phase 4.6 — Video Messages

Video messaging is now the active development target.

Planned implementation:

- Video selection
- Video recording
- Video preview
- MediaDraft integration
- Cloudinary video upload
- Video metadata
- Firestore message persistence
- Video message bubble
- Thumbnail generation/display
- Video playback
- Playback controls

### Paused

Phase 5 — Conversations is temporarily paused while Phase 4.6
Video Messages is implemented.

### Next Milestone

Complete Phase 4.6 Video Messages and validate the complete media
pipeline across the existing Android test devices.

---------------------------------------------------
# 🚀 ECE Chat v1.7.0
## [1.7.0] — Video Architecture
--------------------------------------------------- 
# `GitHubRELEASE.md`

## Release Summary

v1.7.0 completes the application's video messaging architecture and end-to-end video lifecycle.

## Highlights

### 🎥 Video Messaging
- Video attachment
- Video metadata extraction
- Thumbnail generation
- Cloudinary upload
- Video compression
- H.264 output
- 1080-resolution compression target
- Firestore persistence
- Video captions
- Real upload progress

### ▶️ Video Player

Implemented:

- Play
- Pause
- Resume
- Seek
- Mute / Unmute
- Duration
- Position
- Buffering
- Completion
- Lifecycle/disposal
- Fullscreen playback
- Portrait and landscape rendering

### 🏗 Architecture
Video messages use the existing shared conversation message architecture.

MediaDraft
   ↓
VideoCompressionService
   ↓
VideoUploadService
   ↓
VideoMessageSender
   ↓
ConversationMessageRepository
   ↓
Firestore
   ↓
VideoMessageBubble
   ↓
FullscreenVideoPlayer

---------------------------------------------------
# 🚀 ECE Chat v1.7.2
## v1.7.2 — Location Messages
--------------------------------------------------- 
## Highlights

📍 **Share your location in chat.** Tap the location attachment, confirm
or adjust the pin on an interactive map, and send — recipients see a
real map preview and can open it full-screen or in their native Maps
app.

## What's new

- One-time location sharing with a draggable-pin confirmation screen
- Reverse-geocoded address display (falls back to coordinates if
  unavailable)
- Full-screen, pannable/zoomable map view for received locations

## Fixes in this release

- Fixed an intermittent crash (`Using "ref" ... unmounted`) that could
  occur when quickly navigating away from a chat screen
- Fixed sender name occasionally showing as "Unknown" on media/location
  sends
- Fixed location previews rendering as a blank white map on some
  devices/networks
- Consolidated two duplicate location-capture code paths into one

## Upgrade notes

- New dependencies: `geolocator`, `flutter_map`, `latlong2`
- Removed dependency: `geocoding` (no longer used)
- Android: requires `ACCESS_FINE_LOCATION` / `ACCESS_COARSE_LOCATION` in
  `AndroidManifest.xml`
- iOS: requires `NSLocationWhenInUseUsageDescription` in `Info.plist`
- If your `applicationId`/bundle id is still the default Flutter
  template value (`com.example.*`), rename it before wide release — it
  is used as the map tile provider's identifying User-Agent and generic
  values are more likely to be rate-limited

## Known limitations

- "Live" (continuously updating) location sharing is not included in
  this release — planned for a future phase
- Address resolution depends on a public third-party service and may
  occasionally be unavailable; the app degrades to showing coordinates
  in that case

**Full changelog:** see `CHANGELOG.md` — `[1.7.2]`

---------------------------------------------------
# 🚀 ECE Chat v1.7.3
## v1.7.3 — Contact Sharing
--------------------------------------------------- 
## Highlights

👤 **Share a contact in chat.** Pick anyone from your device's contacts
and send their name, phone number, email, and address directly in a
conversation — recipients see the full contact card without needing
access to your address book.

## What's new
- Native contact picker (no in-app contact list UI — uses the OS's own
  picker)
- Contact preview before sending
- Full contact card rendered in the chat bubble

## Upgrade notes
- New dependency: `flutter_contacts: ^2.0.0`
- Android: requires `READ_CONTACTS` / `WRITE_CONTACTS` in
  `AndroidManifest.xml`, **and** the app must request the permission at
  runtime before picking (declaring it alone is not sufficient with
  this package version)
- iOS: requires `NSContactsUsageDescription` in `Info.plist`

## Known limitations
- Contact photos are not included by design — text fields only
- This is a one-time "share this contact" action, distinct from the
  planned Contacts/People-discovery screen (a different, upcoming
  feature for finding and starting new conversations)