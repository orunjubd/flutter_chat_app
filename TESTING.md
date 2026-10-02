## TESTING.md ⭐⭐⭐⭐

Authentication

✓ Login
✓ Logout
✓ Verify Email

Conversation

✓ Ordering
✓ Read Receipt
✓ Unread Badge

Connectivity

✓ Offline
✓ Recovery

Presence

✓ Online
✓ Offline

Typing

✓ Indicator

Messaging

✓ Send
✓ Receive

### 🧪 Tested   v1.6.1

* Theme persistence after app restart.
* Light Theme.
* Dark Theme.
* System Theme.
* Theme switching from Navigation Drawer.
* Material 3 component rendering.
* Authentication screens.
* Shared widget compatibility.
* Riverpod state synchronization.


-------------------------------------------------------------------
# 🧪 TESTING.md
-------------------------------------------------------------------

## ECE Chat Testing Guide

---

# Current Version

**v1.6.1**

---

# Test Environment

| Item | Status |
|------|--------|
| Flutter | ✅ |
| Riverpod | ✅ |
| Firebase Authentication | ✅ |
| Cloud Firestore | ✅ |
| Material 3 | ✅ |

---

# Authentication

## Login

- [x] Email login
- [x] Password validation
- [x] Invalid credential handling
- [x] Loading indicator
- [x] Firebase authentication

---

## Registration

- [x] Username validation
- [x] Email validation
- [x] Password validation
- [x] Confirm password validation
- [x] Email verification
- [x] Firestore user creation

---

## Logout

- [x] User signs out correctly
- [x] Provider cleanup
- [x] Authentication state resets
- [x] Navigation returns to AuthGate

---

# Conversations

## Conversation List

- [x] Conversation loads
- [x] Last message displayed
- [x] Conversation timestamp updates
- [x] Unread badge updates
- [x] Empty conversation state

---

# Chat Screen

## Messaging

- [x] Send message
- [x] Receive message
- [x] Auto-scroll
- [x] Message ordering
- [x] Read receipts
- [x] Typing indicator
- [x] Online presence
- [x] Last seen

---

## Message Bubble

- [x] Outgoing bubble
- [x] Incoming bubble
- [x] Read receipt icon
- [x] Unread receipt icon
- [x] Timestamp display
- [x] Long-press menu
- [x] Delete confirmation dialog

---

# Theme Customization (v1.6.1)

## Light Theme

- [x] App launches in Light Mode
- [x] Theme loads without visual flicker
- [x] AppBar colors
- [x] Drawer colors
- [x] Cards
- [x] Dialogs
- [x] Buttons
- [x] Input fields
- [x] Chat bubbles
- [x] Read receipt colors
- [x] Typography

---

## Dark Theme

- [x] Theme switches correctly
- [x] AppBar updates
- [x] Drawer updates
- [x] Card colors
- [x] Dialog colors
- [x] Buttons
- [x] Inputs
- [x] Chat bubbles
- [x] Read receipt colors
- [x] Unread receipt colors
- [x] Typography

---

## Theme Persistence

- [x] User changes theme
- [x] Preference saved
- [x] App restart restores theme
- [x] No theme flashing
- [x] Riverpod synchronization

---

## Theme Extensions

### ChatBubbleThemeExtension

- [x] myBubbleColor
- [x] otherBubbleColor
- [x] readReceiptColor
- [x] unreadReceiptColor

---

## ThemeContextExtension

Verify all shortcut getters:

- [x] colorScheme
- [x] textTheme
- [x] cardColor
- [x] dividerColor
- [x] scaffoldBackgroundColor
- [x] primaryColor
- [x] secondaryColor
- [x] surfaceColor
- [x] textSecondaryColor
- [x] errorColor

Typography shortcuts:

- [x] titleText
- [x] subtitleText
- [x] bodyText
- [x] bodyTextMedium
- [x] labelTextLarge
- [x] labelTextMedium
- [x] captionText
- [x] errorText

Chat bubble shortcuts:

- [x] myBubbleColor
- [x] otherBubbleColor
- [x] readReceiptColor
- [x] unreadReceiptColor

---

# Component Themes

Verify global Material component themes:

- [x] AppBarTheme
- [x] CardTheme
- [x] DividerTheme
- [x] DialogTheme
- [x] NavigationDrawerTheme
- [x] MenuTheme
- [x] BottomSheetTheme
- [x] SnackBarTheme
- [x] FilledButtonTheme
- [x] ElevatedButtonTheme
- [x] OutlinedButtonTheme
- [x] InputDecorationTheme
- [x] CheckboxTheme
- [x] RadioTheme
- [x] SwitchTheme
- [x] ProgressIndicatorTheme
- [x] ListTileTheme

---

# Connectivity

- [x] Offline banner
- [x] Online banner
- [x] Automatic reconnect
- [x] Snackbar visibility

---

# Performance

- [x] No unnecessary rebuilds
- [x] Theme switch animation remains smooth
- [x] No dropped frames during theme changes
- [x] Drawer opens smoothly
- [x] Chat scrolling remains responsive

---

# Regression Testing

Verify previously completed functionality remains operational after the v1.6.1 theme migration:

- [x] Authentication
- [x] Navigation
- [x] Messaging
- [x] Presence
- [x] Typing indicator
- [x] Read receipts
- [x] Conversation list
- [x] Theme persistence

---

# Future Testing (v1.7.0)

Planned test cases:

- [ ] Delete for Me
- [ ] Delete for Everyone
- [ ] Edited Messages
- [ ] Reply to Message
- [ ] Forward Message
- [ ] Emoji Reactions
- [ ] Message Search

---

**Status**

✅ Stable

Current Release: **ECE Chat v1.6.1**

=======================================
## 1.8.4
=======================================

### Voice call (v1.8.4)

- Test on two devices; callee must be a real phone for FCM/CallKit.
- Dev only: run `node push_relay/relay.js` while testing background calls.
- Matrix: foreground / background / killed × accept / decline / caller cancel / 
timeout.

=======================================
### Video call (v1.8.5)
========================================
- Use two devices. The callee should be a real phone; a USB webcam can serve the emulator.
- Camera behavior must be verified on real hardware (ECERules §27).

Matrix:
| Case | Expected |
|---|---|
| Caller starts video call | Local preview appears, ringback plays, callee card says "Incoming Video Call" |
| Callee has no camera while ringing | Correct; camera starts only after Accept |
| Accept | Log `📷 [Media] camera on` on callee; both sides show remote video and local preview |
| Mute / Camera / Speaker | State and UI update |
| Flip | Switches front/back (needs a device with two cameras) |
| End (either side) | Both cameras stop, screen closes |
| Caller cancel, callee decline, timeout | Cleanup as in voice calls |

Results 2026-10-02 (Pixel 8 emulator + webcam → Nokia 6.1): all rows passed except Flip (not testable).

Still to test: video via background push, killed-state video Accept, notification-body tap,
camera permission denied (call should continue as voice), Flip on a two-camera phone.