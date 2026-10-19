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

=====================================================================
## PHASE 5 CONVERSATION

## Next
- [ ] Phase 1 leftovers: Profile Photos, User Profile
- [ ] Group chat conversations (type, adminIds, member list). Unblocks the items below
- [ ] Tile-owned live group calls (set conversationId), non-invited members can join (Condition 2)
- [ ] Conversation filter "Groups" (after group chats)

## Blaze migration (push work, do once Cloud Functions are available)
Replace `push_relay/relay.js` with Cloud Functions: `onCallRinging` (1:1, exists in functions/src/index.ts)
plus `onGroupCallCreated` / `onGroupCallEnded` (types: incoming_group_call, group_call_cancelled).
- [ ] Mute: functions read `users/{uid}/conversationSettings` before sending message and call pushes
Client files that stay unchanged: call_push_handler.dart, callkit_bridge.dart, pending_call_service.dart,
call_kit_callbacks.dart, group_call_controller.dart, global_group_call_listener.dart
- [ ] Retire push_relay/

## Verify
- [ ] Group killed-state accept/decline, re-test after the double-accept guard
- [ ] Busy auto-reject on a real third device (passed once)
- [ ] Notification-body tap while a group call rings (no in-app takeover yet)
- [ ] Flip camera on a two-camera phone
- [ ] Camera permission denied path
- [ ] Pixel emulators do not receive FCM reliably: verify on real devices

## Before release
- [ ] Replace the open Firestore rules (delete the {document=**} wildcard last). Blocks needed:
  users, typing, presence, conversations (+ messages), calls, callHistory, groupCalls
  (get by participantIds, list by participantIds), users/{uid}/groupCallHistory (owner only),
  users/{uid}/conversationSettings (owner only)
- [ ] Confirm messages live only under conversations/{id}/messages, then delete the unused
      FirestoreRepository.messagesCollection getter
- [ ] Server-side check that group invitees are real contacts
- [ ] Use serverTimestamp for call createdAt (clock skew)
- [ ] Move remaining call strings and colors to CallStrings / AppColors tokens
- [ ] Move ConversationStrings use into the remaining chat screens
- [ ] Remove timing debug prints
- [ ] Complete the Info.plist contacts usage description sentence
- [ ] Guard NetworkImage against empty URLs everywhere (search for NetworkImage()

## Known limits
- Archived chats do not pop out on a new message
- Accepting a group call after the 30 s ring timeout is refused as stale
- Group call history is not written for calls that were never delivered
- Ring-timeout reaper and heartbeat for stuck calls (needs server)

## Later (cut from v1)
- [ ] Mid-call invite, rejoin, host rights
- [ ] 1:1 to group escalation (origin: escalated, shared LiveKit room)
- [ ] Meetings with IDs and links (token server, guests, deep links)
- [ ] Screen share, recording, waiting room, reactions, raise hand, in-call chat, meeting passwords

## Done
- [x] Phase 4 media: 1:1 voice and video, group voice and video, joinable banner, history tab, CallController split
- [x] Phase 5 conversations: search, pin, archive, favorite, mute, filters

=====================================================
## PHASE 6
=====================================================
# TODO

## Next
- [ ] Self-healing login: create users/{uid} if the profile document is missing
- [ Done ] Message edit (does not exist yet; "Allow edit info" is group name/description only)
- [Done ] Hide old messages from new group members (query by joinedAt)
- [ ] Phase 1 leftovers and Phase 7 onward
- [ ] Mentions (@), after Phase 7

## Security
- [ Blaze] Move fcmToken out of the public users/{uid} document into a private document
      (needs a client change and a relay/Cloud Function change). Low severity: a token alone cannot send a push,
      but it is readable by every signed-in user
- [Done ] Contact privacy: email and phone live in users/{uid}/private/*, sharing flags in the public document.
      Rules cannot check "shares a group with me", so any signed-in user may read once the flag is on
- [Blaze ] Group permission map values are only checked client-side; per-value checks in rules need a server
- [ ] Server-side check that group invitees are real contacts
- [ Done ] Cloudinary: restrict the unsigned preset (formats, max size, folder, unique filename, no overwrite),
      signed uploads from a server later
- [ Done] Profile and group photos: bake EXIF orientation, square crop (512 px), optimize off the UI thread

## Blaze phase (server work, do once)
- [ ] Replace push_relay/relay.js with Cloud Functions: onCallRinging (1:1), onGroupCallCreated/Ended
- [ ] Mute: functions read users/{uid}/conversationSettings before sending message and call pushes
- [ ] Move fcmToken to a private document (client + function change together)
- [ ] Callable function for group changes: validate permission map values and that invitees are real contacts
- [ ] Account deletion server job: client only signs out and requests deletion; the server evicts the user from
      groups, formats the tombstone profile and scrubs subcollections. A client cannot delete other users' data,
      and a cleanup interrupted by a crash or lost network leaves orphans
- [ ] Scheduled cleanup: deleted groups (>7 days), ended group calls (>30 days), stale typing (>1 day).
      Script exists: push_relay/cleanup.js (dry-run by default, --apply to delete)
- [ ] Ring-timeout reaper and heartbeat for stuck calls; write the group call chat line when the call truly ends
- [ ] One-time migration of every account's email/phone to private documents (Admin SDK),
      then remove contactMigrationProvider
- [ ] Signed Cloudinary uploads 
- [ ] serverTimestamp for call createdAt (CallSession must accept a null createdAt)     
- [ ] Retire push_relay/
- [ ] └── Advanced
    └── Mentions (@)

## Verify
- [DOne] Group killed-state accept/decline, after the double-accept guard
- [DOne ] Notification-body tap while a group call rings (no in-app takeover)
- [DOne ] Delete-messages permission: canDeleteOthers wired in MessageList
- [DOne ] Creator protection (other admins cannot demote or remove the creator)
- [DOne ] Flip camera on a two-camera phone, camera permission denied path

## Before release
- [ ] Confirm messages live only under conversations/{id}/messages, then delete the unused
      FirestoreRepository.messagesCollection getter
- [ ] Use serverTimestamp for call createdAt (clock skew)
- [ ] Move remaining call and chat strings and colors to CallStrings / ConversationStrings / AppColors
- [ ] Remove debug prints (typing, send, group, timing)
- [ ] Complete the Info.plist contacts usage description sentence
- [ ] Guard NetworkImage against empty URLs everywhere
- [ ] Info.plist contacts usage description sentence
- [ ] Delete the unused FirestoreRepository.messagesCollection getter

## Known limits
- Archived chats do not pop out on a new message
- Accepting a group call after the 30 s ring timeout is refused as stale
- Group call history is not written for calls that were never delivered
- A deleted group keeps its messages until the server cleanup runs
- Message edit window is 15 minutes

## Later
- [ ] Mid-call invite, rejoin, host rights
- [ ] 1:1 to group escalation, meetings with IDs and links
- [ ] Screen share, recording, waiting room, reactions, raise hand, in-call chat
- [ ] Tile-owned live group calls and non-invited chat members joining (group chats now exist)
- [ ] Mentions (@)

## Done
- [x] Phase 4 media, Phase 5 conversations
- [x] Phase 6 group chat: create, info, admin actions, system messages, avatar, read-only profile, privacy migration
- [x] Message edit, history hidden from new members, creator protection, delete permission
- [x] Contact privacy migration, Cloudinary preset restrictions, group call kill/background checks

## Limits (add to TODO.md)

- Old messages and group call names keep A’s old name, because senders are stored by name at send time. Only the profile is anonymized.
- The server job in the Blaze phase finishes cleanup for interrupted deletions. A client can’t delete other users’ data.
- Only email and password accounts are supported, since re-authentication uses the password.