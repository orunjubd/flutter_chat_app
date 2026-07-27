# Changelog

## v1.2.0

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

## v1.2.1

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

# v1.2.3 — Email Verification Gate

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

## v1.3.0 — Authentication Complete / Chat Module Started

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

## [v1.6.0] - 2026-07-19

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

# v1.6.1 (Documentation & Architecture Update)

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

# v1.6.0

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

# v1.6.2 (Delete Messages)

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