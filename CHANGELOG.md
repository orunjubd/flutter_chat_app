# Changelog
--------------------------------------------------------------
## v1.2.0
--------------------------------------------------------------
### Added

- Firebase Authentication
- Firestore User Profile
- Repository Pattern
- Riverpod Providers
- RegistrationService V1
- Auth Listener
- Logout
- ChatScreen Skeleton

### Changed

- Authentication architecture migrated to Feature-First design.

### Fixed

- Firestore permission issue
- Registration flow cleanup

# Changelog
--------------------------------------------------------------
## v1.2.1
--------------------------------------------------------------
### Added
- Production-safe RegistrationService
- Firebase Authentication rollback support
- AppUser returned from RegistrationService
- RegistrationService V2

### Changed
- Registration workflow refactored into transaction-safe service

### Fixed
- Prevent inconsistent Authentication and Firestore data when registration fails

# Changelog

## v1.2.2

### Added
- Email verification support after successful account registration.
- Centralized `AuthExceptionMapper` for translating Firebase Authentication errors into user-friendly messages.

### Changed
- Registration workflow now automatically sends a verification email.
- Authentication UI now displays mapped application errors instead of raw Firebase error messages.

### Improved
- Simplified authentication error handling.
- Removed duplicated Firebase exception logic from the UI layer.
- Increased separation of concerns between presentation and authentication services.
--------------------------------------------------------------
# v1.2.3 — Email Verification Gate
--------------------------------------------------------------
## Added

* Email verification workflow
* VerifyEmailScreen
* Refresh verification button
* Resend verification button
* Email verification repository methods
* Email verification provider
* Email verification routing via AuthGate

## Improved

* Authentication flow now prevents unverified users from accessing ChatScreen.
* Repository abstraction expanded with email verification APIs.
* Riverpod provider invalidation used to refresh verification state.

## Tested

* New account registration
* Firestore user creation
* Authentication login
* Email verification
* Refresh verification
* Logout
* Verified user login
* Authentication routing

Status:
Authentication module is fully functional and verified.
--------------------------------------------------------------
## v1.3.0 — Authentication Complete / Chat Module Started
--------------------------------------------------------------
### Authentication
- Completed Firebase Authentication
- Firestore user profile creation
- Email verification workflow
- Forgot password
- RegistrationService V2
- Enterprise exception mapping
- Reusable dialogs and snackbars
- Authentication gate
- Logout support
- Centralized validation system

### Architecture
- Feature-first architecture
- Repository pattern
- Riverpod providers
- Service layer
- Shared validators
- Shared dialogs

### Next
- Begin Chat module
- Message model
- Firestore messages
- Real-time messaging

# v1.3.1 (2026-07-05)

## Added
- Real-time Firestore message stream
- Riverpod StreamProvider for messages
- Message repository stream support
- Message List UI
- Automatic message updates without app restart

## Improved
- Chat architecture separation
- Repository → Provider → UI data flow
- Firestore message synchronization

## Status

### Authentication
- Firebase Authentication
- Email Verification
- Password Reset
- Registration Service V2
- Enterprise Validation
- Enterprise Error Handling

## [v1.3.3] - 2026-07-06

### Added
- Real-time message stream using Riverpod
- MessageList widget for rendering chat messages
- ChatBubble widget
- Automatic left/right bubble alignment
- Current user vs. other user bubble styling
- Message timestamp formatting
- Read receipt UI foundation (✓ / ✓✓ placeholder)

### Improved
- Refactored chat UI into reusable presentation widgets
- Better separation of responsibilities between ChatScreen, MessageList, and ChatBubble

### Tested
- Real-time messaging between two Firebase accounts
- Android Emulator ↔ Physical Android device
- Firestore synchronization
- Timestamp rendering
- User-specific bubble alignment

## [v1.3.4] - 2026-07-06

### Added
- Real-time Firestore message streaming
- Production ChatBubble widget
- Bubble animation
- Bubble alignment (Me / Others)
- Message timestamps
- Read receipt UI foundation
- Automatic scrolling to latest messages

### Improved
- Refactored message rendering into reusable widgets
- Better chat presentation architecture
- Enterprise-ready message flow

### Tested
- Two-device messaging
- Emulator ↔ Android device
- Real-time synchronization
- Auto-scroll behavior
- Bubble animations

# v1.3.5

## ✨ Added

### Typing Indicator (Step 23)

- Added TypingStatus model
- Added Firestore typing collection
- Added TypingRepository
- Added Riverpod typing providers
- Added real-time typing detection
- Added automatic idle timeout
- Added live "User is typing..." indicator
- Added two-device synchronization
- Added production cleanup for typing state

## Improved

- Unified username source using Firestore AppUser
- Reduced unnecessary Firestore writes
- Improved typing performance
- Cleaner repository architecture

# v1.3.6

## ✨ Added

### Read Receipts (Step 24)

- Added Firestore readBy synchronization
- Added MessageRepository read receipt methods
- Added Riverpod integration for read receipts
- Automatically marks messages as read
- Added animated read receipt icons
- Connected read receipts to Firestore
- Added production testing for two-device synchronization

## Improved

- Prevented duplicate read receipt updates
- Optimized Firestore writes
- Improved chat synchronization
- Prepared architecture for future private conversations

# v1.4.0

## Conversation Engine

### Added
- Conversation model
- Conversation repository
- Conversation provider
- User repository
- User selection
- Create/Open conversation
- Conversation message provider

### Improved
- ChatScreen migrated to conversation architecture
- MessageList migrated to conversation messages
- Read receipts migrated to conversation repository
- Presence system integrated
- Typing indicator integrated
- Repository API synchronized

### Architecture
- Conversation-based messaging foundation completed
- Legacy global message system retained for compatibility

# Changelog

All notable changes to this project will be documented in this file.

---

## ECE [1.5.0] - 2026-07-12

### Added
- Conversation architecture
- Conversation list
- Read receipts
- Unread badges
- Typing indicator
- Presence system
- Connectivity banner
- Logout service
- Friendly Firebase error mapping

### Improved
- Conversation ordering
- Conversation previews
- Provider lifecycle
- Logout cleanup
- AppScaffold architecture

### Fixed
- Firebase permission errors during logout
- Offline handling
- Connectivity recovery


# Changelog

All notable changes to this project will be documented in this file.

---

## [v1.5.1] - 2026-07-15

### 🎉 Added
- One-to-one private conversation architecture.
- Conversation-based message storage.
- Smart connectivity banner.
- Logout service with centralized cleanup.
- Connectivity monitoring across the application.
- Conversation ordering by latest activity.
- Unread message badges.
- Read receipts.
- Typing indicator.
- Online/offline presence.
- Delete message support.
- Friendly offline error handling.

### 🔄 Changed
- Migrated messages from the root `messages` collection to `conversations/{conversationId}/messages`.
- Updated repositories to use conversation-scoped messaging.
- Improved logout flow and provider cleanup.
- Improved conversation list timestamp formatting.
- Improved conversation preview handling.
- Updated stream providers to use `autoDispose`.

### 🐛 Fixed
- Fixed global-chat behavior where all users could see every message.
- Fixed one-to-one privacy isolation.
- Fixed conversation ordering updates.
- Fixed connectivity exception handling.
- Fixed logout permission issues.
- Fixed unread counter synchronization.

### 🔒 Security
- Conversations are now filtered by participant IDs.
- One-to-one conversations are isolated from other users.

# Changelog

All notable changes to this project will be documented in this file.

---
--------------------------------------------------------------
## [v1.6.0] - 2026-07-19
--------------------------------------------------------------
### ✨ Added

#### Enterprise Theme Engine

* Introduced a centralized enterprise theme architecture.
* Added Light, Dark and System theme support.
* Added persistent theme selection using `SharedPreferences`.
* Added Riverpod-based `ThemeProvider`.
* Added `ThemePreference` service for loading and saving user preferences.
* Added `ThemeExtensions` for cleaner theme access from `BuildContext`.
* Added reusable `ThemeBottomSheet` for theme selection.
* Added `ThemeSelectorTile` for the Settings/Navigation Drawer.
* Added reusable `SettingsTile` widget.

#### Theme Architecture

* Added centralized `AppComponentTheme`.
* Expanded `AppColors` into a design-token system.
* Added semantic color tokens for:

  * Borders
  * Dividers
  * Disabled elements
  * Light/Dark support colors
* Centralized Material 3 component styling.

### 🔄 Changed

#### Material Theme

* Refactored `AppTheme` to act as the application's theme assembler.
* Integrated:

  * `AppColors`
  * `AppTextTheme`
  * `AppComponentTheme`
* Configured Material 3 Light and Dark themes.
* Added support for automatic System Theme switching.

#### Component Standardization

* Standardized:

  * Input decorations
  * Buttons
  * Cards
  * AppBars
  * Dialogs
  * Bottom Sheets
  * SnackBars
  * List Tiles
  * Divider themes
* Began migrating reusable widgets to the centralized theme system.

### 🎨 Improved

* Reduced duplicated UI styling across the application.
* Improved consistency between Light and Dark themes.
* Simplified widget styling by moving common visual properties into the global theme.
* Established reusable design tokens for future UI development.
* Improved maintainability and scalability of the UI layer.

###################################################################
# Changelog
###################################################################
All notable changes to this project will be documented in this file.

The format is based on Keep a Changelog and this project follows Semantic Versioning.

---
--------------------------------------------------------------
# v1.6.1 (Documentation & Architecture Update)
--------------------------------------------------------------
Release Date: July 2026

## Added

### Documentation

- Updated project documentation for the new theme architecture.
- Added Theme Extension architecture documentation.
- Added Chat Bubble Theme Extension documentation.
- Updated Material 3 component standardization notes.
- Updated roadmap for upcoming messaging features.

### Theme Architecture

- Centralized Material component themes.
- Added semantic ThemeContextExtension helpers.
- Introduced reusable ChatBubbleThemeExtension.
- Improved Light/Dark adaptive UI behavior.
- Standardized color usage across the application.

### UI Standardization

Standardized the following Material components:

- AppBar
- Card
- Divider
- Dialog
- BottomSheet
- NavigationDrawer
- Menu
- ListTile
- FilledButton
- ElevatedButton
- OutlinedButton
- InputDecoration
- ProgressIndicator
- Checkbox
- Radio
- Switch

### Utilities

- Added reusable responsive helper.
- Improved DateTimeFormatter utility usage.
- Reduced duplicated widget styling.

## Changed

- Refactored AppTheme using a centralized private builder.
- Simplified theme configuration.
- Migrated UI widgets to semantic theme getters.
- Improved maintainability and scalability of the theme system.
- Unified chat bubble styling through Theme Extensions.

## Fixed

- Removed duplicated Material styling.
- Improved Light/Dark theme consistency.
- Fixed inconsistent color usage.
- Improved reusable component architecture.
- Reduced UI maintenance overhead.

---
--------------------------------------------------------------
# v1.6.0
--------------------------------------------------------------
## Added

### Chat Features

- One-to-one private conversations
- Read receipts
- Typing indicator
- Presence (Online / Offline)
- Unread message counters
- Conversation ordering
- Connectivity monitoring

### UI

- Theme selector
- Responsive helper
- Chat bubble improvements

### Infrastructure

- Repository cleanup
- Logout service foundation
- Improved provider architecture
- Better navigation flow

---

# v1.5.0

Previous stable release.
--------------------------------------------------------------
# v1.6.2 (Delete Messages)
--------------------------------------------------------------
## Added
- Delete for Me
- Delete for Everyone
- deletedForEveryone flag
- deletedBy list
- deletedAt timestamp
- Firestore delete placeholder support
- ChatBubble deleted message UI
- Enterprise delete architecture for future messaging features

## Changed
- Message model extended
- MessageRepository updated
- ConversationMessageRepository updated
- MessageList filtering logic improved

## Fixed
- Delete no longer permanently removes Firestore document
- Sender can delete for everyone
- Receiver can delete only for themselves


# CHANGELOG
--------------------------------------------------------------
## v1.6.3 — Reply Messages
--------------------------------------------------------------
**Release Tag:** `Reply`

### 🚀 Added

* Implemented **Reply to Message** functionality similar to WhatsApp.
* Long-press menu now includes a **Reply** action.
* Added `replyProvider` to manage the active reply state.
* Extended the `Message` model with reply metadata:

  * `replyToMessageId`
  * `replyToSenderId`
  * `replyToSenderName`
  * `replyToText`
* Messages now save reply metadata in Firestore.
* Added reply preview above the message composer.
* Added inline reply cards inside chat bubbles.
* Reply sender name and original message are displayed above replied messages.

### 🏗 Architecture

* Created reusable **ReplyCard** widget.
* Created reusable **ReplyPreview** widget.
* Created reusable **MessageMenu** widget.
* Refactored `ChatBubble` to use reusable components instead of embedding reply and menu UI.
* Improved separation of responsibilities following the Enterprise Conversation Engine (ECE) architecture.

### 🔄 Changed

* `MessageInput` now focuses only on composing and sending messages.
* Reply preview UI moved into its own reusable widget.
* `ChatBubble` now renders reply cards through the reusable `ReplyCard` widget.
* Message menu logic extracted into a reusable widget for future features.

### 🎨 UI Improvements

* Compact reply card inside chat bubbles.
* Full reply preview above the input field.
* Reply cards adapt correctly to Light and Dark themes.
* Improved spacing and typography for replied messages.

### 🛠 Refactoring

* Reduced duplicated UI code.
* Improved widget reusability.
* Prepared architecture for upcoming messaging features:

  * Forward Messages
  * Edit Messages
  * Emoji Reactions
  * Search Messages

### 🐞 Fixed

* Reply no longer opens the delete confirmation dialog.
* Fixed sender information displayed in reply preview.
* Fixed reply metadata persistence.
* Fixed reply preview dismissal.
* Improved chat bubble rendering consistency.

--------------------------------------------------------------
# v1.6.4 — ForwardMessage
--------------------------------------------------------------
## 🚀 Added
- Complete Forward Message architecture
- Forward Provider
- Forward Preview widget
- Forward option inside Message Menu
- Forwarded message metadata
- Forwarded badge inside ChatBubble
- Forward to existing conversation
- Forward to newly created conversation
- Automatic provider cleanup after forwarding
- PopScope cleanup for canceled forwarding

## ♻️ Refactored
- Reused UserSelectionScreen for forwarding workflow
- Reused ConversationMessageRepository
- Reused MessageMenu architecture
- Forward pipeline follows Enterprise Conversation Engine (ECE)

## 🛠 Improved
- Prevent forwarding deleted messages
- Better navigation flow after forwarding
- Cleaner provider lifecycle

## Architecture

Forward
 ├── forward_provider
 ├── forward_preview
 ├── MessageMenu
 ├── UserSelectionScreen
 ├── ConversationMessageRepository
 └── ChatBubble

 ## v1.6.5 — EmojiReactions

### Added
- Emoji reactions for chat messages
- Long-press message action menu with integrated reaction picker
- Real-time reaction synchronization via Firestore
- Multiple reaction types per message
- Per-emoji reaction counters
- Automatic reaction toggle (tap the same emoji again to remove)
- Highlight for the current user's reactions
- Reusable `ReactionBar` widget
- Reusable `ReactionPicker` widget
- Reusable reaction state provider

### Improved
- Reactions sorted by popularity
- Animated reaction chips
- Improved spacing and typography
- Cleaner message action workflow using a single popup menu

### Refactored
- Kept reaction UI modular and reusable
- Preserved ECE architecture by keeping message mutations inside `MessageRepository`

## v1.6.6 — SearchMessages

✨ Added
• Conversation message search
• Search screen
• Highlight matched keywords
• Jump directly to searched message
• Automatic message highlight after navigation
• Recent search history
• Remove individual search history
• Clear all search history
• Search result counter
• Empty state UI for search and history

🔄 Improved
• Search navigation flow
• ChatScreen auto-scroll behavior
• Search keyboard UX
• Message highlighting animation

🐞 Fixed
• Search cache cleanup
• Scroll positioning
• Highlight synchronization
• Search navigation stability

------------------------------------------------------
------------------------------------------------------
## v1.6.7 — Enterprise Media Pipeline
# CHANGELOG.md

# Changelog

All notable changes to this project are documented here.

---
Release Date: August 2026

## Added

### Media System

* Cloudinary media upload
* Image preview screen
* Caption support
* MediaDraft model
* MediaUploadRepository
* MediaMessageSender
* Media compression pipeline

### Image Rendering

* Stable image bubble layout
* Aspect-ratio rendering
* Animated image loading
* Image metadata storage
* MediaContent widget

### Conversation Engine

* Automatic conversation preview updates
* Last message synchronization
* Conversation timestamp updates
* Cross-device conversation refresh

---

## Improved

* Chat scrolling after image upload
* Bubble rendering performance
* Username handling for media messages
* Caption rendering
* Conversation synchronization
* Cross-device messaging reliability
* Message loading experience

---

## Fixed

* "Unknown" sender name for image messages
* Conversation list not updating
* Bubble resize while image loads
* Scroll issues after media upload
* Image layout instability
* Conversation preview synchronization

---

# Previous Releases

## v1.6.6

* Presence System
* Typing Indicator
* Reply Engine
* Forward Engine
* Search Engine

## v1.6.5

* Conversation Architecture
* Private Messaging
* Read Receipts
* Unread Counters

## v1.6.x

* Firebase Authentication
* Theme System
* Riverpod Migration
* Repository Pattern
* Feature-First Architecture

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

- Added voice recording functionality.
- Added `VoiceRecorderWidget`.
- Added microphone permission handling.
- Added recording start, stop, and cancel flows.
- Added `VoiceRecording` model for recording metadata.
- Added voice duration tracking.
- Added voice file-size tracking.
- Added voice `MediaDraft` integration.
- Added voice upload through Cloudinary.
- Configured Cloudinary voice uploads through the `video` resource path.
- Added voice message persistence in Firestore.
- Added `voiceUrl` and `voiceDurationMs` message fields.
- Added `VoiceMessageBubble`.
- Added single-active-voice playback behaviour.
- Added play/pause/resume functionality.
- Added playback completion handling.
- Added seek support.
- Added backward-seek recovery for problematic Android/OEM codecs.
- Added protection against spurious native `completed` events.
- Added seek-jitter protection.
- Added Pixel 6 and Nokia 6 / Mi 9e playback testing.
- Added separate active/static voice progress rendering to reduce unnecessary
  rebuilds of inactive voice messages.

### Current Status

- Phase 4.4 — Voice Messages: **Complete**
- Phase 4.6 — Video Messages: **In Progress**
- Phase 5 — Conversations: **Paused**

---------------------------------------------------
# 🚀 ECE Chat v1.7.0
## [1.7.0] — Video Architecture
--------------------------------------------------- 
### Added
- Completed Video Message architecture and end-to-end video messaging pipeline.
- Added dedicated video media model and Firestore serialization/deserialization.
- Added Cloudinary video upload integration.
- Added video thumbnail generation.
- Added video metadata extraction for dimensions, MIME type, file size, and duration.
- Added video compression service with a maximum target of 1080×1080.
- Added H.264 video compression for improved Android playback compatibility.
- Added video message sender integrated with `ConversationMessageRepository`.
- Added Firestore video message persistence.
- Added video message bubble with playback controls.
- Added fullscreen video player.
- Added Riverpod video player provider.
- Added real video upload progress support.
- Added video caption support.
- Added video playback controls:
  - Play
  - Pause
  - Resume
  - Seek
  - Mute / Unmute
  - Duration
  - Position
  - Buffering indicator
  - Completion handling
  - Player lifecycle and disposal
- Added responsive video rendering for portrait and landscape videos.
- Added video compression that skips unnecessary re-encoding for already optimized videos.

### Improved
- Video messages now use the shared `ConversationMessageRepository` message flow instead of duplicating conversation-message persistence logic.
- Video messages correctly update conversation activity and preview information through the shared conversation messaging architecture.
- Large videos are downscaled to a maximum 1080 resolution target before upload.
- Video dimensions are revalidated after compression and upload before being stored in the `VideoMessage`.
- Video playback layout now uses responsive fitting to prevent portrait/landscape rotation overflow.
- Video upload flow now returns cleanly from the preview screen to the chat screen after sending.
- Upload progress is displayed during video message transmission.

### Fixed
- Fixed missing conversation updates when sending video messages.
- Fixed incorrect/private video repository architecture that duplicated shared message persistence behavior.
- Fixed `VideoMessage.fromMap()` deserialization flow to use the shared `Message.fromMap()` factory.
- Fixed video repository/provider naming mismatch.
- Fixed duplicate video captions in the chat UI.
- Fixed video playback controls not responding from the chat screen.
- Fixed fullscreen video playback navigation.
- Fixed portrait-video `RenderFlex` overflow.
- Fixed landscape/rotated-video `RenderFlex` overflow.
- Fixed video player lifecycle and controller disposal issues.
- Fixed large-video playback compatibility by compressing videos to H.264/1080-target output.

### Tested
- `.mp4` video upload and Firestore persistence.
- Small optimized video upload.
- Larger video compression and upload.
- Portrait video playback.
- Landscape video playback.
- Rotated video playback.
- Play / Pause / Resume.
- Seek.
- Mute / Unmute.
- Duration and position.
- Buffering state.
- Completion.
- Video player lifecycle and disposal.
- Video captions.
- Real upload progress.
- Fullscreen playback.
- Android emulator testing.
- Pixel 6 testing.
- Vivo Android device testing.