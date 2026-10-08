## TODO.md ⭐⭐⭐⭐

TODO

- Push Notifications
- Image Compression
- Voice Messages
- Search
- Archive
- Theme Switching
- Group Chat

-------------------------------------------------------------
# ✅ TODO.md 22/07/2026
-------------------------------------------------------------
# ECE Chat Development Tasks

Current Version: **v1.6.1**

---

# 🎉 Completed (v1.6.1)

## Theme Infrastructure

- [x] Material 3 migration
- [x] Centralized AppTheme
- [x] AppComponentTheme
- [x] AppTextTheme
- [x] Theme Provider
- [x] Theme persistence
- [x] Theme selector
- [x] ThemeContextExtension
- [x] ChatBubbleThemeExtension
- [x] Dynamic Light/Dark switching
- [x] Semantic typography shortcuts
- [x] Semantic color shortcuts

---

## Component Themes

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

## UI Migration

- [x] Remove hardcoded colors
- [x] Remove hardcoded text styles
- [x] Centralize InputDecoration
- [x] Centralize button styling
- [x] Centralize progress indicators
- [x] Centralize divider styling
- [x] Centralize card styling

---

## Chat Improvements

- [x] Dynamic chat bubble colors
- [x] Dynamic read receipts
- [x] Dynamic unread receipts
- [x] Theme-aware message timestamps

---

# 🚀 Next Release (v1.7.0)

## Message Management

- [ ] Delete for Me
- [ ] Delete for Everyone
- [ ] Deleted message placeholder

---

## Editing

- [ ] Edit message
- [ ] Edited indicator
- [ ] Edit history preparation

---

## Reply System

- [ ] Reply preview
- [ ] Reply navigation
- [ ] Quoted messages

---

## Forwarding

- [ ] Forward message
- [ ] Multi-select conversations
- [ ] Forward confirmation

---

## Emoji Reactions

- [ ] Add reaction
- [ ] Remove reaction
- [ ] Multiple reactions
- [ ] Reaction counter

---

## Search

- [ ] Search conversation
- [ ] Highlight matches
- [ ] Search navigation
- [ ] Search history

---

# 📌 Future Releases

## Attachments

- [ ] Image messages
- [ ] Camera support
- [ ] Document sharing
- [ ] Video sharing
- [ ] Audio messages

---

## Groups

- [ ] Group conversations
- [ ] Group roles
- [ ] Group avatar
- [ ] Group settings

---

## Notifications

- [ ] Push notifications
- [ ] Background notifications
- [ ] Notification actions

---

## Security

- [ ] Block users
- [ ] Report users
- [ ] Privacy settings
- [ ] Two-factor authentication

---

## Performance

- [ ] Pagination
- [ ] Image caching
- [ ] Offline cache
- [ ] Lazy loading
- [ ] Firestore optimization

---

## UI / UX

- [ ] Chat wallpaper
- [ ] Font size options
- [ ] Chat bubble customization
- [ ] Accessibility improvements
- [ ] Animation refinements

---

# 📚 Documentation

Keep the following documents synchronized with every release:

- [ ] CHANGELOG.md
- [ ] VERSION_HISTORY.md
- [ ] GitHubRelease.md
- [ ] README.md
- [ ] ROADMAP.md
- [ ] ARCHITECTURE.md
- [ ] TESTING.md
- [ ] TODO.md

---

# 🎯 Current Development Target

**Version:** v1.7.0

**Primary Focus:**

Advanced Messaging Features

Priority order:

1. Delete for Everyone
2. Delete for Me
3. Edit Message
4. Reply to Message
5. Forward Message
6. Emoji Reactions
7. Message Search

---

Last Updated:

**ECE Chat v1.6.1**
====================================================================
## 1.8.4
====================================================================

- [ ] Verify killed-state Accept (PendingCallService → CallScreen)
- [ ] Verify notification-body tap while ringing
- [ ] Tighten Firestore rules (calls, users, conversations) before release
- [ ] Move call strings to CallStrings, colors to AppColors/theme extension
- [ ] Enable Blaze and deploy onCallRinging to replace push_relay
- [ ] Use serverTimestamp for call createdAt (clock-skew fix)

====================================================================
## 1.8.5

## Next (polish)
- [ ] Move `call_screen.dart` to `core/screens/` (`git mv`, fix imports)
- [ ] Split `CallController` (no behavior change, one commit each):
  - [ ] `CallRoomEventsBinder`
  - [ ] `CallKitCallbacks`
  - [ ] `CallAppLifecycleHandler`
- [ ] Guard `NetworkImage` against empty URLs in `_PeerAvatar` and `_Waiting` (search project for `NetworkImage(`)
- [ ] Remove debug print "Its for check is _startCall running"
- [ ] Move call strings to `CallStrings`; colors to `AppColors` / theme tokens
- [ ] Finish a real `CallScreen` incoming-card label review (voice vs video)

## Verify
- [ ] Killed-state Accept (PendingCallService → CallScreen)
- [ ] Notification-body tap while ringing
- [ ] Video call via background and killed push
- [ ] Flip camera on a two-camera device
- [ ] Camera permission denied path

## Before release
- [ ] Tighten Firestore rules (calls, users, conversations)
- [ ] Enable Blaze and deploy `onCallRinging`, retire `push_relay/`
- [ ] Use `serverTimestamp` for call `createdAt` (clock-skew fix)
- [ ] Complete the `Info.plist` contacts usage description sentence

## Planned
- [ ] Group voice and video calls (design review first: model, signaling, size limit, admin policy)

-----------------------------------------------------
## v1.9.0

## Next
- [ ] Group voice call (in progress)
- [ ] Group push (relay watches groupCalls, background handler, CallKit, killed-state paths)
- [ ] Group chat conversations (type, adminIds) + call bubbles
## Later
- [ ] Mid-call invite, rejoin, host rights, ring-timeout reaper
- [ ] 1:1 → group escalation (origin: escalated)
- [ ] Meetings with IDs/links (token server, guests)
- [ ] Screen share, recording, waiting room, reactions, in-call chat
## Before release
- [ ] Replace open Firestore rules (add groupCalls get/list split, users/{uid}/groupCallHistory owner-only)
- [ ] Server-side check that invitees are real contacts
- [ ] Move call strings/colors fully to CallStrings/tokens
- [ ] Remove timing debug prints

-------------------------------------------------------------
## Blaze migration: group + 1:1 push (redo when Cloud Functions are available)

Replace `push_relay/relay.js` with Cloud Functions: `onCallRinging` (1:1, exists in functions/src/index.ts)
and a new `onGroupCallCreated` / `onGroupCallEnded` (types: incoming_group_call, group_call_cancelled).

 Files that stay unchanged (client side, already done):

- core/services/call_push_handler.dart  (background handler, group + 1:1)
- core/services/callkit_bridge.dart  (showRaw isGroup, endNative, isActiveNatively)
- core/services/pending_call_service.dart
- core/controllers/call_kit_callbacks.dart  (group-first routing)
- core/controllers/group_call_controller.dart  (acceptFromNative / declineFromNative / timeoutFromNative)
- core/widgets/global_group_call_listener.dart
Files that get replaced/retired:
- push_relay/relay.js
Known limits to revisit:
- Notification-body tap while ringing: no group in-app takeover
- Accept after the 30 s ring timeout is refused as stale
- Group history not written if the call was never delivered
- Pixel emulators may not receive FCM (no Play Services token): verify on real devices
- Group killed-state accept/decline: test once more with the double-accept fix
- [ ] Group chat feature → then tile-owned live calls (conversationId set), banner only for ad-hoc calls